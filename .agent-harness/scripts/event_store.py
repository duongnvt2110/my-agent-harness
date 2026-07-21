"""Canonical v3 event-chain implementation used by every lifecycle writer."""
from __future__ import annotations

import hashlib
import json
import pathlib

ZERO_HASH = "0" * 64


def canonical(value: object) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()


def load(path: pathlib.Path) -> list[dict]:
    if not path.exists():
        return []
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.strip():
            rows.append(json.loads(line))
    return rows


def validate(rows: list[dict]) -> str | None:
    previous = ZERO_HASH
    for sequence, row in enumerate(rows, 1):
        if row.get("schema_version") != 1 or row.get("sequence") != sequence:
            return "event schema or sequence mismatch"
        if row.get("previous_hash") != previous:
            return "event previous_hash does not match canonical chain"
        supplied = row.get("event_hash")
        unsigned = dict(row)
        unsigned.pop("event_hash", None)
        expected = hashlib.sha256(previous.encode() + canonical(unsigned)).hexdigest()
        if supplied != expected:
            return "event hash mismatch"
        previous = supplied
    return None


def append(path: pathlib.Path, *, run_id: str, task_id: str, event_type: str, payload: dict) -> dict:
    rows = load(path)
    error = validate(rows)
    if error:
        raise ValueError(error)
    previous = rows[-1]["event_hash"] if rows else ZERO_HASH
    row = build(len(rows) + 1, previous, run_id=run_id, task_id=task_id, event_type=event_type, payload=payload)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(row, sort_keys=True, separators=(",", ":")) + "\n")
        handle.flush()
    return row


def build(sequence: int, previous: str, *, run_id: str, task_id: str, event_type: str, payload: dict) -> dict:
    row = {
        "schema_version": 1,
        "canonicalization_version": 1,
        "sequence": sequence,
        "run_id": run_id,
        "task_id": task_id,
        "event_type": event_type,
        "previous_hash": previous,
    }
    row.update(payload)
    row["event_hash"] = hashlib.sha256(previous.encode() + canonical(row)).hexdigest()
    return row
