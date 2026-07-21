#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

verification_mode="$(fm_value "$PLAN_PATH" "verification_mode")"
testing_required="$(fm_value "$PLAN_PATH" "testing_required")"
testing_skip_reason="$(fm_value "$PLAN_PATH" "testing_skip_reason")"
rows="$(required_check_rows "$PLAN_PATH")"

case "$verification_mode" in
  none|required_checks) ;;
  *) fail "Invalid verification_mode '$verification_mode'" ;;
esac

case "$testing_required" in
  true|false) ;;
  *) fail "testing_required must be true or false" ;;
esac

if [ "$verification_mode" = "none" ]; then
  [ "$testing_required" = "false" ] || fail "verification_mode=none requires testing_required=false"
  [ -n "$testing_skip_reason" ] && [ "$testing_skip_reason" != "null" ] || fail "verification_mode=none requires testing_skip_reason"
  [ -z "$rows" ] || fail "verification_mode=none requires required_checks to be empty"
  echo "Required check contract passed."
  exit 0
fi

[ -n "$rows" ] || fail "required_checks is empty"
[ "$testing_required" = "true" ] || fail "verification_mode=required_checks requires testing_required=true"

while IFS=$'\t' read -r id type command blocking timeout_seconds evidence allow_raw raw_reason reason; do
  [ -n "$id" ] || continue
  type="${type:-automated}"

  case "$type" in
    setup|automated) ;;
    *) fail "required check '$id' has invalid type '$type' (expected setup|automated)" ;;
  esac

  [ -n "$evidence" ] || fail "required check '$id' missing evidence path"
  [ "$blocking" = "true" ] || [ "$blocking" = "false" ] || fail "required check '$id' has invalid blocking value '$blocking'"

  case "$timeout_seconds" in
    ''|*[!0-9]*)
      fail "required check '$id' missing or invalid timeout_seconds"
      ;;
    *)
      [ "$timeout_seconds" -gt 0 ] || fail "required check '$id' timeout_seconds must be greater than 0"
      ;;
  esac

  if [ "$type" = "setup" ]; then
    [ "$blocking" = "true" ] || fail "setup check '$id' must be blocking"
  fi

  [ -n "$command" ] || fail "$type check '$id' missing command"

  if [[ "$command" != rtk\ * ]]; then
    if [ "$allow_raw" != "true" ] || [ -z "$raw_reason" ]; then
      fail "required check '$id' must use rtk command or set allow_raw_command=true with raw_command_reason"
    fi
  fi
done <<< "$rows"

echo "Required check contract passed."
