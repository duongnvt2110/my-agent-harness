#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

required_keys=(
  task_id title status lifecycle_phase lane change_type implementation_target workflow_version
  implementation_allowed clarification_status approved_by approved_at baseline_ref
  file_map_approved review_required evidence_required requires_rollback_plan
  requires_human_approval test_matrix_refs approved_scopes approved_deletions
  required_checks
)

for key in "${required_keys[@]}"; do
  fm_has_key "$PLAN_PATH" "$key" || fail "Missing required frontmatter key '$key' in $PLAN_PATH"
done

task_id="$(fm_value "$PLAN_PATH" "task_id")"
status="$(fm_value "$PLAN_PATH" "status")"
lifecycle_phase="$(fm_value "$PLAN_PATH" "lifecycle_phase")"
lane="$(fm_value "$PLAN_PATH" "lane")"
implementation_allowed="$(fm_value "$PLAN_PATH" "implementation_allowed")"
clarification_status="$(fm_value "$PLAN_PATH" "clarification_status")"
approved_by="$(fm_value "$PLAN_PATH" "approved_by")"
approved_at="$(fm_value "$PLAN_PATH" "approved_at")"
baseline_ref="$(fm_value "$PLAN_PATH" "baseline_ref")"
file_map_approved="$(fm_value "$PLAN_PATH" "file_map_approved")"
review_required="$(fm_value "$PLAN_PATH" "review_required")"
requires_rollback_plan="$(fm_value "$PLAN_PATH" "requires_rollback_plan")"
requires_human_approval="$(fm_value "$PLAN_PATH" "requires_human_approval")"

[[ "$task_id" =~ ^[a-z0-9]+(_[a-z0-9]+)*$ ]] || fail "task_id must be lowercase snake_case: $task_id"

case "$status" in
  DRAFT|BLOCKED|APPROVED|IN_PROGRESS|VERIFICATION_FAILED|VERIFIED|COMPLETED) ;;
  *) fail "Invalid status '$status'" ;;
esac

case "$lifecycle_phase" in
  PLAN|EXECUTE|VERIFY|REVIEW|FINALIZE|BLOCKED) ;;
  *) fail "Invalid lifecycle_phase '$lifecycle_phase'" ;;
esac

case "$lane" in
  tiny|normal|high_risk) ;;
  *) fail "Invalid lane '$lane' (expected tiny|normal|high_risk)" ;;
esac

case "$clarification_status" in
  CLEAR|BLOCKED|DEFAULTS_APPROVED) ;;
  *) fail "Invalid clarification_status '$clarification_status'" ;;
esac

scope_count="$(fm_list_count "$PLAN_PATH" "approved_scopes")"
[ "$scope_count" -gt 0 ] || fail "approved_scopes must contain at least one entry"

check_count="$(required_check_rows "$PLAN_PATH" | awk 'END {print NR+0}')"
[ "$check_count" -gt 0 ] || fail "required_checks must contain at least one entry"

if [ "$implementation_allowed" = "true" ]; then
  [ "$status" = "APPROVED" ] || [ "$status" = "IN_PROGRESS" ] || [ "$status" = "VERIFICATION_FAILED" ] || [ "$status" = "VERIFIED" ] || fail "implementation_allowed=true is invalid with status '$status'"
  [ "$lifecycle_phase" != "PLAN" ] || fail "implementation_allowed=true cannot use lifecycle_phase=PLAN"
  [ "$lifecycle_phase" != "BLOCKED" ] || fail "implementation_allowed=true cannot use lifecycle_phase=BLOCKED"
  [ "$clarification_status" != "BLOCKED" ] || fail "implementation_allowed=true requires non-blocked clarification_status"
  [ "$(fm_list_count "$PLAN_PATH" "blocking_questions")" -eq 0 ] || fail "implementation_allowed=true requires no blocking_questions"
  [ -n "$approved_by" ] && [ "$approved_by" != "null" ] || fail "implementation_allowed=true requires approved_by"
  [ -n "$approved_at" ] && [ "$approved_at" != "null" ] || fail "implementation_allowed=true requires approved_at"
  [ -n "$baseline_ref" ] && [ "$baseline_ref" != "null" ] || fail "implementation_allowed=true requires baseline_ref"
  [ "$file_map_approved" = "true" ] || fail "implementation_allowed=true requires file_map_approved=true"
fi

if [ "$lane" = "normal" ] || [ "$lane" = "high_risk" ]; then
  [ "$(fm_list_count "$PLAN_PATH" "test_matrix_refs")" -gt 0 ] || fail "$lane lane requires test_matrix_refs"
  [ "$review_required" = "true" ] || fail "$lane lane requires review_required=true"
fi

if [ "$lane" = "high_risk" ]; then
  [ "$requires_rollback_plan" = "true" ] || fail "high_risk lane requires requires_rollback_plan=true"
  [ "$requires_human_approval" = "true" ] || fail "high_risk lane requires requires_human_approval=true"
fi

while IFS= read -r scope; do
  [ -n "$scope" ] || continue
  scope_patterns "$scope" >/dev/null || fail "Unknown approved scope '$scope'"
done < <(fm_list "$PLAN_PATH" "approved_scopes")

echo "Active plan contract checks passed."
