#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

dir="$(evidence_dir)"
diagnosis="$dir/failure-diagnosis.md"
repair_plan="$dir/repair-plan.md"
repair_plans_dir="$dir/repair-plans"

[ -f "$diagnosis" ] || fail "Missing failure diagnosis: $diagnosis"

mkdir -p "$repair_plans_dir"
attempt_number="$(find "$repair_plans_dir" -maxdepth 1 -type f -name 'attempt-*.md' | wc -l | awk '{print $1 + 1}')"
attempt="$(printf '%03d' "$attempt_number")"
attempt_file="$repair_plans_dir/attempt-$attempt.md"

target_files=(
  "docs/exec-plans/active/current.md"
)

{
  echo "# Repair Plan"
  echo
  echo "task_id: $(fm_value "$PLAN_PATH" "task_id")"
  echo "result: planned"
  echo "attempt: $attempt_number"
  echo "patch_type: scope_remediation"
  echo "targeted_retest_command: rtk ./scripts/check-file-map.sh"
  echo "full_verify_command: rtk ./scripts/verify.sh"
  echo "requires_human_review: false"
  echo "planned_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "source: $diagnosis"
  echo
  echo "## Approved Scope"
  echo
  echo "Approved scopes:"
  fm_list "$PLAN_PATH" "approved_scopes" | sed 's/^/- /'
  echo
  echo "Approved file exceptions:"
  fm_list "$PLAN_PATH" "approved_files" | sed 's/^/- /'
  echo
  echo "## Target Files"
  echo
  printf '%s\n' "${target_files[@]}" | sed 's/^/- /'
  echo
  echo "## Repair Steps"
  echo
  echo "1. Keep the active plan aligned to the preserved workspace state."
  echo "2. Run the targeted retest command from this repair plan."
  echo "3. Run the full verification command after the targeted retest passes."
} > "$repair_plan"

cp "$repair_plan" "$attempt_file"

echo "Wrote repair plan: $repair_plan"
