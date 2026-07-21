#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'EOF'
Usage:
  scripts/detect-behavior-baseline.sh --task <task_id> [--root <dir>] [--mode <mode>]

Detect how behavior preservation should be tracked.
EOF
}

task_id=""
root="."
forced_mode=""

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
    --mode)
      forced_mode="${2:-}"
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

repo_mode="$(fm_value "$PLAN_PATH" "repo_mode")"
touches_existing_behavior="$(fm_value "$PLAN_PATH" "task_touches_existing_behavior")"
dir="$(evidence_dir)"
mkdir -p "$dir"
file="$dir/behavior-baseline.md"
approval_snapshot="$dir/approval-snapshot.md"

if [ -n "$forced_mode" ]; then
  mode="$forced_mode"
else
  if [ -f "$root/.baseline-behavior-mode" ]; then
    mode="$(tr -d '[:space:]' < "$root/.baseline-behavior-mode")"
  elif [ "$repo_mode" = "greenfield" ] && [ "$touches_existing_behavior" = "false" ]; then
    mode="none"
  elif find "$root" -type f \( -name '*_test.*' -o -name '*.test.*' -o -path '*/tests/*' \) -print -quit 2>/dev/null | grep -q .; then
    mode="existing_tests"
  else
    mode="characterization"
  fi
fi

case "$mode" in
  none|existing_tests)
    ./scripts/create-behavior-baseline.sh --task "$task_id" --mode "$mode" --root "$root" >/dev/null
    ;;
  characterization|approval_snapshot)
    ./scripts/create-behavior-baseline.sh --task "$task_id" --mode "$mode" --root "$root" >/dev/null
    ;;
  *)
    fail "Unsupported behavior tracking mode: $mode"
    ;;
esac

echo "Created behavior baseline: $file"
