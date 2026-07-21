#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

[ "$#" -gt 0 ] || fail "Usage: $0 <command> [args...]"

mode="$(fm_value "$PLAN_PATH" "environment_mode")"
run_prefix="$(fm_value "$PLAN_PATH" "environment_run_prefix")"

case "$mode" in
  local)
    "$@"
    ;;
  docker_compose)
    [ -n "$run_prefix" ] || fail "docker_compose mode requires environment_run_prefix"
    bash -lc "$run_prefix $(printf '%q ' "$@")"
    ;;
  *)
    fail "Invalid environment_mode '$mode' (expected local|docker_compose)"
    ;;
esac
