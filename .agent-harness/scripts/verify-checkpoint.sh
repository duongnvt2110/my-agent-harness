#!/usr/bin/env bash
set -euo pipefail

checkpoint="${1:-}"
root="${2:-}"
[ -n "$checkpoint" ] && [ -n "$root" ] || { echo "Usage: scripts/verify-checkpoint.sh CHECKPOINT ROOT" >&2; exit 2; }
python3 - "$checkpoint" "$root" <<'PY'
from __future__ import annotations
import hashlib, json, pathlib, sys

checkpoint = pathlib.Path(sys.argv[1]).resolve()
root = pathlib.Path(sys.argv[2]).resolve()
manifest = json.loads((checkpoint / "manifest.json").read_text())
if manifest.get("checkpoint_schema_version") != 2 or manifest.get("canonicalization_version") != 1:
    raise SystemExit("unsupported checkpoint schema or canonicalization")
if manifest.get("checkpoint_id") != manifest.get("run_id") or not manifest.get("run_id"):
    raise SystemExit("checkpoint run identity is missing or inconsistent")
expected_manifest_hash = manifest.get("manifest_hash")
if expected_manifest_hash:
    copy = dict(manifest); copy.pop("manifest_hash", None)
    if hashlib.sha256(json.dumps(copy, sort_keys=True, separators=(",", ":")).encode()).hexdigest() != expected_manifest_hash:
        raise SystemExit("checkpoint manifest hash mismatch")
expected = {row["path"]: row for row in manifest.get("files", [])}
if len(expected) != len(manifest.get("files", [])):
    raise SystemExit("checkpoint manifest contains duplicate paths")
for row in expected.values():
    rel = row.get("path", "")
    pure = pathlib.PurePosixPath(rel)
    if not rel or pure.is_absolute() or ".." in pure.parts or row.get("type") not in {"file", "symlink"}:
        raise SystemExit(f"unsafe or malformed checkpoint path: {rel}")
    if not isinstance(row.get("sha256"), str) or len(row["sha256"]) != 64:
        raise SystemExit(f"invalid checkpoint hash: {rel}")
    source = checkpoint / "files" / row["path"]
    if checkpoint not in source.resolve().parents and source.resolve() != checkpoint / "files":
        raise SystemExit(f"checkpoint path escapes payload: {rel}")
    if not source.exists() and not source.is_symlink():
        raise SystemExit(f"missing checkpoint file: {row['path']}")
    raw = source.readlink().as_posix().encode() if row["type"] == "symlink" else source.read_bytes()
    if hashlib.sha256(raw).hexdigest() != row["sha256"]:
        raise SystemExit(f"checkpoint hash mismatch: {row['path']}")
if root.exists():
    actual = {}
    for path in root.rglob("*"):
        if path.is_file() or path.is_symlink():
            rel = path.relative_to(root).as_posix()
            if rel == ".checkpoint-restore-journal.json":
                continue
            raw = path.readlink().as_posix().encode() if path.is_symlink() else path.read_bytes()
            actual[rel] = hashlib.sha256(raw).hexdigest()
    missing = sorted(set(expected) - set(actual))
    extra = sorted(set(actual) - set(expected))
    changed = sorted(path for path in set(expected) & set(actual) if expected[path]["sha256"] != actual[path])
    if missing or extra or changed:
        raise SystemExit(f"workspace differs from checkpoint: missing={missing} extra={extra} changed={changed}")
print("checkpoint_valid: true")
print(f"run_id: {manifest.get('run_id')}")
print(f"files: {len(expected)}")
PY
