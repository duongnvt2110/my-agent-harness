---
task_id: remove_v2_migration_authority
title: "Remove the v2 migration authority path"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: tiny
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 2
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-15 17:14"
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
  - app_tests
approved_files: 
  - scripts/harness.sh
  - scripts/release-invariants.sh
  - policies/release-fixtures-v1.json
  - scripts/migrate-v2-v3.sh
  - tests/harness/test_v2_v3_migration.sh
  - tests/harness/test_v3_legacy_rejection.sh
  - docs/context/repository-intelligence/repo-profile.yml
  - docs/tasks/tasks.jsonl
approved_deletions: 
  - scripts/migrate-v2-v3.sh
  - tests/harness/test_v2_v3_migration.sh
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
spec_clarification_evidence: docs/evidence/remove_v2_migration_authority/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/remove_v2_migration_authority/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/remove_v2_migration_authority/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/remove_v2_migration_authority/context-pack.md
working_memory_path: docs/evidence/remove_v2_migration_authority/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
source_plan_path: null
implementation_plan_path: docs/tasks/remove_v2_migration_authority/implementation-plan.md
acceptance_criteria: 
  - The public v3 harness exposes no v2 migration command or migration authority path.
  - Release invariants no longer require a v2 migration fixture, and a focused regression proves legacy migration input is rejected by the v3 surface.
  - The v3 dispatcher remains fail-closed for legacy or mixed workflow metadata.
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: legacy-rejection-test
    type: automated
    command: rtk bash tests/harness/test_v3_legacy_rejection.sh
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: docs/evidence/remove_v2_migration_authority/legacy-rejection-test.md
completed_at: "2026-07-15 17:17"
---

# Active Task: Remove the v2 migration authority path

## Goal

Remove the v2 migration authority path

## Parent References

- epic_id: `none`
- story_id: `none`
- source_plan_path: `none`
- implementation_plan_path: `docs/tasks/remove_v2_migration_authority/implementation-plan.md`

## Scope

### Approved Scopes

- harness_core
- app_tests

### Approved Files

- scripts/harness.sh
- scripts/release-invariants.sh
- policies/release-fixtures-v1.json
- scripts/migrate-v2-v3.sh
- tests/harness/test_v2_v3_migration.sh
- tests/harness/test_v3_legacy_rejection.sh

## Acceptance Criteria

- The public v3 harness exposes no v2 migration command or migration authority path.
- Release invariants no longer require a v2 migration fixture, and a focused regression proves legacy migration input is rejected by the v3 surface.
- The v3 dispatcher remains fail-closed for legacy or mixed workflow metadata.

## Required Checks

- `rtk bash tests/harness/test_v3_legacy_rejection.sh`

## Out of Scope

- Do not place the full epic/story/task tree in this active plan.
- Do not modify files outside approved scopes/files.

## Verification

Run the required checks listed in frontmatter, then run `rtk ./scripts/verify.sh` when implementation is complete.
