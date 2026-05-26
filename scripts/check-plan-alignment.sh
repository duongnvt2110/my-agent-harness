#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

status="$(fm_value "$PLAN_PATH" "status")"
lifecycle_phase="$(fm_value "$PLAN_PATH" "lifecycle_phase")"
review_required="$(fm_value "$PLAN_PATH" "review_required")"

if [ "$status" = "VERIFIED" ] && [ "$lifecycle_phase" = "EXECUTE" ]; then
  fail "status=VERIFIED conflicts with lifecycle_phase=EXECUTE"
fi

if [ "$lifecycle_phase" = "FINALIZE" ] && [ "$status" != "VERIFIED" ] && [ "$status" != "COMPLETED" ]; then
  fail "lifecycle_phase=FINALIZE requires status=VERIFIED or COMPLETED"
fi

if [ "$review_required" = "true" ] && [ "$status" = "COMPLETED" ]; then
  task_id="$(fm_value "$PLAN_PATH" "task_id")"
  find docs/reviews -type f -name "*.md" ! -name "TEMPLATE.md" -print0 2>/dev/null | \
    xargs -0 grep -l "^task_id:[[:space:]]*$task_id$" >/dev/null 2>&1 || fail "Completed plan requires review artifact for task_id=$task_id"
fi

echo "Plan alignment checks passed."

