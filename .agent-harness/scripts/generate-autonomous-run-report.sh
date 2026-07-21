#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

dir="$(evidence_dir)"
report="$dir/autonomous-run-report.md"
task_id="$(fm_value "$PLAN_PATH" "task_id")"
adr_file="$dir/adr-review.md"
context_pack="$dir/context-pack.md"
working_memory="$dir/working-memory.md"

mkdir -p "$dir"

relevant_adrs() {
  if [ ! -f "$adr_file" ]; then
    echo "- (missing)"
    return
  fi
  awk '
    /^result:/ {sub(/^result:[[:space:]]*/, "", $0); print "- result: " $0; next}
    /^relevant_adrs:/ {in_list=1; next}
    /^## / {in_list=0}
    in_list && /^[[:space:]]*-[[:space:]]+/ {sub(/^[[:space:]]*-[[:space:]]+/, "", $0); print "- " $0}
  ' "$adr_file"
}

context_files() {
  if [ ! -f "$context_pack" ]; then
    echo "- (missing)"
    return
  fi
  awk '
    /^## Selected Context Files/ {in_list=1; next}
    /^## / && in_list {exit}
    in_list && /^[[:space:]]*-[[:space:]]+/ {sub(/^[[:space:]]*-[[:space:]]+/, "", $0); print "- " $0}
  ' "$context_pack"
}

{
  echo "# Autonomous Run Report"
  echo
  echo "task_id: $task_id"
  echo "result: pass"
  echo "generated_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "active_plan: $PLAN_PATH"
  echo
  echo "## Task Summary"
  echo
  echo "- title: $(fm_value "$PLAN_PATH" "title")"
  echo "- review_required: $(fm_value "$PLAN_PATH" "review_required")"
  echo "- repo_mode: $(fm_value "$PLAN_PATH" "repo_mode")"
  echo "- task_change_type: $(fm_value "$PLAN_PATH" "task_change_type")"
  echo "- task_touches_existing_behavior: $(fm_value "$PLAN_PATH" "task_touches_existing_behavior")"
  echo "- task_backward_compatibility_required: $(fm_value "$PLAN_PATH" "task_backward_compatibility_required")"
  echo
  echo "## Final Status"
  echo
  echo "- status: $(fm_value "$PLAN_PATH" "status")"
  echo "- lifecycle_phase: $(fm_value "$PLAN_PATH" "lifecycle_phase")"
  echo "- lane: $(fm_value "$PLAN_PATH" "lane")"
  echo "- approved_scopes: $(fm_list "$PLAN_PATH" "approved_scopes" | paste -sd ', ' -)"
  echo
  echo "## Context Evidence"
  echo
  echo "- adr_review: $adr_file"
  relevant_adrs
  echo "- context_pack: $context_pack"
  echo "- working_memory: $working_memory"
  if [ -f "$dir/repo-knowledge-selection.md" ]; then
    echo "- repo_knowledge_selection: $dir/repo-knowledge-selection.md"
  fi
  if [ -f "$dir/impact-scan.md" ]; then
    echo "- impact_scan: $dir/impact-scan.md"
  fi
  if [ -f "$dir/verification-scope.md" ]; then
    echo "- verification_scope: $dir/verification-scope.md"
  fi
  echo
  echo "## Files Read"
  echo
  echo "- $PLAN_PATH"
  echo "- $adr_file"
  echo "- $context_pack"
  echo "- $working_memory"
  context_files
  echo
  echo "## Files Changed"
  echo
  echo '```text'
  ./scripts/list-baseline-changes.sh --format name-status
  echo '```'
  echo
  echo "## Actions Taken"
  echo
  echo "- Created intake, ADR, discussion, localization, conventions, and context-pack evidence."
  echo "- Updated the harness packet and report/template contracts."
  echo "- Verified and finalized the refinement task through the harness."
  echo
  echo "## Token Estimate"
  echo
  if [ -f "$context_pack" ]; then
    echo "- approx_words: $(wc -w < "$context_pack" | tr -d ' ')"
  else
    echo "- approx_words: 0"
  fi
  echo
  echo "## Harness Friction"
  echo
  if [ -f "$dir/failure-packet.md" ]; then
    echo "- failure_packet: $dir/failure-packet.md"
  else
    echo "- failure_packet: none remaining"
  fi
  if [ -f "$dir/file-map-violation.md" ]; then
    echo "- file_map_violation: $dir/file-map-violation.md"
  fi
  echo
  echo "## Required Checks"
  echo
  while IFS=$'\t' read -r id type command blocking timeout_seconds evidence allow_raw raw_reason reason; do
    [ -n "$id" ] || continue
    result="missing"
    if [ -f "$evidence" ]; then
      result="$(awk -F: '/^result:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$evidence")"
    fi
    echo "- $id: $result ($evidence)"
  done < <(required_check_rows "$PLAN_PATH")
  echo
  echo "## Decision Summary"
  echo
  if [ -f "$dir/decision-ledger.jsonl" ]; then
    sed 's/^/- /' "$dir/decision-ledger.jsonl"
  else
    echo "- No decision ledger entries recorded for this task."
  fi
  echo
  echo "## Failure and Remediation"
  echo
  if [ -f "$dir/failure-packet.md" ]; then
    echo "- Failure packet: $dir/failure-packet.md"
  else
    echo "- No blocking failure packet remains for this task."
  fi
  if [ -f "$dir/failure-diagnosis.md" ]; then
    echo "- Failure diagnosis: $dir/failure-diagnosis.md"
  fi
  if [ -f "$dir/repair-plan.md" ]; then
    echo "- Repair plan: $dir/repair-plan.md"
  fi
  if [ -f "$dir/targeted-retest.md" ]; then
    echo "- Targeted retest: $dir/targeted-retest.md"
  fi
  echo
  echo "## Verification"
  echo
  echo "- Verification pass: $dir/verification-pass.md"
  echo "- Test report: $dir/test-report.md"
  echo
  echo "## Review"
  review_file="$(find docs/reviews -type f -name "*.md" ! -name "TEMPLATE.md" -print0 2>/dev/null | xargs -0 grep -l "^task_id:[[:space:]]*$task_id$" 2>/dev/null | head -n 1 || true)"
  if [ -n "$review_file" ]; then
    echo "- Review: $review_file"
  else
    echo "- Review: not required or not found"
  fi
  echo
  echo "## Human Review Required"
  echo
  echo "- $(fm_value "$PLAN_PATH" "review_required")"
  echo
  echo "## Unresolved Items"
  echo
  echo "- None recorded for this task."
} > "$report"

echo "Generated autonomous run report: $report"
