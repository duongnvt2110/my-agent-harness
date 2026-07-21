---
task_id: v4_slice_2_deterministic_context_compiler
title: "Implement v4-core Slice 2 deterministic context compiler"
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
approved_at: "2026-07-18 13:58"
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
  - .agent-harness/scripts/context.sh
  - .agent-harness/scripts/check-context-pack.sh
  - .agent-harness/scripts/check-context-budget.sh
  - .agent-harness/tests/harness/test_v4_slice_2_context_compiler.sh
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
parent_epic_id: agent_harness_v4_detailed_implementation_plan_epic
parent_story_id: implementation_tasks
epic_path: docs/epics/agent_harness_v4_detailed_implementation_plan_epic/epic.md
story_registry: docs/epics/agent_harness_v4_detailed_implementation_plan_epic/stories.jsonl
epic_memory: docs/epics/agent_harness_v4_detailed_implementation_plan_epic/epic-memory.md
epic_progress: docs/epics/agent_harness_v4_detailed_implementation_plan_epic/progress.md
integration_contract: docs/epics/agent_harness_v4_detailed_implementation_plan_epic/integration-contract.md
epic_clarifications: docs/epics/agent_harness_v4_detailed_implementation_plan_epic/clarifications.md
epic_context_required: true
spec_clarification_required: false
spec_clarification_evidence: docs/evidence/v4_slice_2_deterministic_context_compiler/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/v4_slice_2_deterministic_context_compiler/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/v4_slice_2_deterministic_context_compiler/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/v4_slice_2_deterministic_context_compiler/context-pack.md
working_memory_path: docs/evidence/v4_slice_2_deterministic_context_compiler/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
source_plan_path: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/intake/agent-harness-v4-detailed-implementation-plan.md
implementation_plan_path: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/tasks/v4_slice_2_deterministic_context_compiler/implementation-plan.md
acceptance_criteria: 
  - Context compilation is deterministic and bounded
  - Context manifest records source hashes, selection and omission reasons, budget, usage, and compiler version
  - Critical requirements are retained under the hard budget
  - Focused regression proves reproducibility and freshness
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: slice-2-context-compiler-test
    type: automated
    command: ./tests/harness/test_v4_slice_2_context_compiler.sh
    allow_raw_command: true
    raw_command_reason: "The executable fixture is run from the harness root through run-in-env; nested rtk path resolution is not reliable."
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: docs/evidence/v4_slice_2_deterministic_context_compiler/plan-check.md
completed_at: "2026-07-18 14:02"
---

# Active Task: Implement v4-core Slice 2 deterministic context compiler

## Goal

Implement v4-core Slice 2 deterministic context compiler

## Parent References

- epic_id: `agent_harness_v4_detailed_implementation_plan_epic`
- story_id: `implementation_tasks`
- source_plan_path: `/Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/intake/agent-harness-v4-detailed-implementation-plan.md`
- implementation_plan_path: `/Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/tasks/v4_slice_2_deterministic_context_compiler/implementation-plan.md`

## Scope

### Approved Scopes

- harness_core
- harness_docs
- app_tests

### Approved Files

- .agent-harness/scripts/context.sh
- .agent-harness/scripts/check-context-pack.sh
- .agent-harness/scripts/check-context-budget.sh
- .agent-harness/tests/harness/test_v4_slice_2_context_compiler.sh

## Acceptance Criteria

- Context compilation is deterministic and bounded
- Context manifest records source hashes, selection and omission reasons, budget, usage, and compiler version
- Critical requirements are retained under the hard budget
- Focused regression proves reproducibility and freshness

## Required Checks

- `./tests/harness/test_v4_slice_2_context_compiler.sh`

## Out of Scope

- Do not place the full epic/story/task tree in this active plan.
- Do not modify files outside approved scopes/files.

## Verification

Run the required checks listed in frontmatter, then run `rtk ./scripts/verify.sh` when implementation is complete.
