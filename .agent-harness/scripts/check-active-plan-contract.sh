#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

required_keys=(
  task_id title status lifecycle_phase lane change_type implementation_target workflow_version
  implementation_allowed clarification_status approved_by approved_at baseline_ref
  file_map_approved review_required evidence_required requires_rollback_plan
  requires_human_approval repo_mode task_change_type task_touches_existing_behavior
  task_backward_compatibility_required approved_scopes approved_deletions
  environment_mode environment_setup_required environment_run_prefix
  verification_mode testing_required testing_skip_reason acceptance_criteria required_checks
  decision_policy_allow_safe_revert decision_policy_allow_test_fix
  decision_policy_allow_source_fix decision_policy_allow_scope_expansion
  decision_policy_allow_dependency_change decision_policy_allow_environment_change
  decision_policy_allow_test_skip decision_policy_allow_timeout_increase
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
repo_mode="$(fm_value "$PLAN_PATH" "repo_mode")"
task_change_type="$(fm_value "$PLAN_PATH" "task_change_type")"
task_touches_existing_behavior="$(fm_value "$PLAN_PATH" "task_touches_existing_behavior")"
task_backward_compatibility_required="$(fm_value "$PLAN_PATH" "task_backward_compatibility_required")"
environment_mode="$(fm_value "$PLAN_PATH" "environment_mode")"
environment_setup_required="$(fm_value "$PLAN_PATH" "environment_setup_required")"
verification_mode="$(fm_value "$PLAN_PATH" "verification_mode")"
testing_required="$(fm_value "$PLAN_PATH" "testing_required")"
testing_skip_reason="$(fm_value "$PLAN_PATH" "testing_skip_reason")"
decision_policy_allow_safe_revert="$(fm_value "$PLAN_PATH" "decision_policy_allow_safe_revert")"
decision_policy_allow_test_fix="$(fm_value "$PLAN_PATH" "decision_policy_allow_test_fix")"
decision_policy_allow_source_fix="$(fm_value "$PLAN_PATH" "decision_policy_allow_source_fix")"
decision_policy_allow_scope_expansion="$(fm_value "$PLAN_PATH" "decision_policy_allow_scope_expansion")"
decision_policy_allow_dependency_change="$(fm_value "$PLAN_PATH" "decision_policy_allow_dependency_change")"
decision_policy_allow_environment_change="$(fm_value "$PLAN_PATH" "decision_policy_allow_environment_change")"
decision_policy_allow_test_skip="$(fm_value "$PLAN_PATH" "decision_policy_allow_test_skip")"
decision_policy_allow_timeout_increase="$(fm_value "$PLAN_PATH" "decision_policy_allow_timeout_increase")"

[[ "$task_id" =~ ^[a-z0-9]+(_[a-z0-9]+)*$ ]] || fail "task_id must be lowercase snake_case: $task_id"

case "$status" in
  DRAFT|BLOCKED|APPROVED|IN_PROGRESS|VERIFICATION_FAILED|VERIFIED|COMPLETED) ;;
  *) fail "Invalid status '$status'" ;;
esac

case "$lifecycle_phase" in
  PLAN|EXECUTE|VERIFY|REVIEW|FINALIZE|BLOCKED|COMPLETED|SCOPE_REMEDIATION|DIAGNOSE|REPAIR_PLAN|PATCH) ;;
  *) fail "Invalid lifecycle_phase '$lifecycle_phase'" ;;
esac

[ "$lifecycle_phase" != "COMPLETED" ] || fail "Active plan cannot use lifecycle_phase=COMPLETED"

case "$lane" in
  tiny|normal|high_risk) ;;
  *) fail "Invalid lane '$lane' (expected tiny|normal|high_risk)" ;;
esac

case "$repo_mode" in
  greenfield|brownfield|hybrid) ;;
  *) fail "Invalid repo_mode '$repo_mode' (expected greenfield|brownfield|hybrid)" ;;
esac

case "$task_change_type" in
  new_module|extend_existing|refactor_existing|bugfix|migration|integration) ;;
  *) fail "Invalid task_change_type '$task_change_type'" ;;
esac

[ "$task_touches_existing_behavior" = "true" ] || [ "$task_touches_existing_behavior" = "false" ] || fail "task_touches_existing_behavior must be true or false"
[ "$task_backward_compatibility_required" = "true" ] || [ "$task_backward_compatibility_required" = "false" ] || fail "task_backward_compatibility_required must be true or false"

case "$clarification_status" in
  CLEAR|BLOCKED|DEFAULTS_APPROVED) ;;
  *) fail "Invalid clarification_status '$clarification_status'" ;;
esac

case "$environment_mode" in
  local|docker_compose) ;;
  *) fail "Invalid environment_mode '$environment_mode' (expected local|docker_compose)" ;;
esac

[ "$environment_setup_required" = "true" ] || [ "$environment_setup_required" = "false" ] || fail "environment_setup_required must be true or false"
[ "$testing_required" = "true" ] || [ "$testing_required" = "false" ] || fail "testing_required must be true or false"

case "$verification_mode" in
  none|required_checks) ;;
  *) fail "Invalid verification_mode '$verification_mode' (expected none|required_checks)" ;;
esac

for policy_value in \
  "$decision_policy_allow_safe_revert" \
  "$decision_policy_allow_test_fix" \
  "$decision_policy_allow_source_fix" \
  "$decision_policy_allow_scope_expansion" \
  "$decision_policy_allow_dependency_change" \
  "$decision_policy_allow_environment_change" \
  "$decision_policy_allow_test_skip" \
  "$decision_policy_allow_timeout_increase"
do
  [ "$policy_value" = "true" ] || [ "$policy_value" = "false" ] || fail "decision policy fields must be true or false"
done

if [ "$verification_mode" = "none" ]; then
  [ "$testing_required" = "false" ] || fail "verification_mode=none requires testing_required=false"
  [ -n "$testing_skip_reason" ] && [ "$testing_skip_reason" != "null" ] || fail "verification_mode=none requires testing_skip_reason"
  [ "$(fm_list_count "$PLAN_PATH" "required_checks")" -eq 0 ] || fail "verification_mode=none requires required_checks to be empty"
else
  [ "$testing_required" = "true" ] || fail "verification_mode=required_checks requires testing_required=true"
  [ -n "$(fm_list "$PLAN_PATH" "acceptance_criteria")" ] || fail "verification_mode=required_checks requires acceptance_criteria"
  [ "$(fm_list_count "$PLAN_PATH" "required_checks")" -gt 0 ] || fail "verification_mode=required_checks requires required_checks"
fi

scope_count="$(fm_list_count "$PLAN_PATH" "approved_scopes")"
[ "$scope_count" -gt 0 ] || fail "approved_scopes must contain at least one entry"

if [ "$implementation_allowed" = "true" ]; then
  [ "$status" = "APPROVED" ] || [ "$status" = "IN_PROGRESS" ] || [ "$status" = "VERIFICATION_FAILED" ] || [ "$status" = "VERIFIED" ] || fail "implementation_allowed=true is invalid with status '$status'"
  [ "$lifecycle_phase" != "PLAN" ] || fail "implementation_allowed=true cannot use lifecycle_phase=PLAN"
  [ "$lifecycle_phase" != "BLOCKED" ] || fail "implementation_allowed=true cannot use lifecycle_phase=BLOCKED"
  [ "$clarification_status" != "BLOCKED" ] || fail "implementation_allowed=true requires non-blocked clarification_status"
  [ "$(fm_list_count "$PLAN_PATH" "blocking_questions")" -eq 0 ] || fail "implementation_allowed=true requires no blocking_questions"
  [ -n "$approved_by" ] && [ "$approved_by" != "null" ] || fail "implementation_allowed=true requires approved_by"
  [ -n "$approved_at" ] && [ "$approved_at" != "null" ] || fail "implementation_allowed=true requires approved_at"
  if [ -z "$baseline_ref" ] || [ "$baseline_ref" = "null" ]; then
    decision_file="$(evidence_dir)/baseline-decision.md"
    [ -f "$decision_file" ] || fail "implementation_allowed=true requires baseline_ref or baseline-decision evidence"
    change_tracking="$(awk -F: '/^change_tracking:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision_file")"
    [ "$change_tracking" = "snapshot" ] || fail "implementation_allowed=true requires baseline_ref or snapshot baseline evidence"
    snapshot_path="$(awk -F: '/^snapshot_path:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision_file")"
    [ -n "$snapshot_path" ] && [ "$snapshot_path" != "null" ] || fail "snapshot baseline evidence missing snapshot_path"
    [ -f "$snapshot_path" ] || fail "snapshot baseline evidence missing file: $snapshot_path"
  fi
  [ "$file_map_approved" = "true" ] || fail "implementation_allowed=true requires file_map_approved=true"
fi

[ "$review_required" = "true" ] || [ "$review_required" = "false" ] || fail "review_required must be true or false"

if [ "$lane" = "normal" ] || [ "$lane" = "high_risk" ]; then
  [ "$review_required" = "true" ] || fail "lane '$lane' requires review_required=true"
fi

if [ "$environment_mode" = "docker_compose" ]; then
  [ "$environment_setup_required" = "true" ] || fail "docker_compose plans require environment_setup_required=true"
fi

if [ "$environment_setup_required" = "true" ]; then
  [ "$environment_mode" = "docker_compose" ] || fail "environment_setup_required=true requires environment_mode=docker_compose"
fi

if [ "$lane" = "high_risk" ]; then
  [ "$requires_rollback_plan" = "true" ] || fail "high_risk lane requires requires_rollback_plan=true"
  [ "$requires_human_approval" = "true" ] || fail "high_risk lane requires requires_human_approval=true"
fi

if [ "$verification_mode" != "none" ]; then
  check_count="$(required_check_rows "$PLAN_PATH" | awk 'END {print NR+0}')"
  [ "$check_count" -gt 0 ] || fail "required_checks must contain at least one entry"
fi

while IFS= read -r scope; do
  [ -n "$scope" ] || continue
  scope_patterns "$scope" >/dev/null || fail "Unknown approved scope '$scope'"
done < <(fm_list "$PLAN_PATH" "approved_scopes")

echo "Active plan contract checks passed."
