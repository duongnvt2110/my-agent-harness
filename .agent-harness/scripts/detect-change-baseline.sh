#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage:
  scripts/detect-change-baseline.sh --task <task_id> [--root <dir>]

Detect whether change tracking should use Git or a baseline snapshot.
EOF
}

task_id=""
root="$HARNESS_REPO_ROOT"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --task)
      task_id="${2:-}"
      shift 2
      ;;
    --root)
      root="${2:-}"
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

[ -n "$task_id" ] || fail "Missing --task <task_id>"

dir="$(evidence_dir)"
mkdir -p "$dir"
decision="$dir/baseline-decision.md"
snapshot_path="$dir/baseline-snapshot.json"

if git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_ref="$(git -C "$root" rev-parse HEAD 2>/dev/null || true)"
  git_status="$(git -C "$root" status --porcelain --untracked-files=all)"
  if [ -z "$git_ref" ] || [ -n "$git_status" ]; then
    ./scripts/create-baseline-snapshot.sh \
      --task "$task_id" \
      --root "$root" \
      --snapshot "$snapshot_path" >/dev/null
    {
      echo "# Baseline Decision"
      echo
      echo "task_id: $task_id"
      echo "created_before_execution: true"
      echo "repo_root: $root"
      echo "change_tracking: snapshot"
      echo "git_ref: null"
      echo "snapshot_path: $snapshot_path"
      echo "reason: Git repository is dirty or has no commit at $root."
    } > "$decision"
  else
    {
      echo "# Baseline Decision"
      echo
      echo "task_id: $task_id"
      echo "created_before_execution: true"
      echo "repo_root: $root"
      echo "change_tracking: git"
      echo "git_ref: $git_ref"
      echo "snapshot_path: $snapshot_path"
      echo "reason: Clean Git repository detected at $root."
    } > "$decision"
  fi
else
  ./scripts/create-baseline-snapshot.sh --task "$task_id" --root "$root" --snapshot "$snapshot_path" >/dev/null
  {
    echo "# Baseline Decision"
    echo
    echo "task_id: $task_id"
    echo "created_before_execution: true"
    echo "repo_root: $root"
    echo "change_tracking: snapshot"
    echo "git_ref: null"
    echo "snapshot_path: $snapshot_path"
    echo "reason: Git repository was not detected at $root."
  } > "$decision"
fi

echo "Created change baseline decision: $decision"
