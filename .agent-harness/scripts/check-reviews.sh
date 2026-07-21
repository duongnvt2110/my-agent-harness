#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

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

blockers="$(fm_value "$review_file" "blocker_findings")"
blocks_completion="$(fm_value "$review_file" "blocks_completion")"
reviewer="$(fm_value "$review_file" "reviewer")"
review_session="$(fm_value "$review_file" "review_session")"
role_separated="$(fm_value "$review_file" "role_separated")"
model_independent="$(fm_value "$review_file" "model_independent")"
review_result="$(fm_value "$review_file" "result")"
reviewed_at="$(fm_value "$review_file" "reviewed_at")"

[ "$blockers" = "0" ] || fail "Review has blocker findings: $review_file"
[ "$blocks_completion" = "false" ] || fail "Review blocks completion: $review_file"
[ -n "$reviewer" ] && [ "$reviewer" != "null" ] || fail "Review is missing reviewer identity: $review_file"
[ -n "$review_session" ] && [ "$review_session" != "null" ] || fail "Review is missing session identity: $review_file"
[ "$review_result" = "PASS" ] || fail "Review must explicitly declare result: PASS: $review_file"
[ -n "$reviewed_at" ] && [ "$reviewed_at" != "null" ] || fail "Review is missing reviewed_at freshness marker: $review_file"
case "$reviewer" in
  Primary|Verifier|Finalizer|Oracle) fail "Legacy role-named reviewer is not valid v3 authority: $review_file" ;;
esac

echo "Review checks passed."
