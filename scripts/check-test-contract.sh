#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

rows="$(required_check_rows "$PLAN_PATH")"
[ -n "$rows" ] || fail "required_checks is empty"

while IFS=$'\t' read -r id type command blocking evidence allow_raw reason; do
  [ -n "$id" ] || fail "required check missing id"
  [ -n "$command" ] || fail "required check '$id' missing command"
  [ -n "$evidence" ] || fail "required check '$id' missing evidence path"
  [ "$blocking" = "true" ] || [ "$blocking" = "false" ] || fail "required check '$id' has invalid blocking value '$blocking'"

  if [[ "$command" != rtk\ * ]]; then
    if [ "$allow_raw" != "true" ] || [ -z "$reason" ]; then
      fail "required check '$id' must use rtk command or set allow_raw_command=true with raw_command_reason"
    fi
  fi

  if [ "$blocking" = "true" ] && [ -z "$command" ]; then
    fail "blocking required check '$id' must define command"
  fi
done <<< "$rows"

echo "Required check contract passed."

