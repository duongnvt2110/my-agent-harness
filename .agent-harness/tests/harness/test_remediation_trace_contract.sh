#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
task_id="remediation_trace_contract"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" "docs/evidence/$task_id"' EXIT
mkdir -p "docs/evidence/$task_id"
cat > "$tmp/plan.md" <<'MD'
---
task_id: remediation_trace_contract
---
MD
dir="docs/evidence/$task_id"
for name in failure-packet.md failure-diagnosis.md repair-plan.md targeted-retest.md test-report.md decision-trace.md; do
  printf '# %s\n\ntask_id: %s\n' "$name" "$task_id" > "$dir/$name"
done
cat > "$dir/decision-ledger.jsonl" <<'JSON'
{"task_id":"remediation_trace_contract","recorded_at":"2026-07-15T00:00:00Z","phase":"DIAGNOSE","decision_type":"PATCH_TEST","trigger":"failure","action":"retest","result":"pending","requires_human_review":false,"evidence":"targeted-retest.md","files_affected":["tests/example.sh"]}
JSON
printf '%s\n' '- {"task_id":"remediation_trace_contract","recorded_at":"2026-07-15T00:00:00Z","phase":"DIAGNOSE","decision_type":"PATCH_TEST","trigger":"failure","action":"retest","result":"pending","requires_human_review":false,"evidence":"targeted-retest.md","files_affected":["tests/example.sh"]}' >> "$dir/decision-trace.md"
PLAN_PATH="$tmp/plan.md" "$harness_root/scripts/check-remediation-trace.sh" >/dev/null

sed 's/task_id: remediation_trace_contract/task_id: wrong-task/' "$dir/failure-diagnosis.md" > "$tmp/bad.md"
mv "$tmp/bad.md" "$dir/failure-diagnosis.md"
if PLAN_PATH="$tmp/plan.md" "$harness_root/scripts/check-remediation-trace.sh" >/dev/null 2>&1; then
  echo "mismatched remediation artifact was accepted" >&2
  exit 1
fi
echo "Remediation trace contract regression passed."
