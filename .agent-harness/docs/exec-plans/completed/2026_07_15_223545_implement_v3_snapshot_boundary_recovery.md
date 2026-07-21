---
task_id: implement_v3_snapshot_boundary_recovery
title: "Implement snapshot boundary and recovery hardening"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: tiny
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 3
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-15 22:33"
baseline_ref: null
file_map_approved: true
review_required: false
evidence_required: true
requires_rollback_plan: false
requires_human_approval: false
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
approved_scopes: 
  - harness_core
  - harness_docs
  - app_tests
approved_files: 
  - .agent-harness/scripts/**
  - .agent-harness/tests/**
  - .agent-harness/docs/**
  - my_docs/2026_07_16_v3_snapshot_boundary_recovery_update.md
approved_deletions: []
environment_mode: local
environment_setup_required: false
environment_run_prefix: null
environment_compose_file: null
environment_service: null
environment_reason: null
verification_mode: required_checks
testing_required: true
testing_skip_reason: null
parent_epic_id: null
parent_story_id: null
epic_path: null
story_registry: null
epic_memory: null
epic_progress: null
integration_contract: null
epic_clarifications: null
epic_context_required: false
spec_clarification_required: false
spec_clarification_evidence: docs/evidence/implement_v3_snapshot_boundary_recovery/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_v3_snapshot_boundary_recovery/work-alignment.md
adr_check_required: true
adr_index: .agent-harness/docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_v3_snapshot_boundary_recovery/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_v3_snapshot_boundary_recovery/context-pack.md
working_memory_path: docs/evidence/implement_v3_snapshot_boundary_recovery/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
source_plan_path: null
implementation_plan_path: docs/tasks/implement_v3_snapshot_boundary_recovery/implementation-plan.md
acceptance_criteria: 
  - Snapshot directories cannot escape the package parent or use symlinks
  - Atomic snapshot replacement fsyncs the parent directory
  - An actual integrity failure records autonomous remediation or rethink resolution
  - Required checks pass and the original TOC remains unchanged
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: task-benchmark
    type: automated
    command: "rtk env PATH=/Users/exe-macbook/.local/bin:$PATH rtk ./scripts/harness.sh benchmark --no-history --timeout 60"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-002
      - AC-003
      - AC-004
    evidence: docs/evidence/implement_v3_snapshot_boundary_recovery/benchmark.md
completed_at: "2026-07-15 22:35"
---

# Active Task: Implement snapshot boundary and recovery hardening

## Goal

Implement snapshot boundary and recovery hardening

## Parent References

- epic_id: `none`
- story_id: `none`
- source_plan_path: `none`
- implementation_plan_path: `docs/tasks/implement_v3_snapshot_boundary_recovery/implementation-plan.md`

## Scope

### Approved Scopes

- harness_core
- harness_docs
- app_tests

### Approved Files

- .agent-harness/scripts/**
- .agent-harness/tests/**
- .agent-harness/docs/**
- my_docs/2026_07_16_v3_snapshot_boundary_recovery_update.md

## Acceptance Criteria

- Snapshot directories cannot escape the package parent or use symlinks
- Atomic snapshot replacement fsyncs the parent directory
- An actual integrity failure records autonomous remediation or rethink resolution
- Required checks pass and the original TOC remains unchanged

## Required Checks

- `rtk env PATH=/Users/exe-macbook/.local/bin:$PATH rtk ./scripts/harness.sh benchmark --no-history --timeout 60`

## Out of Scope

- Do not place the full epic/story/task tree in this active plan.
- Do not modify files outside approved scopes/files.

## Verification

Run the required checks listed in frontmatter, then run `rtk ./scripts/verify.sh` when implementation is complete.
