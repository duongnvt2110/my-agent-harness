#!/usr/bin/env bash
set -euo pipefail

request="${1:-}"
ledger="${2:-}"
[ -n "$request" ] && [ -n "$ledger" ] || {
  echo "Usage: scripts/remediation-epoch.sh REQUEST.json EPOCHS.jsonl" >&2
  exit 2
}

python3 - "$request" "$ledger" <<'PY'
from __future__ import annotations
import datetime as dt
import hashlib
import json
import os
import pathlib
import sys

request_path = pathlib.Path(sys.argv[1])
ledger_path = pathlib.Path(sys.argv[2])
request = json.loads(request_path.read_text(encoding="utf-8"))
required = ("task_id", "run_id", "risk", "reason", "budget_exhausted", "failure_history_hash")
missing = [key for key in required if key not in request]
if missing:
    raise SystemExit("remediation epoch request missing: " + ",".join(missing))
if request["risk"] not in {"tiny", "normal", "high_risk"}:
    raise SystemExit("unsupported remediation risk")
if request["reason"] != "BUDGET_EXHAUSTED" or request["budget_exhausted"] is not True:
    raise SystemExit("only budget exhaustion can renew a remediation epoch")
if not isinstance(request["failure_history_hash"], str) or len(request["failure_history_hash"]) != 64:
    raise SystemExit("failure_history_hash must be a SHA-256 digest")

rows = [json.loads(line) for line in ledger_path.read_text(encoding="utf-8").splitlines() if line.strip()] if ledger_path.exists() else []
previous_hash = rows[-1].get("epoch_hash", "0" * 64) if rows else "0" * 64
if rows and any(row.get("task_id") != request["task_id"] or row.get("run_id") != request["run_id"] for row in rows):
    raise SystemExit("remediation epoch ledger identity does not match request")
epoch_number = len(rows) + 1
event = {
    "schema_version": 1,
    "sequence": epoch_number,
    "epoch_number": epoch_number,
    "task_id": request["task_id"],
    "run_id": request["run_id"],
    "risk": request["risk"],
    "reason": "BUDGET_EXHAUSTED",
    "budget_exhausted": True,
    "budget_reset": True,
    "failure_history_hash": request["failure_history_hash"],
    "failure_history_preserved": True,
    "requires_human_review": False,
    "previous_hash": previous_hash,
    "created_at": dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
}
event["epoch_hash"] = hashlib.sha256(previous_hash.encode() + json.dumps(event, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
ledger_path.parent.mkdir(parents=True, exist_ok=True)
with ledger_path.open("a", encoding="utf-8") as handle:
    handle.write(json.dumps(event, sort_keys=True, separators=(",", ":")) + "\n")
    handle.flush()
    os.fsync(handle.fileno())
print(json.dumps({"decision": "CONTINUE", "epoch_number": epoch_number, "epoch_hash": event["epoch_hash"], "failure_history_preserved": True, "requires_human_review": False}, sort_keys=True))
PY
