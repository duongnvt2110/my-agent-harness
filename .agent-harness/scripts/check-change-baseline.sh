#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage:
  scripts/check-change-baseline.sh [--task <task_id>]

Validate that a usable change baseline exists for the active task.
EOF
}

task_id=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --task)
      task_id="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[ -n "$task_id" ] || task_id="$(fm_value "$PLAN_PATH" "task_id")"
dir="$(evidence_dir)"
decision="$dir/baseline-decision.md"
[ -f "$decision" ] || fail "Missing baseline decision evidence: $decision"

change_tracking="$(awk -F: '/^change_tracking:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
created_before_execution="$(awk -F: '/^created_before_execution:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"

case "$change_tracking" in
  git|snapshot) ;;
  *) fail "Invalid change_tracking in baseline decision: $change_tracking" ;;
esac

[ "$created_before_execution" = "true" ] || fail "Change baseline must be created before execution"

case "$change_tracking" in
  git)
    git_ref="$(awk -F: '/^git_ref:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
    repo_root="$(awk -F: '/^repo_root:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
    [ -n "$git_ref" ] && [ "$git_ref" != "null" ] || fail "Git baseline decision missing git_ref"
    [ -n "$repo_root" ] && [ "$repo_root" != "null" ] || repo_root="."
    git -C "$repo_root" rev-parse --verify "$git_ref" >/dev/null 2>&1 || fail "Git ref is invalid in baseline decision: $git_ref"
    ;;
  snapshot)
    snapshot_path="$(awk -F: '/^snapshot_path:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$decision")"
    [ -n "$snapshot_path" ] && [ "$snapshot_path" != "null" ] || fail "Snapshot baseline decision missing snapshot_path"
    ./scripts/check-baseline-snapshot.sh --task "$task_id" --snapshot "$snapshot_path" >/dev/null
    ;;
esac

echo "Change baseline checks passed."
