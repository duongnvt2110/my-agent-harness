#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

dir="$(evidence_dir)"
report="$dir/test-report.md"
mkdir -p "$dir"

overall="pass"
check_count=0
blocking_passed=0
rows="$(required_check_rows "$PLAN_PATH")"

{
  echo "# Test Report"
  echo
  echo "task_id: $(fm_value "$PLAN_PATH" "task_id")"
  echo "report_schema_version: 1"
  echo "canonicalization_version: 1"
  echo "environment: local"
  echo "generated_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo
  echo "## Checks"
  echo
  while IFS=$'\t' read -r id type command blocking timeout_seconds evidence allow_raw raw_reason reason; do
    [ -n "$id" ] || continue
    check_count=$((check_count + 1))
    result="missing"
    if [ -f "$evidence" ]; then
      result="$(awk -F: '/^result:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$evidence")"
    fi
    normalized_result="$result"
    if [ "$result" = "CLEAR" ] && [[ "$evidence" == *"/spec-clarification.md" ]]; then
      normalized_result="pass"
    fi
    if [ "$blocking" = "true" ] && [ "$normalized_result" != "pass" ]; then
      overall="fail"
    fi
    if [ "$blocking" = "true" ] && [ "$normalized_result" = "pass" ]; then
      blocking_passed=$((blocking_passed + 1))
    fi
    echo "- id: $id"
    echo "  type: ${type:-automated}"
    echo "  blocking: $blocking"
    echo "  timeout_seconds: $timeout_seconds"
    echo "  result: $normalized_result"
    echo "  evidence: $evidence"
  done <<< "$rows"
  echo
  echo "## Reproducibility"
  echo
  echo "Run rtk ./scripts/verify.sh from the repository root."
} > "$report.tmp"

{
  echo "# Test Report"
  echo
  echo "task_id: $(fm_value "$PLAN_PATH" "task_id")"
  echo "result: $overall"
  echo "required_checks_count: $check_count"
  echo "blocking_checks_passed: $blocking_passed"
  tail -n +4 "$report.tmp"
} > "$report"
rm -f "$report.tmp"

[ "$overall" = "pass" ] || fail "Generated failing test report: $report"
echo "Generated test report: $report"
