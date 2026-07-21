# Context Pack

task_id: 3_add_final_coverage_gate_to_verification
budget: 5000
packed_at: "2026-07-16 19:28"

## Active Task

- task_id: 3_add_final_coverage_gate_to_verification
- title: .3: Add final coverage gate to verification
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
- docs/evidence/3_add_final_coverage_gate_to_verification/working-memory.md
- docs/evidence/3_add_final_coverage_gate_to_verification/localization.md
- docs/evidence/3_add_final_coverage_gate_to_verification/brownfield-conventions.md
- docs/evidence/3_add_final_coverage_gate_to_verification/repo-knowledge-selection.md
- docs/evidence/3_add_final_coverage_gate_to_verification/impact-scan.md
- docs/evidence/3_add_final_coverage_gate_to_verification/convention-awareness.md
- docs/evidence/3_add_final_coverage_gate_to_verification/business-rule-awareness.md
- docs/evidence/3_add_final_coverage_gate_to_verification/regression-scope.md
- docs/evidence/3_add_final_coverage_gate_to_verification/verification-scope.md
- docs/evidence/3_add_final_coverage_gate_to_verification/environment-state.md
- docs/evidence/3_add_final_coverage_gate_to_verification/human-approval.md
- docs/evidence/3_add_final_coverage_gate_to_verification/adr-review.md
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
- docs/epics/v3_contract_coverage_and_finalization_hardening_plan_epic/epic.md
- docs/epics/v3_contract_coverage_and_finalization_hardening_plan_epic/epic-memory.md
- docs/epics/v3_contract_coverage_and_finalization_hardening_plan_epic/integration-contract.md
- docs/epics/v3_contract_coverage_and_finalization_hardening_plan_epic/clarifications.md
- docs/epics/v3_contract_coverage_and_finalization_hardening_plan_epic/progress.md
- docs/epics/v3_contract_coverage_and_finalization_hardening_plan_epic/stories.jsonl
- docs/epics/v3_contract_coverage_and_finalization_hardening_plan_epic/stories.jsonl#story:implementation_tasks

## Repo Mode Summary

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true

## Repository Intelligence

# Repo Knowledge Selection

task_id: 3_add_final_coverage_gate_to_verification
result: pass
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
recorded_at: 2026-07-16 19:28:21 +0700

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

task_id: 3_add_final_coverage_gate_to_verification
result: pass
repo_mode: brownfield
task_change_type: extend_existing
recorded_at: 2026-07-16 19:28:21 +0700

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
- docs/evidence/3_add_final_coverage_gate_to_verification/**
- tests/harness/**

## Convention Awareness

# Convention Awareness

task_id: 3_add_final_coverage_gate_to_verification
result: pass
recorded_at: 2026-07-16 19:28:21 +0700

## Conventions

- Keep shell scripts in strict mode.
- Use `rtk` for harness commands.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.

## Business Rule Awareness

# Business Rule Awareness

task_id: 3_add_final_coverage_gate_to_verification
result: pass
recorded_at: 2026-07-16 19:28:21 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.

## Regression Scope

# Regression Scope

task_id: 3_add_final_coverage_gate_to_verification
result: pass
recorded_at: 2026-07-16 19:28:21 +0700

## Scope

- harness plan contract tests
- context pack and work alignment tests
- repository intelligence selection tests
- template export regression tests

## Verification Scope

# Verification Scope

task_id: 3_add_final_coverage_gate_to_verification
result: pass
recorded_at: 2026-07-16 19:28:21 +0700

## Commands

- `rtk ./tests/harness/run_all.sh`
- `rtk ./scripts/verify.sh`
- `rtk ./scripts/finalize-task.sh`

## Environment State

# Environment State

task_id: 3_add_final_coverage_gate_to_verification
result: pass
recorded_at: 2026-07-16 19:28:21 +0700

## State

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- git_commit: ed416bc84d9ffe998d140243772ecc6e120186c1
- working_tree_status: 44 changed path(s)

## Human Approval

# Human Approval

task_id: 3_add_final_coverage_gate_to_verification
result: pass
recorded_at: 2026-07-16 19:28:21 +0700

## Approval

The active plan approval is the required human approval for the approved scope.

## Parent Epic Summary

# Epic: V3 Contract Coverage and Finalization Hardening Plan

## Source Plan

`/Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/intake/2026_07_16_v3_contract_coverage_and_finalization_hardening_plan.md`

## Goal

Deliver the decomposed implementation plan through one-task-at-a-time execution.

## Non-Goals

Do not place the full epic/story/task tree inside `docs/exec-plans/active/current.md`.

## Acceptance Summary

- The long plan is decomposed into stories and executable tasks.
- Each task has acceptance criteria, approved file scope, and required checks.
- One READY task can be activated into `current.md` without carrying the full roadmap.

## Parent Story Summary

{"id":"implementation_tasks","title":"Implementation tasks","status":"READY","depends_on":[],"acceptance":["All child tasks for Implementation tasks are DONE","Story-level verification passes"],"required_checks":["bash .agent-harness/harness.sh benchmark --no-history"],"notes":"generated from long implementation plan","tasks":["1_define_finalization_contract_rules","2_harden_final_human_approval_validation","3_remove_the_direct_completion_bypass","1_add_the_contract_coverage_checker","2_unify_finalization_entry_points","3_add_state_transition_invariants","1_add_coverage_to_generated_context","2_add_adversarial_regression_suite","3_add_final_coverage_gate_to_verification","benchmark_verification_and_harness_finalization_pass"]}

## Epic Memory Summary

# Epic Memory

## Stable Decisions

- Long plans are stored in docs/intake/.
- current.md contains one active task only.

## Update

- task_id: 1_define_finalization_contract_rules
- projection_schema_version: 1
- task_title: .1: Define finalization contract rules
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: 213e92446eb3174bd53e0b5029d4de840a3c76bc18435f01f99ab219d782dddc
- story_registry_hash: 17ade785a177b2e87a5820ff3c164618033362f221f6d6e7aa191393dc6c8b49
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/tasks/1_define_finalization_contract_rules/implementation-plan.md .agent-harness/docs/tasks/tasks.jsonl
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-16 17:30

## Update

- task_id: 2_harden_final_human_approval_validation
- projection_schema_version: 1
- task_title: .2: Harden final human approval validation
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: d1689770c03330c6c7d7e390c1d83dea38e73d53f9ebf134b3959688823ffc51
- story_registry_hash: 17ade785a177b2e87a5820ff3c164618033362f221f6d6e7aa191393dc6c8b49
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/tasks/2_harden_final_human_approval_validation/implementation-plan.md .agent-harness/docs/tasks/tasks.jsonl
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-16 17:32

## Update

- task_id: 3_remove_the_direct_completion_bypass
- projection_schema_version: 1
- task_title: .3: Remove the direct completion bypass
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: b59e08ee0695658e4ea7820563832648504c8a55f466908d68de1005b2cd09e0
- story_registry_hash: 17ade785a177b2e87a5820ff3c164618033362f221f6d6e7aa191393dc6c8b49
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/tasks/3_remove_the_direct_completion_bypass/implementation-plan.md .agent-harness/docs/tasks/tasks.jsonl
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-16 17:35

## Update

- task_id: 1_add_the_contract_coverage_checker
- projection_schema_version: 1
- task_title: .1: Add the contract-coverage checker
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: ef2677a99d421ae2fa3edb806034dc2bc684c37b6c8cab5a86ad9448c9b2608d
- story_registry_hash: 17ade785a177b2e87a5820ff3c164618033362f221f6d6e7aa191393dc6c8b49
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/tasks/1_add_the_contract_coverage_checker/implementation-plan.md .agent-harness/docs/tasks/tasks.jsonl
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-16 17:37

## Update

- task_id: 2_unify_finalization_entry_points
- projection_schema_version: 1
- task_title: .2: Unify finalization entry points
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: dfa810d7da039b44cd483a76e7fa7371da7f22a6cc354667dd71a1b8661eeb1b
- story_registry_hash: 17ade785a177b2e87a5820ff3c164618033362f221f6d6e7aa191393dc6c8b49
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/tasks/2_unify_finalization_entry_points/implementation-plan.md .agent-harness/docs/tasks/tasks.jsonl
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-16 17:40

## Update

- task_id: 3_add_state_transition_invariants
- projection_schema_version: 1
- task_title: .3: Add state-transition invariants
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: a3d378635e68b2989a391af9425b0e52e1c857220c924bd283d18086140be4fb
- story_registry_hash: 17ade785a177b2e87a5820ff3c164618033362f221f6d6e7aa191393dc6c8b49
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/tasks/3_add_state_transition_invariants/implementation-plan.md .agent-harness/docs/tasks/tasks.jsonl
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-16 19:21

## Update

- task_id: 1_add_coverage_to_generated_context
- projection_schema_version: 1
- task_title: .1: Add coverage to generated context
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: 433ad97c3991b1471e051e37f90b586529059af40b46f65f7c42ab743c9f0d63
- story_registry_hash: 17ade785a177b2e87a5820ff3c164618033362f221f6d6e7aa191393dc6c8b49
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/tasks/1_add_coverage_to_generated_context/implementation-plan.md .agent-harness/docs/tasks/tasks.jsonl
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-16 19:24

## Update

- task_id: 2_add_adversarial_regression_suite
- projection_schema_version: 1
- task_title: .2: Add adversarial regression suite
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

task_id: 3_add_final_coverage_gate_to_verification
recorded_at: "2026-07-16 19:28"

## Selected Context

- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md

## Notes

Use local repository context only; keep the selection narrow.

## Brownfield Conventions

# Brownfield Conventions

task_id: 3_add_final_coverage_gate_to_verification
recorded_at: "2026-07-16 19:28"

## Selected Conventions

- Keep diffs small.
- Preserve existing workflow unless the plan changes it.
- Prefer harness-owned docs and scripts.
- Keep evidence in docs/evidence/<task_id>/.

## Required Checks

- id: task-benchmark | type: automated | command: rtk ./scripts/harness.sh benchmark --no-history --timeout 60 | blocking: true | timeout_seconds: 180 | evidence: docs/evidence/3_add_final_coverage_gate_to_verification/benchmark.md

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/verification-pass.md
- docs/evidence/*/autonomous-run-report.md
