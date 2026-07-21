# Context Pack

task_id: 1_create_the_guarded_implementation_task
budget: 5000
packed_at: "2026-07-16 16:40"

## Active Task

- task_id: 1_create_the_guarded_implementation_task
- title: .1: Create the guarded implementation task
- status: VERIFICATION_FAILED
- lifecycle_phase: DIAGNOSE
- lane: normal
- review_required: true
- verification_mode: required_checks
- required_checks: 1

## Selected Context Files

- docs/context/memory-index.json
- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md
- docs/context/conventions.md
- docs/context/runbooks.md
- docs/context/known-errors.md
- docs/context/discussions.md
- docs/evidence/1_create_the_guarded_implementation_task/working-memory.md
- docs/evidence/1_create_the_guarded_implementation_task/localization.md
- docs/evidence/1_create_the_guarded_implementation_task/brownfield-conventions.md
- docs/evidence/1_create_the_guarded_implementation_task/repo-knowledge-selection.md
- docs/evidence/1_create_the_guarded_implementation_task/impact-scan.md
- docs/evidence/1_create_the_guarded_implementation_task/convention-awareness.md
- docs/evidence/1_create_the_guarded_implementation_task/business-rule-awareness.md
- docs/evidence/1_create_the_guarded_implementation_task/regression-scope.md
- docs/evidence/1_create_the_guarded_implementation_task/verification-scope.md
- docs/evidence/1_create_the_guarded_implementation_task/environment-state.md
- docs/evidence/1_create_the_guarded_implementation_task/human-approval.md
- docs/evidence/1_create_the_guarded_implementation_task/adr-review.md
- docs/decisions/adr-index.json
- docs/context/repository-intelligence/README.md
- docs/context/repository-intelligence/repo-profile.yml
- docs/context/repository-intelligence/repo-map.md
- docs/context/repository-intelligence/architecture-map.md
- docs/context/repository-intelligence/module-boundaries.md
- docs/context/repository-intelligence/domain-model.md
- docs/context/repository-intelligence/business-rules.md
- docs/context/repository-intelligence/data-flow.md
- docs/context/repository-intelligence/api-contracts.md
- docs/context/repository-intelligence/database-model.md
- docs/context/repository-intelligence/implementation-patterns.md
- docs/context/repository-intelligence/testing-style.md
- docs/context/repository-intelligence/dependency-map.md
- docs/context/repository-intelligence/dangerous-areas.md
- docs/context/repository-intelligence/legacy-constraints.md
- docs/context/repository-intelligence/knowledge-index.json
- docs/context/repository-intelligence/error-handling-style.md
- docs/context/repository-intelligence/logging-style.md
- docs/context/repository-intelligence/transaction-patterns.md
- docs/context/repository-intelligence/brownfield-observations.md
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/epic.md
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/epic-memory.md
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/integration-contract.md
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/clarifications.md
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/progress.md
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/stories.jsonl
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/stories.jsonl#story:implementation_tasks

## Repo Mode Summary

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true

## Repository Intelligence

# Repo Knowledge Selection

task_id: 1_create_the_guarded_implementation_task
result: pass
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
recorded_at: 2026-07-16 16:40:09 +0700

## Selected Repository Intelligence

- docs/context/repository-intelligence/README.md
- docs/context/repository-intelligence/repo-profile.yml
- docs/context/repository-intelligence/repo-map.md
- docs/context/repository-intelligence/architecture-map.md
- docs/context/repository-intelligence/module-boundaries.md
- docs/context/repository-intelligence/domain-model.md
- docs/context/repository-intelligence/business-rules.md
- docs/context/repository-intelligence/data-flow.md
- docs/context/repository-intelligence/api-contracts.md
- docs/context/repository-intelligence/database-model.md
- docs/context/repository-intelligence/implementation-patterns.md
- docs/context/repository-intelligence/testing-style.md
- docs/context/repository-intelligence/dependency-map.md
- docs/context/repository-intelligence/dangerous-areas.md
- docs/context/repository-intelligence/legacy-constraints.md
- docs/context/repository-intelligence/knowledge-index.json
- docs/context/repository-intelligence/error-handling-style.md
- docs/context/repository-intelligence/logging-style.md
- docs/context/repository-intelligence/transaction-patterns.md
- docs/context/repository-intelligence/brownfield-observations.md

## Impact Scan

# Impact Scan

task_id: 1_create_the_guarded_implementation_task
result: pass
repo_mode: brownfield
task_change_type: extend_existing
recorded_at: 2026-07-16 16:40:09 +0700

## Impacted Areas

- scripts/check-active-plan-contract.sh
- scripts/approve-plan.sh
- scripts/check-context-pack.sh
- scripts/check-work-alignment.sh
- scripts/context.sh
- scripts/harness.sh
- scripts/task.sh
- docs/exec-plans/TEMPLATE.md
- docs/context/repository-intelligence/**
- docs/evidence/1_create_the_guarded_implementation_task/**
- tests/harness/**

## Convention Awareness

# Convention Awareness

task_id: 1_create_the_guarded_implementation_task
result: pass
recorded_at: 2026-07-16 16:40:09 +0700

## Conventions

- Keep shell scripts in strict mode.
- Use `rtk` for harness commands.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.

## Business Rule Awareness

# Business Rule Awareness

task_id: 1_create_the_guarded_implementation_task
result: pass
recorded_at: 2026-07-16 16:40:09 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.

## Regression Scope

# Regression Scope

task_id: 1_create_the_guarded_implementation_task
result: pass
recorded_at: 2026-07-16 16:40:09 +0700

## Scope

- harness plan contract tests
- context pack and work alignment tests
- repository intelligence selection tests
- template export regression tests

## Verification Scope

# Verification Scope

task_id: 1_create_the_guarded_implementation_task
result: pass
recorded_at: 2026-07-16 16:40:09 +0700

## Commands

- `rtk ./tests/harness/run_all.sh`
- `rtk ./scripts/verify.sh`
- `rtk ./scripts/finalize-task.sh`

## Environment State

# Environment State

task_id: 1_create_the_guarded_implementation_task
result: pass
recorded_at: 2026-07-16 16:40:09 +0700

## State

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- git_commit: ed416bc84d9ffe998d140243772ecc6e120186c1
- working_tree_status: 44 changed path(s)

## Human Approval

# Human Approval

task_id: 1_create_the_guarded_implementation_task
result: pass
recorded_at: 2026-07-16 16:40:09 +0700

## Approval

The active plan approval is the required human approval for the approved scope.

## Parent Epic Summary

# Epic: Plan: v3 Harness Scope Reconciliation and Completion

## Source Plan

`/Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/intake/2026_07_15_v3_harness_scope_reconciliation_plan.md`

## Goal

Deliver the decomposed implementation plan through one-task-at-a-time execution.

## Non-Goals

Do not place the full epic/story/task tree inside `docs/exec-plans/active/current.md`.

## Acceptance Summary

- The long plan is decomposed into stories and executable tasks.
- Each task has acceptance criteria, approved file scope, and required checks.
- One READY task can be activated into `current.md` without carrying the full roadmap.

## Parent Story Summary

{"id":"implementation_tasks","title":"Implementation tasks","status":"READY","depends_on":[],"acceptance":["All child tasks for Implementation tasks are DONE","Story-level verification passes"],"required_checks":["bash .agent-harness/harness.sh benchmark --no-history"],"notes":"generated from long implementation plan","tasks":["implement_the_missing_one_file_intake_and_specification_lock_con","remove_stale_v2_release_identity_sandbox_network_and_role_author","implement_or_complete_the_one_file_intake_understanding_design_b","add_focused_tests_for_stale_artifact_rejection_lifecycle_transit","update_the_toc_only_in_a_later_implementation_documentation_step","1_create_the_guarded_implementation_task","2_record_the_current_behavior_baseline","1_inventory_the_existing_v3_implementation","2_remove_stale_active_authority_references","3_verify_lifecycle_remediation_recovery_and_finalization","1_define_the_canonical_contract_package","2_preserve_multimodal_and_external_source_provenance","3_keep_human_interaction_at_contract_boundaries","1_repair_automatic_remediation_epochs_only_if_needed","2_repair_automatic_rethink_detection_only_if_needed","1_update_active_toc_sections_after_behavior_is_verified","2_reconcile_supporting_documentation_and_decision_records"]}

## Epic Memory Summary

# Epic Memory

## Stable Decisions

- Long plans are stored in docs/intake/.
- current.md contains one active task only.

## Update

- task_id: 1_inventory_the_existing_v3_implementation
- projection_schema_version: 1
- task_title: .1: Inventory the existing v3 implementation
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: 5f9a68d43b306855b3b31e5f53fd1315a8420cf69ee5424fe23dea708834d98f
- story_registry_hash: 31b4cf8671a77846fb80d671fb70b2cb80b1d457c7165a9c084efe8b736a0fce
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_15_inventory_existing_v3_implementation.md .agent-harness/docs/tasks/1_inventory_the_existing_v3_implementation/implementation-plan.md,.agent-harness/docs/tasks/tasks.jsonl
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-15 21:11

## Update

- task_id: 2_remove_stale_active_authority_references
- projection_schema_version: 1
- task_title: .2: Remove stale active authority references
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: 672064380bbe6556ce8ff5b16a312f29a64d979bc132038e5a5ca1dbff241a6d
- story_registry_hash: 31b4cf8671a77846fb80d671fb70b2cb80b1d457c7165a9c084efe8b736a0fce
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/decisions/authority-model-v3.md .agent-harness/docs/reports/benchmark/latest.json,.agent-harness/docs/reports/benchmark/latest.md .agent-harness/docs/reviews/2026_07_15_remove_stale_active_authority_references.md,.agent-harness/docs/tasks/2_remove_stale_active_authority_references/implementation-plan.md .agent-harness/docs/tasks/tasks.jsonl
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-15 21:15

## Update

- task_id: 3_preserve_harness_owned_verification_and_finalization
- projection_schema_version: 1
- task_title: .3: Preserve harness-owned verification and finalization
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: 59d2b6d41b0ffe788f5fedfcc4726c6c07c6c8e5a24e2db340ebcdc5dc989859
- story_registry_hash: 31b4cf8671a77846fb80d671fb70b2cb80b1d457c7165a9c084efe8b736a0fce
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_15_preserve_harness_owned_verification_and_finalization.md .agent-harness/docs/tasks/3_preserve_harness_owned_verification_and_finalization/implementation-plan.md,.agent-harness/docs/tasks/tasks.jsonl
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-15 21:18

## Update

- task_id: implement_the_missing_one_file_intake_and_specification_lock_con
- projection_schema_version: 1
- task_title: Implement the missing one-file intake and specification-lock control plane.
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: 9ea5ef60110bcbc46dd541cb25d64e07e66445bc00652369f31d5b1ecac7a615
- story_registry_hash: 31b4cf8671a77846fb80d671fb70b2cb80b1d457c7165a9c084efe8b736a0fce
- completed_files: .agent-harness/docs/context/commands.md,.agent-harness/docs/context/repository-intelligence/repo-profile.yml .agent-harness/docs/reports/benchmark/latest.json,.agent-harness/docs/reports/benchmark/latest.md .agent-harness/docs/reviews/2026_07_15_implement_one_file_intake_control_plane.md,.agent-harness/docs/tasks/implement_the_missing_one_file_intake_and_specification_lock_con/implementation-plan.md .agent-harness/docs/tasks/tasks.jsonl,.agent-harness/scripts/check-script-interface.sh .agent-harness/scripts/harness.sh,.agent-harness/scripts/intake-control.sh .agent-harness/tests/harness/test_intake_control_plane.sh,.agent-harness/tests/harness/test_public_cli_compatibility.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-15 21:26

## Update

- task_id: update_the_toc_only_in_a_later_implementation_documentation_step
- projection_schema_version: 1
- task_title: Update the TOC only in a later implementation/documentation step after the
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: 865102a01c9a8adbd09bc3d040da81269a0a7ca5deb154787173eefc84b61712
- story_registry_hash: 31b4cf8671a77846fb80d671fb70b2cb80b1d457c7165a9c084efe8b736a0fce
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_15_update_toc_v3_reconciliation.md .agent-harness/docs/tasks/tasks.jsonl,.agent-harness/docs/tasks/update_the_toc_only_in_a_later_implementation_documentation_step/implementation-plan.md
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-15 21:33

## Update

- task_id: implement_or_complete_the_one_file_intake_understanding_design_b
- projection_schema_version: 1
- task_title: Implement or complete the one-file intake, understanding, design/business
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: d64a9d5845f123a0e80fdff4f0e804d5a2f99c1935ea46ebc47134c33dc8578b
- story_registry_hash: 31b4cf8671a77846fb80d671fb70b2cb80b1d457c7165a9c084efe8b736a0fce
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_15_v3_intake_authority_binding_reconciliation.md .agent-harness/docs/tasks/implement_or_complete_the_one_file_intake_understanding_design_b/implementation-plan.md,.agent-harness/docs/tasks/tasks.jsonl
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-15 21:44

## Update

- task_id: 1_enforce_v3_only_artifact_selection
- projection_schema_version: 1
- task_title: .1: Enforce v3-only artifact selection
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: dea27a905f2542a9e0a0e85c19ae9976e04ac138ee37b18a5602af5f05ec8126
- story_registry_hash: 31b4cf8671a77846fb80d671fb70b2cb80b1d457c7165a9c084efe8b736a0fce
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_16_v3_artifact_selection.md .agent-harness/docs/tasks/1_enforce_v3_only_artifact_selection/implementation-plan.md,.agent-harness/docs/tasks/tasks.jsonl .agent-harness/scripts/task.sh,.agent-harness/tests/harness/test_v3_artifact_selection.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-16 15:55

## Update

- task_id: 2_align_lifecycle_and_recovery_states
- projection_schema_version: 1
- task_title: .2: Align lifecycle and recovery states
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY

## Integration Contract Summary

# Integration Contract

## Execution Contract

Every decomposed task must carry acceptance criteria, approved files/scopes, and required checks.

## Clarification Summary

# Clarifications

## Blocking Questions

None recorded by automated decomposition.

## Selected ADRs

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: Makes state.json the sole v3 lifecycle authority and current.md a generated projection.

## Selected Repo Memory

- id: repo_profile | path: docs/context/repo-profile.md | reason: baseline repo overview
- id: commands | path: docs/context/commands.md | reason: command interface
- id: boundaries | path: docs/context/boundaries.md | reason: file and scope control
- id: conventions | path: docs/context/conventions.md | reason: documentation and evidence conventions
- id: runbooks | path: docs/context/runbooks.md | reason: workflow runbooks
- id: known_errors | path: docs/context/known-errors.md | reason: common failure patterns
- id: discussions | path: docs/context/discussions.md | reason: discussion history

## Localization

# Localization

task_id: 1_create_the_guarded_implementation_task
recorded_at: "2026-07-16 16:40"

## Selected Context

- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md

## Notes

Use local repository context only; keep the selection narrow.

## Brownfield Conventions

# Brownfield Conventions

task_id: 1_create_the_guarded_implementation_task
recorded_at: "2026-07-16 16:40"

## Selected Conventions

- Keep diffs small.
- Preserve existing workflow unless the plan changes it.
- Prefer harness-owned docs and scripts.
- Keep evidence in docs/evidence/<task_id>/.

## Required Checks

- id: task-benchmark | type: automated | command: rtk ./scripts/harness.sh benchmark --no-history --timeout 60 | blocking: true | timeout_seconds: 180 | evidence: docs/evidence/1_create_the_guarded_implementation_task/benchmark.md

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/verification-pass.md
- docs/evidence/*/autonomous-run-report.md
