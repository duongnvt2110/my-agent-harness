#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/../.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
plan="$tmp/plan.md"
report="$tmp/report.md"
cat > "$plan" <<'EOF'
---
task_id: task-1
---
EOF
cat > "$report" <<'EOF'
# Autonomous Run Report
task_id: task-1
result: pass
## Final Status
- status: COMPLETED
- lifecycle_phase: COMPLETED
## Required Checks
- task-check: pass (docs/evidence/task/check.md)
## Verification
- Verification pass: docs/evidence/task/verification-pass.md
- Test report: docs/evidence/task/test-report.md
## Review
- Review: docs/reviews/task.md
## Unresolved Items
- None recorded for this task.
EOF
scripts/check-final-report.sh "$report" "$plan" | grep -q 'Final report checks passed.'
sed 's/- status: COMPLETED/- status: IN_PROGRESS/' "$report" > "$tmp/bad.md"
if scripts/check-final-report.sh "$tmp/bad.md" "$plan" >/dev/null 2>&1; then
  echo 'non-terminal final report was accepted' >&2
  exit 1
fi
echo 'Final report validation regression passed.'
