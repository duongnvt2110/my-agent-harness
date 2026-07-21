#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/../.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

printf '%s\n' '{"id":"legacy","title":"Legacy","status":"READY","depends_on":[],"acceptance_criteria":["Implement the task"]}' > "$tmp/v2.jsonl"
if scripts/check-task-schema.sh "$tmp/v2.jsonl" --mode v2 >/dev/null 2>&1; then
  echo 'legacy v2 task schema was accepted' >&2
  exit 1
fi
if scripts/check-task-schema.sh "$tmp/v2.jsonl" >/dev/null 2>&1; then
  echo 'legacy task input was accepted by the v3 validator' >&2
  exit 1
fi

spec_hash="$(printf 'locked-spec' | shasum -a 256 | awk '{print $1}')"
cat > "$tmp/v3.json" <<EOF
{"schema_version":1,"canonicalization_version":1,"id":"task-1","title":"Behavior task","goal":"Produce a verified outcome","depends_on":[],"acceptance_criteria":[{"id":"AC-001","given":"input exists","when":"command runs","then":"output is recorded","evidence_class":"deterministic_test","producer":"runner","evaluator":"Verifier","aggregation_rule":"all","freshness":{"run_id":"run-1"},"pass_conditions":["exit 0"]}],"approved_scopes":["harness_core"],"approved_files":[],"approved_deletions":[],"verification_checks":[{"id":"check-1","command":"true","covers":["AC-001"]}],"risk":"normal","source_spec_hash":"$spec_hash"}
EOF
scripts/check-task-schema.sh "$tmp/v3.json" | grep -q 'valid: true'

if sed 's/"source_spec_hash":"[0-9a-f]*"/"source_spec_hash":"bad"/' "$tmp/v3.json" > "$tmp/invalid.json" && scripts/check-task-schema.sh "$tmp/invalid.json" >/dev/null 2>&1; then
  echo 'invalid v3 task schema was accepted' >&2
  exit 1
fi
echo 'Task schema regression passed.'
