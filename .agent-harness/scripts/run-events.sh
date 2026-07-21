#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command="${1:-}"
shift || true
usage() { echo "Usage: run-events.sh create|append|verify ..." >&2; exit 2; }

case "$command" in
  create)
    dir="${1:-}"; task_id="${2:-}"; spec_hash="${3:-}"; policy_hash="${4:-}"; predecessor="${5:-}"
    [ -n "$dir" ] && [ -n "$task_id" ] && [ -n "$spec_hash" ] && [ -n "$policy_hash" ] || usage
    python3 - "$dir" "$task_id" "$spec_hash" "$policy_hash" "$predecessor" <<'PY'
import hashlib, json, pathlib, sys, uuid
from datetime import datetime, timezone
root = pathlib.Path(sys.argv[1]); run_file = root / "run.json"; predecessor = pathlib.Path(sys.argv[5]) if sys.argv[5] else None
if run_file.exists(): raise SystemExit("run identity is immutable")
run_id = str(uuid.uuid4())
lineage = {"supersedes_run_id": None, "supersedes_run_hash": None}
if predecessor:
    if not predecessor.is_file(): raise SystemExit("predecessor run identity is missing")
    prior = json.loads(predecessor.read_text())
    if prior.get("run_id") == run_id: raise SystemExit("successor cannot self-link")
    for key, expected in (("task_id", sys.argv[2]), ("spec_hash", sys.argv[3]), ("policy_hash", sys.argv[4])):
        if prior.get(key) != expected: raise SystemExit(f"predecessor {key} mismatch")
    predecessor_hash = hashlib.sha256(predecessor.read_bytes()).hexdigest()
    lineage = {"supersedes_run_id": prior["run_id"], "supersedes_run_hash": predecessor_hash}
record = {"schema_version": 1, "canonicalization_version": 1,
          "run_id": run_id, "task_id": sys.argv[2],
          "spec_hash": sys.argv[3], "policy_hash": sys.argv[4],
          "created_at": datetime.now(timezone.utc).isoformat(),
          "event_chain": "local_tamper_evidence", **lineage}
record["lineage_hash"] = hashlib.sha256(json.dumps(record, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
root.mkdir(parents=True, exist_ok=True)
run_file.write_text(json.dumps(record, sort_keys=True, indent=2) + "\n")
(root / "events.jsonl").touch()
print(run_id)
PY
    ;;
  append)
    dir="${1:-}"; event_type="${2:-}"; payload="${3:-}"
    [ -n "$payload" ] || payload='{}'
    [ -d "$dir" ] && [ -n "$event_type" ] || usage
    lock="$dir/events.jsonl.lock"
    if ! mkdir "$lock" 2>/dev/null; then echo "event journal busy" >&2; exit 75; fi
    trap 'rmdir "$lock" 2>/dev/null || true' EXIT
    python3 - "$dir" "$event_type" "$payload" "$script_dir" <<'PY'
import json, pathlib, sys
sys.path.insert(0, sys.argv[4])
from event_store import append
root = pathlib.Path(sys.argv[1]); run = json.loads((root / "run.json").read_text())
record = append(root / "events.jsonl", run_id=run["run_id"], task_id=run["task_id"], event_type=sys.argv[2], payload=json.loads(sys.argv[3]))
print(record["sequence"])
PY
    ;;
  verify)
    dir="${1:-}"; [ -d "$dir" ] || usage
    python3 - "$dir" "$script_dir" <<'PY'
import json, pathlib, sys
sys.path.insert(0, sys.argv[2])
from event_store import load, validate
root = pathlib.Path(sys.argv[1]); run = json.loads((root / "run.json").read_text())
if run.get("supersedes_run_id") and not run.get("lineage_hash"):
    raise SystemExit("successor run lineage hash is missing")
rows = load(root / "events.jsonl")
error = validate(rows)
if error:
    raise SystemExit(error)
if any(row.get("run_id") != run.get("run_id") or row.get("task_id") != run.get("task_id") for row in rows):
    raise SystemExit("event identity mismatch")
print(json.dumps({"valid": True, "run_id": run["run_id"], "events": len(rows), "head": rows[-1]["event_hash"] if rows else None}, sort_keys=True))
PY
    ;;
  *) usage ;;
esac
