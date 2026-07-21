# Context Pack

task_id: v4_slice_3_controlled_tool_interface
budget: 5000
packed_at: "2026-07-18 14:06"

## Active Task

- task_id: v4_slice_3_controlled_tool_interface
- title: Implement v4-core Slice 3 controlled tool interface
- status: IN_PROGRESS
- lifecycle_phase: EXECUTE
- lane: tiny
- review_required: false
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
- docs/evidence/v4_slice_3_controlled_tool_interface/working-memory.md
- docs/evidence/v4_slice_3_controlled_tool_interface/localization.md
- docs/evidence/v4_slice_3_controlled_tool_interface/brownfield-conventions.md
- docs/evidence/v4_slice_3_controlled_tool_interface/repo-knowledge-selection.md
- docs/evidence/v4_slice_3_controlled_tool_interface/impact-scan.md
- docs/evidence/v4_slice_3_controlled_tool_interface/convention-awareness.md
- docs/evidence/v4_slice_3_controlled_tool_interface/business-rule-awareness.md
- docs/evidence/v4_slice_3_controlled_tool_interface/regression-scope.md
- docs/evidence/v4_slice_3_controlled_tool_interface/verification-scope.md
- docs/evidence/v4_slice_3_controlled_tool_interface/environment-state.md
- docs/evidence/v4_slice_3_controlled_tool_interface/human-approval.md
- docs/evidence/v4_slice_3_controlled_tool_interface/adr-review.md
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
- docs/epics/agent_harness_v4_detailed_implementation_plan_epic/epic.md
- docs/epics/agent_harness_v4_detailed_implementation_plan_epic/epic-memory.md
- docs/epics/agent_harness_v4_detailed_implementation_plan_epic/integration-contract.md
- docs/epics/agent_harness_v4_detailed_implementation_plan_epic/clarifications.md
- docs/epics/agent_harness_v4_detailed_implementation_plan_epic/progress.md
- docs/epics/agent_harness_v4_detailed_implementation_plan_epic/stories.jsonl
- docs/epics/agent_harness_v4_detailed_implementation_plan_epic/stories.jsonl#story:implementation_tasks

## Repo Mode Summary

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true

## Repository Intelligence

# Repo Knowledge Selection

task_id: v4_slice_3_controlled_tool_interface
result: generated
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
recorded_at: 2026-07-18 14:06:03 +0700

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

task_id: v4_slice_3_controlled_tool_interface
result: generated
repo_mode: brownfield
task_change_type: extend_existing
recorded_at: 2026-07-18 14:06:03 +0700

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
- docs/evidence/v4_slice_3_controlled_tool_interface/**
- tests/harness/**

## Convention Awareness

# Convention Awareness

task_id: v4_slice_3_controlled_tool_interface
result: generated
recorded_at: 2026-07-18 14:06:03 +0700

## Conventions

- Keep shell scripts in strict mode.
- Use the public harness driver; prefer `rtk` when installed and fall back to `bash`.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.

## Business Rule Awareness

# Business Rule Awareness

task_id: v4_slice_3_controlled_tool_interface
result: generated
recorded_at: 2026-07-18 14:06:03 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.

## Regression Scope

# Regression Scope

task_id: v4_slice_3_controlled_tool_interface
result: generated
recorded_at: 2026-07-18 14:06:03 +0700

## Scope

- harness plan contract tests
- context pack and work alignment tests
- repository intelligence selection tests
- template export regression tests

## Verification Scope

# Verification Scope

task_id: v4_slice_3_controlled_tool_interface
result: generated
recorded_at: 2026-07-18 14:06:03 +0700

## Commands

- `rtk ./tests/harness/run_all.sh`
- `rtk ./scripts/verify.sh`
- `rtk ./scripts/finalize-task.sh`

## Environment State

# Environment State

task_id: v4_slice_3_controlled_tool_interface
result: generated
recorded_at: 2026-07-18 14:06:03 +0700

## State

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- git_commit: ed416bc84d9ffe998d140243772ecc6e120186c1
- working_tree_status: 45 changed path(s)

## Human Approval

# Human Approval

task_id: v4_slice_3_controlled_tool_interface
result: generated
recorded_at: 2026-07-18 14:06:03 +0700

## Approval

The active plan approval is the required human approval for the approved scope.

## Parent Epic Summary

# Epic: Agent Harness v4 — Detailed Implementation Plan

## Source Plan

`/Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/intake/agent-harness-v4-detailed-implementation-plan.md`

## Goal

Deliver the decomposed implementation plan through one-task-at-a-time execution.

## Non-Goals

Do not place the full epic/story/task tree inside `docs/exec-plans/active/current.md`.

## Acceptance Summary

- The long plan is decomposed into stories and executable tasks.
- Each task has acceptance criteria, approved file scope, and required checks.
- One READY task can be activated into `current.md` without carrying the full roadmap.

## Parent Story Summary

{"id":"implementation_tasks","title":"Implementation tasks","status":"READY","depends_on":[],"acceptance":["All child tasks for Implementation tasks are DONE","Story-level verification passes"],"required_checks":["bash .agent-harness/harness.sh benchmark --no-history"],"notes":"generated from long implementation plan","tasks":["add_docs_architecture_current_state_md","add_docs_architecture_target_state_md","add_an_adr_defining_the_product_as","add_a_public_cli_contract_fixture_for","add_feature_flags","create_a_clean_checkout_or_worktree_from_the_approved_baseline","benchmark_failures_can_be_classified_by_model_harness_tool_conte","add_repository_fact_claim_schemas_and_verification","implement_context_pack_v2_with_real_token_budgets_and_provenance","remove_arbitrary_run_check_add_the_structured_tool_registry","implement_the_fake_adapter_and_runtime_contract","implement_the_codex_adapter","add_capability_tested_sandbox_mode","create_the_first_genuine_agent_task_benchmark","add_opentelemetry_compatible_traces_and_replay"]}

## Epic Memory Summary

# Epic Memory

## Stable Decisions

- Long plans are stored in docs/intake/.
- current.md contains one active task only.

## Update

- task_id: v4_slice_2_deterministic_context_compiler
- projection_schema_version: 1
- task_title: Implement v4-core Slice 2 deterministic context compiler
- story_id: implementation_tasks
- status: COMPLETED
- epic_status: READY
- verification_result: pass
- task_store_hash: fa3ac29ed50a26d8c7cf8ad218be7633b60140388dbf977f4f8f935c2ba36a4e
- story_registry_hash: c9531e568478d2a3e2bdc7b1a94155c0d3213758e1b75ace39e0c09e50f418b0
- completed_files: .agent-harness/docs/context/repository-intelligence/repo-profile.yml,.agent-harness/docs/context/repository-intelligence/repository-inventory.json .agent-harness/docs/tasks/tasks.jsonl,.agent-harness/docs/tasks/v4_slice_2_deterministic_context_compiler/implementation-plan.md .agent-harness/scripts/check-context-budget.sh,.agent-harness/scripts/check-context-pack.sh .agent-harness/scripts/context.sh,.agent-harness/tests/harness/test_v4_slice_2_context_compiler.sh
- summary: Completed harness review hardening and re-verification.
- recorded_at: 2026-07-18 14:02

## Integration Contract Summary

# Integration Contract

## Execution Contract

Every decomposed task must carry acceptance criteria, approved files/scopes, and required checks.

## Clarification Summary

# Clarifications

## Blocking Questions

None recorded by automated decomposition.

## Selected ADRs

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | hash: b6cde0431dbce0fc497e3aa9eb4945e613a64752d37bbf0ed85380418c2974b5 | status: Accepted | reason: Makes state.json the sole v3 lifecycle authority and current.md a generated projection.

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

task_id: v4_slice_3_controlled_tool_interface
recorded_at: "2026-07-18 14:06"

## Selected Context

- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md

## Notes

Use local repository context only; keep the selection narrow.

## Brownfield Conventions

# Brownfield Conventions

task_id: v4_slice_3_controlled_tool_interface
recorded_at: "2026-07-18 14:06"

## Selected Conventions

- Keep diffs small.
- Preserve existing workflow unless the plan changes it.
- Prefer harness-owned docs and scripts.
- Keep evidence in docs/evidence/<task_id>/.

## Required Checks

- id: slice-3-tool-interface-test | type: automated | command: ./tests/harness/test_v4_slice_3_tool_interface.sh | blocking: true | timeout_seconds: 180 | evidence: docs/evidence/v4_slice_3_controlled_tool_interface/plan-check.md

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/verification-pass.md
- docs/evidence/*/autonomous-run-report.md
