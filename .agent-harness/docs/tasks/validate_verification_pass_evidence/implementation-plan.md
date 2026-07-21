---
task_id: validate_verification_pass_evidence
title: "Validate verification-pass evidence."
status: COMPLETED
lifecycle_phase: COMPLETED
lane: normal
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 2
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-12 09:49"
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
parent_epic_id: agent_harness_vnext_full_implementation_plan_epic
parent_story_id: implementation_tasks
epic_path: docs/epics/agent_harness_vnext_full_implementation_plan_epic/epic.md
story_registry: docs/epics/agent_harness_vnext_full_implementation_plan_epic/stories.jsonl
epic_memory: docs/epics/agent_harness_vnext_full_implementation_plan_epic/epic-memory.md
epic_progress: docs/epics/agent_harness_vnext_full_implementation_plan_epic/progress.md
integration_contract: docs/epics/agent_harness_vnext_full_implementation_plan_epic/integration-contract.md
epic_clarifications: docs/epics/agent_harness_vnext_full_implementation_plan_epic/clarifications.md
epic_context_required: true
spec_clarification_required: false
spec_clarification_evidence: docs/evidence/validate_verification_pass_evidence/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/validate_verification_pass_evidence/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/validate_verification_pass_evidence/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/validate_verification_pass_evidence/context-pack.md
working_memory_path: docs/evidence/validate_verification_pass_evidence/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
source_plan_path: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/intake/agent-harness-vnext-full-implementation-plan.md
implementation_plan_path: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/tasks/validate_verification_pass_evidence/implementation-plan.md
acceptance_criteria: 
  - "Implement: Validate verification-pass evidence."
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
    evidence: docs/evidence/validate_verification_pass_evidence/benchmark.md
completed_at: "2026-07-12 10:53"
---

# Active Task: Validate verification-pass evidence.

## Goal

Validate verification-pass evidence.

## Parent References

- epic_id: `agent_harness_vnext_full_implementation_plan_epic`
- story_id: `implementation_tasks`
- source_plan_path: `/Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/intake/agent-harness-vnext-full-implementation-plan.md`
- implementation_plan_path: `/Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/tasks/validate_verification_pass_evidence/implementation-plan.md`

## Scope

### Approved Scopes

- harness_core
- harness_docs
- app_tests

### Approved Files

- None

## Acceptance Criteria

- Implement: Validate verification-pass evidence.
- Required checks pass
- Changes stay inside approved scopes/files

## Required Checks

- `rtk ./scripts/harness.sh benchmark --no-history --timeout 60`

## Out of Scope

- Do not place the full epic/story/task tree in this active plan.
- Do not modify files outside approved scopes/files.

## Verification

Run the required checks listed in frontmatter, then run `rtk ./scripts/verify.sh` when implementation is complete.
