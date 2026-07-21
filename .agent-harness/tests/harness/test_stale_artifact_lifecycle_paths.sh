#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

state="$tmp/state.json"
cat >"$state" <<'JSON'
{"schema_version":1,"canonicalization_version":1,"run_id":"run-focused","task_id":"task-focused","state":"INTAKE","previous_state":null,"active_function":"intake","updated_at":"2026-07-16T00:00:00Z","event_sequence":0,"event_hash":"0000000000000000000000000000000000000000000000000000000000000000"}
JSON

# The v3 public surface must preserve the same lifecycle decision as the
# transition writer and must create only a state-derived projection.
direct="$tmp/direct.txt"
public="$tmp/public.txt"
"$harness_root/scripts/transition-state" --state "$state" --to UNDER_REVIEW --check >"$direct"
"$harness_root/scripts/harness.sh" transition-state --state "$state" --to UNDER_REVIEW --check >"$public"
grep -q '^decision: ALLOW$' "$direct"
grep -q '^decision: ALLOW$' "$public"

"$harness_root/scripts/transition-state" --state "$state" --to UNDER_REVIEW --apply >/dev/null
[ -f "$tmp/current.md" ]
[ -f "$tmp/events.jsonl" ]
grep -q 'projection_source: state.json' "$tmp/current.md"

# Stale and unknown lifecycle states cannot be treated as recoverable v3
# states, and a terminal state cannot be advanced.
python3 - "$state" <<'PY'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["state"] = "ROLLED_BACK"
path.write_text(json.dumps(data) + "\n")
PY
if "$harness_root/scripts/transition-state" --state "$state" --to INTAKE --check >/dev/null 2>&1; then
  echo "stale ROLLED_BACK state was accepted" >&2
  exit 1
fi

python3 - "$state" <<'PY'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["state"] = "FINALIZED"
data["active_function"] = "finalization"
path.write_text(json.dumps(data) + "\n")
PY
if "$harness_root/scripts/transition-state" --state "$state" --to INTAKE --check >/dev/null 2>&1; then
  echo "terminal FINALIZED state was accepted" >&2
  exit 1
fi

legacy="$tmp/current.md"
cat >"$legacy" <<'EOF'
---
task_id: stale-task
state: IMPLEMENTING
---
EOF
if "$harness_root/scripts/transition-state" --state "$legacy" --to VERIFYING --check >/dev/null 2>&1; then
  echo "legacy current.md was accepted as lifecycle authority" >&2
  exit 1
fi

echo "Stale artifact and lifecycle path regression passed."
