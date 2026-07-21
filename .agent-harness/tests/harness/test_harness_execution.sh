#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/harness_execution_temp' EXIT

plan="$tmp/current.md"
task_store="$tmp/tasks.jsonl"
task_id="harness_execution_temp"
dir="docs/evidence/$task_id"
report="$dir/harness-execution.md"

cat > "$plan" <<'EOF'
---
task_id: harness_execution_temp
title: "Harness execution temp"
status: APPROVED
lifecycle_phase: EXECUTE
lane: tiny
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
verification_mode: required_checks
testing_required: true
testing_skip_reason: ""
approved_scopes:
  - harness_docs
approved_files:
  - docs/reports/**
approved_deletions: []
review_required: false
implementation_allowed: true
clarification_status: CLEAR
approved_by: codex
approved_at: "2026-06-25 00:00"
baseline_ref: test-baseline
file_map_approved: true
requires_rollback_plan: false
requires_human_approval: false
environment_mode: local
environment_setup_required: false
environment_run_prefix: ""
acceptance_criteria:
  - execution harness checks pass
required_checks:
  - id: plan-check
    type: automated
    command: "./scripts/harness.sh next"
    blocking: true
    timeout_seconds: 180
    evidence: "docs/evidence/harness_execution_temp/plan-check.md"
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
work_alignment_evidence: docs/evidence/harness_execution_temp/work-alignment.md
spec_clarification_evidence: docs/evidence/harness_execution_temp/spec-clarification.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/harness_execution_temp/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/harness_execution_temp/context-pack.md
working_memory_path: docs/evidence/harness_execution_temp/working-memory.md
---
EOF

mkdir -p "$dir"
cat > "$dir/full-context.md" <<'EOF'
# Full Context

Minimal full-context evidence for harness execution regression.
EOF

PLAN_PATH="$plan" TASK_STORE="$task_store" ./scripts/task.sh add "$task_id" "Harness execution temp" >/dev/null

PLAN_PATH="$plan" ./scripts/context.sh index
PLAN_PATH="$plan" ./scripts/context.sh localize --task "$task_id"
PLAN_PATH="$plan" ./scripts/context.sh conventions --task "$task_id"
PLAN_PATH="$plan" ./scripts/context.sh pack --task "$task_id" --budget 5000
PLAN_PATH="$plan" ./scripts/check-spec-clarification.sh --write-evidence
PLAN_PATH="$plan" TASK_STORE="$task_store" ./scripts/consume-plan.sh >/dev/null
TASK_STORE="$task_store" PLAN_PATH="$plan" ./scripts/check-work-alignment.sh
PLAN_PATH="$plan" ./scripts/adr.sh select "$task_id" ADR-0004 --reason "Harness execution regression control-plane context"
PLAN_PATH="$plan" ./scripts/check-adr-awareness.sh
PLAN_PATH="$plan" ./scripts/check-context-pack.sh

{
  echo "# Harness Execution"
  echo
  echo "task_id: $task_id"
  echo "checked_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "result: pass"
  echo
  echo "## Checks"
  echo
  echo "- check-spec-clarification"
  echo "- check-work-alignment"
  echo "- check-adr-awareness"
  echo "- check-context-pack"
} > "$report"

rm -rf "$dir"

echo "Execution harness checks passed."
