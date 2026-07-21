#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/../.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/evidence"
plan="$tmp/plan.md"
report="$tmp/test-report.md"
evidence="$tmp/evidence/check.md"
cat > "$plan" <<'EOF'
---
task_id: task-1
---
EOF
printf '%s\n' 'result: pass' > "$evidence"
cat > "$report" <<EOF
# Test Report
task_id: task-1
report_schema_version: 1
canonicalization_version: 1
result: pass
required_checks_count: 1
blocking_checks_passed: 1
- id: check-1
  type: automated
  blocking: true
  timeout_seconds: 60
  result: pass
  evidence: $evidence
EOF
scripts/check-test-report.sh "$report" "$plan" | grep -q 'Test report checks passed.'
sed 's/result: pass$/result: fail/' "$report" > "$tmp/bad-report.md"
if scripts/check-test-report.sh "$tmp/bad-report.md" "$plan" >/dev/null 2>&1; then
  echo 'failing report was accepted' >&2
  exit 1
fi
echo 'Test report validation regression passed.'
