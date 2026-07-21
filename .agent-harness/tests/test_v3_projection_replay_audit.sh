#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/../.." && pwd)"
audit="$root/.agent-harness/scripts/check-v3-projections"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/run" "$tmp/docs/tasks"

python3 - "$tmp" <<'PY'
import hashlib, json, pathlib
root = pathlib.Path(__import__('sys').argv[1])
run = root / 'run'
def canon(v): return json.dumps(v, sort_keys=True, separators=(',', ':'), ensure_ascii=True).encode()
prev = '0' * 64
event = {'schema_version':1,'sequence':1,'event_type':'STATE_TRANSITION','run_id':'run-1','task_id':'task-1','from_state':'VERIFYING','to_state':'FINALIZED','actor':'Verifier','occurred_at':'2026-07-11T00:00:00Z','previous_hash':prev}
event['event_hash'] = hashlib.sha256(prev.encode() + canon({k:v for k,v in event.items() if k != 'event_hash'})).hexdigest()
(run/'events.jsonl').write_text(json.dumps(event, sort_keys=True, separators=(',', ':'))+'\n')
state = {'schema_version':1,'canonicalization_version':1,'run_id':'run-1','task_id':'task-1','state':'FINALIZED','event_sequence':1,'event_hash':event['event_hash']}
(run/'state.json').write_text(json.dumps(state, sort_keys=True, separators=(',', ':'))+'\n')
(run/'current.md').write_text('---\ngenerated: true\nprojection_source: state.json\nrun_id: run-1\ntask_id: task-1\nstate: FINALIZED\nevent_sequence: 1\n---\n\n# Generated Run Projection\n')
(root/'docs/tasks/tasks.jsonl').write_text(json.dumps({'id':'task-1','status':'DONE'})+'\n')
PY

rtk "$audit" --state "$tmp/run/state.json" --task-store "$tmp/docs/tasks/tasks.jsonl" >/dev/null
hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'; else shasum -a 256 "$1" | awk '{print $1}'; fi
}
before="$(hash_file "$tmp/run/current.md")"
perl -0pi -e 's/state: FINALIZED/state: VERIFYING/' "$tmp/run/current.md"
if rtk "$audit" --state "$tmp/run/state.json" --task-store "$tmp/docs/tasks/tasks.jsonl" >/dev/null 2>&1; then
  echo 'stale projection was accepted' >&2
  exit 1
fi
after="$(hash_file "$tmp/run/current.md")"
[ "$before" != "$after" ]

echo 'v3 projection replay audit tests passed'
