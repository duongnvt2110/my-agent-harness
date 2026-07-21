#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

evidence_required="$(fm_value "$PLAN_PATH" "evidence_required")"
[ "$evidence_required" = "true" ] || { echo "Evidence not required for this plan."; exit 0; }

while IFS=$'\t' read -r id type command blocking timeout_seconds evidence allow_raw raw_reason reason; do
  [ -n "$id" ] || continue
  type="${type:-automated}"
  [ -f "$evidence" ] || fail "Missing evidence for required check '$id': $evidence"
  grep -q "^result:" "$evidence" || fail "Evidence file missing result field: $evidence"

  result="$(awk -F: '/^result:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$evidence")"
  case "$result" in
    pass|fail|warning|CLEAR) ;;
    *) fail "Evidence file has invalid result '$result': $evidence" ;;
  esac

  if [ "$blocking" = "true" ] && [ "$result" != "pass" ]; then
    if [ "$result" = "CLEAR" ] && [[ "$evidence" == *"/spec-clarification.md" ]]; then
      continue
    fi
    fail "Blocking check '$id' did not pass: $evidence"
  fi
done < <(required_check_rows "$PLAN_PATH")

status="$(fm_value "$PLAN_PATH" "status")"
if [ "$status" = "VERIFIED" ] || [ "$status" = "COMPLETED" ]; then
  pass_file="$(evidence_dir)/verification-pass.md"
  [ -f "$pass_file" ] || fail "Missing verification pass evidence: $pass_file"
  grep -q '^# Verification Pass$' "$pass_file" || fail "Verification pass evidence has an invalid heading: $pass_file"
  pass_task_id="$(awk -F: '/^task_id:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$pass_file")"
  expected_task_id="$(fm_value "$PLAN_PATH" "task_id")"
  [ "$pass_task_id" = "$expected_task_id" ] || fail "Verification pass task binding mismatch: $pass_file"
  grep -q '^result: pass$' "$pass_file" || fail "Verification pass evidence must have result: pass: $pass_file"
  grep -Eq '^verified_at:[[:space:]]+[^[:space:]].*$' "$pass_file" || fail "Verification pass evidence missing verified_at: $pass_file"
  grep -q '^## Gates$' "$pass_file" || fail "Verification pass evidence missing gate section: $pass_file"
  grep -q -- '- required-checks$' "$pass_file" || fail "Verification pass evidence missing required-checks gate: $pass_file"
  grep -q -- '- evidence$' "$pass_file" || fail "Verification pass evidence missing evidence gate: $pass_file"
fi

echo "Evidence checks passed."
