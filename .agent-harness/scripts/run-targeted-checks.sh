#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

dir="$(evidence_dir)"
repair_plan="$dir/repair-plan.md"
target_report="$dir/targeted-retest.md"

[ -f "$repair_plan" ] || fail "Missing repair plan: $repair_plan"

targeted_retest_command="$(awk -F: '/^targeted_retest_command:[[:space:]]*/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$repair_plan")"
[ -n "$targeted_retest_command" ] || fail "Repair plan missing targeted_retest_command: $repair_plan"

tmp="$(mktemp)"
set +e
bash -lc "$targeted_retest_command" > "$tmp" 2>&1
exit_code=$?
set -e

mkdir -p "$dir"
{
  echo "# Targeted Retest"
  echo
  echo "task_id: $(fm_value "$PLAN_PATH" "task_id")"
  echo "result: $( [ "$exit_code" -eq 0 ] && echo pass || echo fail )"
  echo "exit_code: $exit_code"
  echo "started_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo
  echo "## Command"
  echo
  echo '```text'
  echo "$targeted_retest_command"
  echo '```'
  echo
  echo "## Output"
  echo
  echo '```text'
  cat "$tmp"
  echo '```'
  echo
  echo "## Follow Up"
  echo
  echo "full_verify_command: $(awk -F: '/^full_verify_command:[[:space:]]*/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$repair_plan")"
  echo "lifecycle_phase_before: $(fm_value "$PLAN_PATH" "lifecycle_phase")"
} > "$target_report"
rm -f "$tmp"

if [ "$exit_code" -ne 0 ]; then
  set_fm_value "$PLAN_PATH" "lifecycle_phase" "DIAGNOSE"
  fail "Targeted retest failed: $target_report"
fi

set_fm_value "$PLAN_PATH" "lifecycle_phase" "VERIFY"

echo "Targeted retest passed: $target_report"
