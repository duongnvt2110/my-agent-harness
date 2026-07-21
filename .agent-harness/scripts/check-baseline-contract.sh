#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

template="docs/exec-plans/TEMPLATE.md"
[ -f "$template" ] || fail "Missing plan template: $template"

grep -q 'change_tracking: null # git | snapshot' "$template" || fail "Template missing reduced change_tracking baseline contract"
grep -q 'behavior_tracking: null # existing_tests | characterization | approval_snapshot | none' "$template" || fail "Template missing reduced behavior_tracking baseline contract"
grep -q 'git_ref: null' "$template" || fail "Template missing git_ref baseline field"
grep -q 'snapshot_path: docs/evidence/__TASK_ID__/baseline-snapshot.json' "$template" || fail "Template missing snapshot baseline path"
grep -q 'behavior_baseline_path: docs/evidence/__TASK_ID__/behavior-baseline.md' "$template" || fail "Template missing behavior baseline path"
grep -q 'approval_snapshot_path: docs/evidence/__TASK_ID__/approval-snapshot.md' "$template" || fail "Template missing approval snapshot path"
grep -q 'created_before_execution: false' "$template" || fail "Template missing created_before_execution baseline flag"

dir="$(evidence_dir)"
decision="$dir/baseline-decision.md"
behavior="$dir/behavior-baseline.md"

[ -f "$decision" ] || fail "Missing baseline decision evidence: $decision"
[ -f "$behavior" ] || fail "Missing behavior baseline evidence: $behavior"

change_tracking="$(awk -F: '/^change_tracking:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
created_before_execution="$(awk -F: '/^created_before_execution:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"

case "$change_tracking" in
  git|snapshot) ;;
  *) fail "Invalid change_tracking in baseline decision: $change_tracking" ;;
esac

[ "$created_before_execution" = "true" ] || fail "Baseline decision must be created before execution"

if [ "$change_tracking" = "git" ]; then
  git_ref="$(awk -F: '/^git_ref:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
  repo_root="$(awk -F: '/^repo_root:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
  [ -n "$git_ref" ] && [ "$git_ref" != "null" ] || fail "Git baseline decision missing git_ref"
  [ -n "$repo_root" ] && [ "$repo_root" != "null" ] || repo_root="."
  git -C "$repo_root" rev-parse --verify "$git_ref" >/dev/null 2>&1 || fail "Git ref is invalid in baseline decision: $git_ref"
else
  snapshot_path="$(awk -F: '/^snapshot_path:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
  [ -n "$snapshot_path" ] && [ "$snapshot_path" != "null" ] || fail "Snapshot baseline decision missing snapshot_path"
  ./scripts/check-baseline-snapshot.sh --task "$(fm_value "$PLAN_PATH" "task_id")" --snapshot "$snapshot_path" >/dev/null
fi

behavior_tracking="$(awk -F: '/^behavior_tracking:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$behavior")"
case "$behavior_tracking" in
  none|existing_tests|characterization|approval_snapshot) ;;
  *) fail "Invalid behavior_tracking in behavior baseline: $behavior_tracking" ;;
esac

echo "Baseline contract checks passed."
