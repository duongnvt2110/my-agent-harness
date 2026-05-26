#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

evidence_required="$(fm_value "$PLAN_PATH" "evidence_required")"
[ "$evidence_required" = "true" ] || { echo "Evidence not required for this plan."; exit 0; }

while IFS=$'\t' read -r id type command blocking evidence allow_raw reason; do
  [ -n "$id" ] || continue
  [ -f "$evidence" ] || fail "Missing evidence for required check '$id': $evidence"
  grep -q "^result:" "$evidence" || fail "Evidence file missing result field: $evidence"
done < <(required_check_rows "$PLAN_PATH")

status="$(fm_value "$PLAN_PATH" "status")"
if [ "$status" = "VERIFIED" ] || [ "$status" = "COMPLETED" ]; then
  pass_file="$(evidence_dir)/verification-pass.md"
  [ -f "$pass_file" ] || fail "Missing verification pass evidence: $pass_file"
fi

echo "Evidence checks passed."

