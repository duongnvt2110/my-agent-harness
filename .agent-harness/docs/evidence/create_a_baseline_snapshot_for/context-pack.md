# Context Pack

task_id: create_a_baseline_snapshot_for
budget: 5000
packed_at: "2026-07-12 13:37"

## Active Task

- task_id: create_a_baseline_snapshot_for
- title: Create a baseline snapshot for:
- status: IN_PROGRESS
- lifecycle_phase: EXECUTE
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
- docs/evidence/create_a_baseline_snapshot_for/working-memory.md
- docs/evidence/create_a_baseline_snapshot_for/localization.md
- docs/evidence/create_a_baseline_snapshot_for/brownfield-conventions.md
- docs/evidence/create_a_baseline_snapshot_for/repo-knowledge-selection.md
- docs/evidence/create_a_baseline_snapshot_for/impact-scan.md
- docs/evidence/create_a_baseline_snapshot_for/convention-awareness.md
- docs/evidence/create_a_baseline_snapshot_for/business-rule-awareness.md
- docs/evidence/create_a_baseline_snapshot_for/regression-scope.md
- docs/evidence/create_a_baseline_snapshot_for/verification-scope.md
- docs/evidence/create_a_baseline_snapshot_for/environment-state.md
- docs/evidence/create_a_baseline_snapshot_for/human-approval.md
- docs/evidence/create_a_baseline_snapshot_for/adr-review.md
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
- docs/epics/agent_harness_vnext_full_implementation_plan_epic/epic.md
- docs/epics/agent_harness_vnext_full_implementation_plan_epic/epic-memory.md
- docs/epics/agent_harness_vnext_full_implementation_plan_epic/integration-contract.md
- docs/epics/agent_harness_vnext_full_implementation_plan_epic/clarifications.md
- docs/epics/agent_harness_vnext_full_implementation_plan_epic/progress.md
- docs/epics/agent_harness_vnext_full_implementation_plan_epic/stories.jsonl
- docs/epics/agent_harness_vnext_full_implementation_plan_epic/stories.jsonl#story:implementation_tasks

## Repo Mode Summary

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true

## Repository Intelligence

# Repo Knowledge Selection

task_id: create_a_baseline_snapshot_for
result: pass
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
recorded_at: 2026-07-12 13:37:02 +0700

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

task_id: create_a_baseline_snapshot_for
result: pass
repo_mode: brownfield
task_change_type: extend_existing
recorded_at: 2026-07-12 13:37:02 +0700

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
- docs/evidence/create_a_baseline_snapshot_for/**
- tests/harness/**

## Convention Awareness

# Convention Awareness

task_id: create_a_baseline_snapshot_for
result: pass
recorded_at: 2026-07-12 13:37:02 +0700

## Conventions

- Keep shell scripts in strict mode.
- Use `rtk` for harness commands.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.

## Business Rule Awareness

# Business Rule Awareness

task_id: create_a_baseline_snapshot_for
result: pass
recorded_at: 2026-07-12 13:37:02 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.

## Regression Scope

# Regression Scope

task_id: create_a_baseline_snapshot_for
result: pass
recorded_at: 2026-07-12 13:37:02 +0700

## Scope

- harness plan contract tests
- context pack and work alignment tests
- repository intelligence selection tests
- template export regression tests

## Verification Scope

# Verification Scope

task_id: create_a_baseline_snapshot_for
result: pass
recorded_at: 2026-07-12 13:37:02 +0700

## Commands

- `rtk ./tests/harness/run_all.sh`
- `rtk ./scripts/verify.sh`
- `rtk ./scripts/finalize-task.sh`

## Environment State

# Environment State

task_id: create_a_baseline_snapshot_for
result: pass
recorded_at: 2026-07-12 13:37:02 +0700

## State

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- git_commit: ed416bc84d9ffe998d140243772ecc6e120186c1
- working_tree_status: 42 changed path(s)

## Human Approval

# Human Approval

task_id: create_a_baseline_snapshot_for
result: pass
recorded_at: 2026-07-12 13:37:02 +0700

## Approval

The active plan approval is the required human approval for the approved scope.

## Parent Epic Summary

# Epic: Agent Harness vNext — Full Implementation Plan

## Source Plan

`/Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/intake/agent-harness-vnext-full-implementation-plan.md`

## Goal

Deliver the decomposed implementation plan through one-task-at-a-time execution.

## Non-Goals

Do not place the full epic/story/task tree inside `docs/exec-plans/active/current.md`.

## Acceptance Summary

- The long plan is decomposed into stories and executable tasks.
- Each task has acceptance criteria, approved file scope, and required checks.
- One READY task can be activated into `current.md` without carrying the full roadmap.

## Parent Story Summary

{"id":"implementation_tasks","title":"Implementation tasks","status":"READY","depends_on":[],"acceptance":["All child tasks for Implementation tasks are DONE","Story-level verification passes"],"required_checks":["bash .agent-harness/harness.sh benchmark --no-history"],"notes":"generated from long implementation plan","tasks":["benchmark_framework","validate_the_current_state","validate_the_requested_transition","update_the_state_atomically","implement_approved_changes","create_a_baseline_snapshot_for","add_a_migration_adr","schema","validate_verification_pass_evidence","validate_test_report","validate_ac_coverage","validate_independent_verifier_verdict","validate_completion_judge","validate_remediation_history","validate_adr_impact","validate_required_review","validate_final_report","update_story_and_epic_rollups"]}

## Epic Memory Summary

# Epic Memory

## Stable Decisions

- Long plans are stored in docs/intake/.
- current.md contains one active task only.

## Update

- task_id: benchmark_framework
- task_title: benchmark framework;
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/epics/agent_harness_vnext_full_implementation_plan_epic/epic.md .agent-harness/docs/reports/benchmark/latest.json,.agent-harness/docs/reports/benchmark/latest.md .agent-harness/docs/reviews/2026_07_11_benchmark_framework.md,.agent-harness/docs/tasks/benchmark_framework/implementation-plan.md .agent-harness/docs/tasks/tasks.jsonl,.agent-harness/scripts/check-plan-decomposition-semantic.sh .agent-harness/scripts/finalize-task.sh,.agent-harness/scripts/harness.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-11 10:43

## Update

- task_id: benchmark_framework
- task_title: benchmark framework;
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/epics/agent_harness_vnext_full_implementation_plan_epic/epic-memory.md .agent-harness/docs/epics/agent_harness_vnext_full_implementation_plan_epic/epic.md,.agent-harness/docs/epics/agent_harness_vnext_full_implementation_plan_epic/progress.md .agent-harness/docs/reports/benchmark/latest.json,.agent-harness/docs/reports/benchmark/latest.md .agent-harness/docs/reviews/2026_07_11_benchmark_framework.md,.agent-harness/docs/tasks/benchmark_framework/implementation-plan.md .agent-harness/docs/tasks/tasks.jsonl,.agent-harness/scripts/check-plan-decomposition-semantic.sh .agent-harness/scripts/finalize-task.sh,.agent-harness/scripts/harness.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-11 10:43

## Update

- task_id: validate_the_current_state
- task_title: validate the current state;
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_11_validate_the_current_state.md .agent-harness/docs/tasks/tasks.jsonl,.agent-harness/docs/tasks/validate_the_current_state/implementation-plan.md .agent-harness/scripts/harness.sh,.agent-harness/scripts/validate-current-state.sh .agent-harness/scripts/verify.sh,.agent-harness/tests/harness/test_current_state_validator.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-11 11:07

## Update

- task_id: validate_the_current_state
- task_title: validate the current state;
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/epics/agent_harness_vnext_full_implementation_plan_epic/epic-memory.md .agent-harness/docs/epics/agent_harness_vnext_full_implementation_plan_epic/progress.md,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_11_validate_the_current_state.md .agent-harness/docs/tasks/tasks.jsonl,.agent-harness/docs/tasks/validate_the_current_state/implementation-plan.md .agent-harness/scripts/harness.sh,.agent-harness/scripts/validate-current-state.sh .agent-harness/scripts/verify.sh,.agent-harness/tests/harness/test_current_state_validator.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-11 11:07

## Update

- task_id: validate_the_requested_transition
- task_title: validate the requested transition;
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_11_validate_the_requested_transition.md .agent-harness/docs/tasks/tasks.jsonl,.agent-harness/docs/tasks/validate_the_requested_transition/implementation-plan.md .agent-harness/policies/state-transitions.yaml,.agent-harness/scripts/harness-lib.sh .agent-harness/scripts/harness.sh,.agent-harness/scripts/transition-state .agent-harness/tests/harness/test_transition_state_validation.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-11 11:13

## Update

- task_id: validate_the_requested_transition
- task_title: validate the requested transition;
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/epics/agent_harness_vnext_full_implementation_plan_epic/epic-memory.md .agent-harness/docs/epics/agent_harness_vnext_full_implementation_plan_epic/progress.md,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_11_validate_the_requested_transition.md .agent-harness/docs/tasks/tasks.jsonl,.agent-harness/docs/tasks/validate_the_requested_transition/implementation-plan.md .agent-harness/policies/state-transitions.yaml,.agent-harness/scripts/harness-lib.sh .agent-harness/scripts/harness.sh,.agent-harness/scripts/transition-state .agent-harness/tests/harness/test_transition_state_validation.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-11 11:13

## Update

- task_id: update_the_state_atomically
- task_title: update the state atomically;
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_11_update_the_state_atomically.md .agent-harness/docs/tasks/tasks.jsonl,.agent-harness/docs/tasks/update_the_state_atomically/implementation-plan.md .agent-harness/scripts/transition-state,.agent-harness/tests/harness/test_transition_state_validation.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-11 11:17

## Update

- task_id: update_the_state_atomically
- task_title: update the state atomically;
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/epics/agent_harness_vnext_full_implementation_plan_epic/epic-memory.md .agent-harness/docs/epics/agent_harness_vnext_full_implementation_plan_epic/progress.md,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_11_update_the_state_atomically.md .agent-harness/docs/tasks/tasks.jsonl,.agent-harness/docs/tasks/update_the_state_atomically/implementation-plan.md .agent-harness/scripts/transition-state,.agent-harness/tests/harness/test_transition_state_validation.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-11 11:17

## Update

- task_id: implement_approved_changes
- task_title: implement approved changes;
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/reports/benchmark/latest.json .agent-harness/docs/reports/benchmark/latest.md,.agent-harness/docs/reviews/2026_07_11_implement_approved_changes.md .agent-harness/docs/tasks/implement_approved_changes/implementation-plan.md,.agent-harness/docs/tasks/tasks.jsonl .agent-harness/policies/canonicalization-v1.json,.agent-harness/policies/state-schema-v1.json .agent-harness/scripts/check-state-schema.sh,.agent-harness/scripts/harness.sh .agent-harness/scripts/transition-state,.agent-harness/scripts/validate-current-state.sh .agent-harness/tests/harness/test_current_state_validator.sh,.agent-harness/tests/harness/test_transition_state_validation.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-11 11:21

## Update

- task_id: implement_approved_changes
- task_title: implement approved changes;
- story_id: implementation_tasks

## Integration Contract Summary

# Integration Contract

## Execution Contract

Every decomposed task must carry acceptance criteria, approved files/scopes, and required checks.

## Clarification Summary

# Clarifications

## Blocking Questions

None recorded by automated decomposition.

## Selected ADRs

- id: ADR-0001 | path: docs/decisions/0001-define-scratch-harness-lifecycle-terminology.md | status: Accepted | reason: Defines the canonical lifecycle terms for the scratch harness.
- id: ADR-0002 | path: docs/decisions/0002-remove-harness-skill-selection-contract.md | status: Accepted | reason: Removes the live skill-selection contract from the harness.
- id: ADR-0003 | path: docs/decisions/0003-brownfield-agent-ready-execution-harness.md | status: Accepted | reason: Adds repo memory, ADR control, context packs, and structured task evidence.

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

task_id: create_a_baseline_snapshot_for
recorded_at: "2026-07-12 13:37"

## Selected Context

- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md

## Notes

Use local repository context only; keep the selection narrow.

## Brownfield Conventions

# Brownfield Conventions

task_id: create_a_baseline_snapshot_for
recorded_at: "2026-07-12 13:37"

## Selected Conventions

- Keep diffs small.
- Preserve existing workflow unless the plan changes it.
- Prefer harness-owned docs and scripts.
- Keep evidence in docs/evidence/<task_id>/.

## Required Checks

- id: task-benchmark | type: automated | command: rtk ./scripts/harness.sh benchmark --no-history --timeout 60 | blocking: true | timeout_seconds: 180 | evidence: docs/evidence/create_a_baseline_snapshot_for/benchmark.md

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/verification-pass.md
- docs/evidence/*/autonomous-run-report.md
