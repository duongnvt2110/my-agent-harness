#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/run" "$tmp/docs"
python3 - "$tmp/run" <<'PY'
import hashlib, json, pathlib, sys

root = pathlib.Path(sys.argv[1])
state = {
    "schema_version": 1,
    "canonicalization_version": 1,
    "run_id": "run-state-alignment",
    "task_id": "task-state-alignment",
    "state": "FINALIZED",
    "active_function": "finalization",
    "updated_at": "2026-07-16T00:00:00Z",
    "event_sequence": 1,
}
event = {
    "schema_version": 1,
    "sequence": 1,
    "event_type": "STATE_TRANSITION",
    "run_id": state["run_id"],
    "task_id": state["task_id"],
    "from_state": "HUMAN_FINAL_REVIEW",
    "to_state": "FINALIZED",
    "active_function": "finalization",
    "occurred_at": state["updated_at"],
    "previous_hash": "0" * 64,
}
canonical = json.dumps(event, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()
event["event_hash"] = hashlib.sha256(("0" * 64).encode() + canonical).hexdigest()
state["event_hash"] = event["event_hash"]
(root / "state.json").write_text(json.dumps(state) + "\n")
(root / "events.jsonl").write_text(json.dumps(event) + "\n")
(root / "current.md").write_text("---\ngenerated: true\nprojection_source: state.json\nrun_id: run-state-alignment\ntask_id: task-state-alignment\nstate: FINALIZED\nevent_sequence: 1\n---\n")
PY
printf '%s\n' '{"id":"task-state-alignment","status":"DONE"}' > "$tmp/docs/tasks.jsonl"

"$harness_root/scripts/check-v3-projections" --state "$tmp/run/state.json" --task-store "$tmp/docs/tasks.jsonl" >/dev/null

python3 - "$tmp/run/state.json" <<'PY'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["state"] = "ROLLED_BACK"
path.write_text(json.dumps(data) + "\n")
PY
if "$harness_root/scripts/check-v3-projections" --state "$tmp/run/state.json" --task-store "$tmp/docs/tasks.jsonl" >/dev/null 2>&1; then
  echo "stale ROLLED_BACK lifecycle state was accepted" >&2
  exit 1
fi

echo "v3 lifecycle state alignment regression passed."
