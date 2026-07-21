---
task_id: 2_extend_change_package_source_manifest
title: ".2: Extend Change Package source manifest"
status: VERIFICATION_FAILED
lifecycle_phase: DIAGNOSE
lane: normal
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 3
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-16 13:32"
baseline_ref: null
file_map_approved: true
review_required: true
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
approved_files: []
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
parent_epic_id: implement_v3_implementation_readiness_and_human_input_coverage_epic
parent_story_id: implementation_tasks
epic_path: docs/epics/implement_v3_implementation_readiness_and_human_input_coverage_epic/epic.md
story_registry: docs/epics/implement_v3_implementation_readiness_and_human_input_coverage_epic/stories.jsonl
epic_memory: docs/epics/implement_v3_implementation_readiness_and_human_input_coverage_epic/epic-memory.md
epic_progress: docs/epics/implement_v3_implementation_readiness_and_human_input_coverage_epic/progress.md
integration_contract: docs/epics/implement_v3_implementation_readiness_and_human_input_coverage_epic/integration-contract.md
epic_clarifications: docs/epics/implement_v3_implementation_readiness_and_human_input_coverage_epic/clarifications.md
epic_context_required: true
spec_clarification_required: false
spec_clarification_evidence: docs/evidence/2_extend_change_package_source_manifest/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/2_extend_change_package_source_manifest/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/2_extend_change_package_source_manifest/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/2_extend_change_package_source_manifest/context-pack.md
working_memory_path: docs/evidence/2_extend_change_package_source_manifest/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
source_plan_path: docs/intake/implementation_readiness/2026_07_16_implementation_readiness_and_human_input_coverage_plan.md
implementation_plan_path: docs/tasks/implementation_readiness/2_extend_change_package_source_manifest/implementation-plan.md
acceptance_criteria: 
  - "Implement: .2: Extend Change Package source manifest"
  - Required checks pass
  - Changes stay inside approved scopes/files
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
    command: rtk ./scripts/harness.sh benchmark --no-history --timeout 60
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: docs/evidence/2_extend_change_package_source_manifest/benchmark.md
completed_at: "2026-07-16 13:40"
---

# Active Task: .2: Extend Change Package source manifest

## Goal

.2: Extend Change Package source manifest

## Parent References

- epic_id: `implement_v3_implementation_readiness_and_human_input_coverage_epic`
- story_id: `implementation_tasks`
- source_plan_path: `docs/intake/implementation_readiness/2026_07_16_implementation_readiness_and_human_input_coverage_plan.md`
- implementation_plan_path: `docs/tasks/implementation_readiness/2_extend_change_package_source_manifest/implementation-plan.md`

## Scope

### Approved Scopes

- harness_core
- harness_docs
- app_tests

### Approved Files

- None

## Acceptance Criteria

- Implement: .2: Extend Change Package source manifest
- Required checks pass
- Changes stay inside approved scopes/files

## Required Checks

- `rtk ./scripts/harness.sh benchmark --no-history --timeout 60`

## Out of Scope

- Do not place the full epic/story/task tree in this active plan.
- Do not modify files outside approved scopes/files.

## Verification

Run the required checks listed in frontmatter, then run `rtk ./scripts/verify.sh` when implementation is complete.
