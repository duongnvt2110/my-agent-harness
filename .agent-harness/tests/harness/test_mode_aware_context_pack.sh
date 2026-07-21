#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

make_plan() {
  local plan="$1"
  local task_id="$2"
  local mode="$3"
  cat > "$plan" <<EOF
---
task_id: $task_id
title: "Mode aware context pack"
status: APPROVED
lifecycle_phase: EXECUTE
lane: tiny
repo_mode: $mode
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
verification_mode: required_checks
testing_required: true
testing_skip_reason: ""
approved_scopes:
  - harness_core
  - harness_docs
  - app_tests
approved_files: []
approved_deletions: []
review_required: false
implementation_allowed: true
clarification_status: CLEAR
approved_by: codex
approved_at: "2026-06-26 00:00"
baseline_ref: test-baseline
file_map_approved: true
requires_rollback_plan: false
requires_human_approval: false
environment_mode: local
environment_setup_required: false
environment_run_prefix: ""
acceptance_criteria:
  - mode-aware context pack is generated
required_checks:
  - id: plan-check
    type: automated
    command: "rtk ./scripts/harness.sh next"
    blocking: true
    timeout_seconds: 180
    evidence: "docs/evidence/$task_id/plan-check.md"
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
epic_context_required: false
spec_clarification_required: false
parent_epic_id: null
parent_story_id: null
epic_path: null
story_registry: null
epic_memory: null
epic_progress: null
epic_clarifications: null
work_alignment_evidence: docs/evidence/$task_id/work-alignment.md
spec_clarification_evidence: docs/evidence/$task_id/spec-clarification.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/$task_id/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/$task_id/context-pack.md
working_memory_path: docs/evidence/$task_id/working-memory.md
---
EOF
}

assert_mode_context() {
  local mode="$1"
  local expected="$2"
  local task_id="mode_context_${mode}"
  local plan="$tmp/${task_id}.md"

  make_plan "$plan" "$task_id" "$mode"
  PLAN_PATH="$plan" ./scripts/context.sh index >/dev/null
  PLAN_PATH="$plan" ./scripts/context.sh localize --task "$task_id" >/dev/null
  PLAN_PATH="$plan" ./scripts/context.sh conventions --task "$task_id" >/dev/null
  PLAN_PATH="$plan" ./scripts/context.sh pack --task "$task_id" --budget 5000 >/dev/null

  grep -q "^repo_mode: $mode$" "docs/evidence/$task_id/repo-knowledge-selection.md" || {
    echo "Repo knowledge selection did not record $mode mode" >&2
    exit 1
  }
  grep -q "^$expected$" "docs/evidence/$task_id/context-pack.md" || {
    echo "Context pack did not include expected mode-specific docs for $mode" >&2
    exit 1
  }
  if grep -q '"id":' "docs/evidence/$task_id/context-pack.md"; then
    echo "Context pack still dumps raw memory JSON for $mode" >&2
    exit 1
  fi
}

assert_mode_context greenfield "- docs/context/repository-intelligence/greenfield-decisions.md"
assert_mode_context brownfield "- docs/context/repository-intelligence/brownfield-observations.md"
assert_mode_context hybrid "- docs/context/repository-intelligence/greenfield-decisions.md"

echo "Mode-aware context pack regression passed."
