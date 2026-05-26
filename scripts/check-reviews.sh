#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

review_dir="docs/reviews"
[ -f "$review_dir/TEMPLATE.md" ] || fail "Missing review template: $review_dir/TEMPLATE.md"

lane="$(fm_value "$PLAN_PATH" "lane")"
review_required="$(fm_value "$PLAN_PATH" "review_required")"

if [ "$lane" = "normal" ] || [ "$lane" = "high_risk" ]; then
  review_required="true"
fi

[ "$review_required" = "true" ] || { echo "Review not required for this plan."; exit 0; }

task_id="$(fm_value "$PLAN_PATH" "task_id")"
review_file="$(find "$review_dir" -type f -name "*.md" ! -name "TEMPLATE.md" -print0 2>/dev/null | \
  xargs -0 grep -l "^task_id:[[:space:]]*$task_id$" 2>/dev/null | head -n 1 || true)"

[ -n "$review_file" ] || fail "Missing review artifact for task_id=$task_id"

p1="$(fm_value "$review_file" "p1_findings")"
[ "$p1" = "0" ] || fail "Review has blocking P1 findings: $review_file"

echo "Review checks passed."

