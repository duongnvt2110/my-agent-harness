#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
validator="$harness_root/scripts/validate-current-state.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

python3 - "$tmp" <<'PY'
import hashlib, json, pathlib, sys
root = pathlib.Path(sys.argv[1])
unsigned = {
    "schema_version": 1, "sequence": 1, "event_type": "STATE_TRANSITION",
    "run_id": "run-1", "task_id": "task-1", "from_state": "INTAKE",
    "to_state": "SPEC_LOCKED", "active_function": "specification", "occurred_at": "2026-07-12T00:00:00Z",
    "previous_hash": "0" * 64,
}
canonical = json.dumps(unsigned, sort_keys=True, separators=(",", ":"), ensure_ascii=True)
event = dict(unsigned, event_hash=hashlib.sha256((unsigned["previous_hash"] + canonical).encode()).hexdigest())
(root / "events.jsonl").write_text(json.dumps(event, sort_keys=True, separators=(",", ":")) + "\n")
state = {
    "schema_version": 1, "canonicalization_version": 1, "run_id": "run-1", "task_id": "task-1",
    "state": "SPEC_LOCKED", "previous_state": "INTAKE", "active_function": "specification",
    "updated_at": "2026-07-12T00:00:00Z", "event_sequence": 1, "event_hash": event["event_hash"],
}
(root / "state.json").write_text(json.dumps(state))
PY

"$validator" --state "$tmp/state.json" >/dev/null
python3 - "$tmp/events.jsonl" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
p.write_text(p.read_text().replace("SPEC_LOCKED", "UNDER_REVIEW"))
PY
if "$validator" --state "$tmp/state.json" >/dev/null 2>&1; then
  echo "corrupt event chain unexpectedly accepted" >&2
  exit 1
fi
echo "Current-state event-chain regression passed."
