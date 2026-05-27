#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

[ -f "$PLAN_PATH" ] || fail "This check requires an existing active plan: $PLAN_PATH"

tmp="$(mktemp)"
set +e
./scripts/create-active-plan.sh should_not_create "Should Not Create" > "$tmp" 2>&1
exit_code=$?
set -e

cat "$tmp"

if [ "$exit_code" -eq 0 ]; then
  rm -f "$tmp"
  fail "create-active-plan.sh succeeded even though an active current.md already exists"
fi

grep -q "Active plan already exists" "$tmp" || {
  rm -f "$tmp"
  fail "create-active-plan.sh did not explain that the active plan already exists"
}

rm -f "$tmp"
echo "create-active-plan.sh denied creating a second active plan."
