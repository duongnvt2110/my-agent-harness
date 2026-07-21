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
title: "Mode aware verification"
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
  - mode-aware verification passes
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

assert_mode_verification() {
  local mode="$1"
  local task_id="mode_verify_${mode}"
  local plan="$tmp/${task_id}.md"
  local dir="docs/evidence/$task_id"

  make_plan "$plan" "$task_id" "$mode"
  rm -rf "$dir"
  mkdir -p "$dir"
  cat > "$dir/full-context.md" <<'EOF'
# Full Context

Minimal full-context evidence for mode-aware verification regression.
EOF
  PLAN_PATH="$plan" ./scripts/context.sh index >/dev/null
  PLAN_PATH="$plan" ./scripts/context.sh localize --task "$task_id" >/dev/null
  PLAN_PATH="$plan" ./scripts/context.sh conventions --task "$task_id" >/dev/null
  PLAN_PATH="$plan" ./scripts/context.sh pack --task "$task_id" --budget 5000 >/dev/null

  TASK_STORE="$tmp/tasks.jsonl" PLAN_PATH="$plan" ./scripts/consume-plan.sh >/dev/null
  TASK_STORE="$tmp/tasks.jsonl" PLAN_PATH="$plan" ./scripts/check-work-alignment.sh >/dev/null
  PLAN_PATH="$plan" ./scripts/check-context-pack.sh >/dev/null
  PLAN_PATH="$plan" ./scripts/check-context-budget.sh >/dev/null

  case "$mode" in
    greenfield)
      grep -q '^- docs/context/repository-intelligence/greenfield-decisions.md$' "docs/evidence/$task_id/context-pack.md" || {
        echo "Greenfield context missing greenfield decisions" >&2
        exit 1
      }
      ;;
    brownfield)
      grep -q '^- docs/context/repository-intelligence/brownfield-observations.md$' "docs/evidence/$task_id/context-pack.md" || {
        echo "Brownfield context missing brownfield observations" >&2
        exit 1
      }
      ;;
    hybrid)
      grep -q '^- docs/context/repository-intelligence/greenfield-decisions.md$' "docs/evidence/$task_id/context-pack.md" || {
        echo "Hybrid context missing greenfield decisions" >&2
        exit 1
      }
      grep -q '^- docs/context/repository-intelligence/brownfield-observations.md$' "docs/evidence/$task_id/context-pack.md" || {
        echo "Hybrid context missing brownfield observations" >&2
        exit 1
      }
      ;;
  esac
}

assert_mode_verification greenfield
assert_mode_verification brownfield
assert_mode_verification hybrid

echo "Mode-aware verification regression passed."
