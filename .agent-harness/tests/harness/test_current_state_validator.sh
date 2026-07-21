#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
validator="$harness_root/scripts/validate-current-state.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

legacy="$tmp/current.md"
cat >"$legacy" <<'EOF'
---
task_id: legacy_task
status: IN_PROGRESS
lifecycle_phase: EXECUTE
workflow_version: 2
---
EOF

if "$validator" --state "$legacy" >/dev/null 2>&1; then
  echo "legacy v2 state must be rejected by the v3 validator" >&2
  exit 1
fi

v3="$tmp/state.json"
cat >"$v3" <<'EOF'
{"schema_version":1,"canonicalization_version":1,"run_id":"run-1","task_id":"task-1","state":"INTAKE","previous_state":null,"active_function":"intake","updated_at":"2026-07-11T00:00:00Z","event_sequence":0,"event_hash":"0000000000000000000000000000000000000000000000000000000000000000"}
EOF
v3_output="$tmp/v3.txt"
if ! "$validator" --state "$v3" >"$v3_output"; then
  echo "complete v3 state should validate when transition-state exists" >&2
  exit 1
fi
grep -q '^authority: state.json$' "$v3_output"
grep -q '^valid: true$' "$v3_output"

if "$validator" >/dev/null 2>&1; then
  echo "implicit current.md fallback must be rejected" >&2
  exit 1
fi
if "$validator" --state "$legacy" --json >/dev/null 2>&1; then
  echo "legacy current.md must be rejected in JSON mode" >&2
  exit 1
fi

json_output="$tmp/state.json.out"
if "$harness_root/harness.sh" validate-state --state "$legacy" --json >"$json_output" 2>&1; then
  echo "public validate-state accepted legacy current.md" >&2
  exit 1
fi

echo "Current-state validator regression passed."
