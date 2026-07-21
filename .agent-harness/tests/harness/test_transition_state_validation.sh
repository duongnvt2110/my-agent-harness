#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
transition="$harness_root/scripts/transition-state"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

state="$tmp/state.json"
printf '%s\n' '{"schema_version":1,"canonicalization_version":1,"run_id":"run-1","task_id":"task-1","state":"INTAKE","previous_state":null,"active_function":"intake","updated_at":"2026-07-11T00:00:00Z","event_sequence":0,"event_hash":"0000000000000000000000000000000000000000000000000000000000000000"}' >"$state"

"$transition" --state "$state" --to UNDER_REVIEW --check >"$tmp/allow.txt"
grep -q '^decision: ALLOW$' "$tmp/allow.txt"

"$transition" --state "$state" --to UNDER_REVIEW --apply >"$tmp/apply.txt"
grep -q '^decision: ALLOW$' "$tmp/apply.txt"
grep -q '^event_sequence: 1$' "$tmp/apply.txt"
[ "$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["state"])' "$state")" = "UNDER_REVIEW" ]
[ "$(wc -l < "$tmp/events.jsonl" | tr -d ' ')" = "1" ]
[ -f "$tmp/current.md" ]
[ "$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["status"])' "$tmp/transition-journal.json")" = "FINALIZED" ]
"$harness_root/scripts/check-state-schema.sh" "$state" | grep -q '^valid: true$'

python3 - "$tmp/transition-journal.json" <<'PY'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["status"] = "FINALIZING"
data["expected_before_hash"] = "0" * 64
data["expected_after_hash"] = "1" * 64
path.write_text(json.dumps(data) + "\n")
PY
if "$transition" --state "$state" --to CLARIFICATION_REQUIRED --apply >/dev/null 2>&1; then
  echo "ambiguous transition journal was accepted" >&2
  exit 1
fi
rm -f "$tmp/transition-journal.json"

sed -i.bak 's/STATE_TRANSITION/STATE_CORRUPTED/' "$tmp/events.jsonl"
if "$transition" --state "$state" --to CLARIFICATION_REQUIRED --apply >/dev/null 2>&1; then
  echo "corrupted event chain was accepted" >&2
  exit 1
fi
mv "$tmp/events.jsonl.bak" "$tmp/events.jsonl"

if "$transition" --state "$state" --to FINALIZED --check >"$tmp/deny.txt" 2>&1; then
  echo "illegal transition was accepted" >&2
  exit 1
fi
grep -q 'illegal transition: UNDER_REVIEW -> FINALIZED' "$tmp/deny.txt"

printf '%s\n' '{"schema_version":1,"canonicalization_version":1,"run_id":"run-1","task_id":"task-1","state":"FINALIZED","previous_state":"INTAKE","active_function":"finalization","updated_at":"2026-07-11T00:00:00Z","event_sequence":0,"event_hash":"0000000000000000000000000000000000000000000000000000000000000000"}' >"$state"
if "$transition" --state "$state" --to INTAKE --check >/dev/null 2>&1; then
  echo "terminal transition was accepted" >&2
  exit 1
fi

echo "Transition validation regression passed."
