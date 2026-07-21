#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

[ -f "$PLAN_PATH" ] || fail "Missing active plan: $PLAN_PATH"

status="$(fm_value "$PLAN_PATH" "status")"
lifecycle_phase="$(fm_value "$PLAN_PATH" "lifecycle_phase")"

[ "$status" = "DRAFT" ] || [ "$status" = "BLOCKED" ] || fail "Plan approval requires status=DRAFT or BLOCKED, got '$status'"
[ "$lifecycle_phase" = "PLAN" ] || [ "$lifecycle_phase" = "BLOCKED" ] || fail "Plan approval requires lifecycle_phase=PLAN or BLOCKED, got '$lifecycle_phase'"

baseline_ref="$(fm_value "$PLAN_PATH" "baseline_ref")"
if [ -z "$baseline_ref" ] || [ "$baseline_ref" = "null" ]; then
  decision_file="$(evidence_dir)/baseline-decision.md"
  if [ -f "$decision_file" ]; then
    change_tracking="$(awk -F: '/^change_tracking:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision_file")"
    case "$change_tracking" in
      git)
        baseline_ref="$(awk -F: '/^git_ref:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision_file")"
        [ -n "$baseline_ref" ] && [ "$baseline_ref" != "null" ] || fail "Git baseline decision missing git_ref"
        set_fm_value "$PLAN_PATH" "baseline_ref" "$baseline_ref"
        ;;
      snapshot)
        :
        ;;
      *)
        fail "Invalid change_tracking in baseline decision: $change_tracking"
        ;;
    esac
  else
    baseline_ref="$(git rev-parse HEAD 2>/dev/null || true)"
    [ -n "$baseline_ref" ] || fail "Cannot resolve baseline_ref from HEAD"
    set_fm_value "$PLAN_PATH" "baseline_ref" "$baseline_ref"
  fi
fi

./scripts/check-active-plan-contract.sh
./scripts/check-plan-decomposition.sh
./scripts/check-plan-decomposition-semantic.sh
./scripts/check-baseline-contract.sh
./scripts/check-change-baseline.sh
./scripts/check-behavior-baseline.sh
./scripts/consume-plan.sh
./scripts/check-spec-clarification.sh --write-evidence
./scripts/create-full-context.sh
./scripts/check-full-context.sh
./scripts/check-work-alignment.sh
if [ -x ./scripts/check-adr-awareness.sh ]; then
  ./scripts/check-adr-awareness.sh
fi
if [ -x ./scripts/check-context-pack.sh ]; then
  ./scripts/check-context-pack.sh
fi
./scripts/check-test-contract.sh

set_fm_value "$PLAN_PATH" "status" "IN_PROGRESS"
set_fm_value "$PLAN_PATH" "lifecycle_phase" "EXECUTE"
set_fm_value "$PLAN_PATH" "implementation_allowed" "true"
set_fm_value "$PLAN_PATH" "file_map_approved" "true"
set_fm_value "$PLAN_PATH" "approved_by" "human"
set_fm_value "$PLAN_PATH" "approved_at" "\"$(date '+%Y-%m-%d %H:%M')\""

task_id="$(fm_value "$PLAN_PATH" "task_id")"
task_title="$(fm_value "$PLAN_PATH" "title")"
./scripts/task.sh mark-in-progress "$task_id" "$task_title"

echo "Approved active plan: $PLAN_PATH"
