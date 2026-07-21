# Context Pack

task_id: v3_core_bootstrap_contract_and_baseline
budget: 5000
packed_at: "2026-07-10 14:19"

## Active Task

- task_id: v3_core_bootstrap_contract_and_baseline
- title: Protect v3-core bootstrap contract and dirty baseline
- status: DRAFT
- lifecycle_phase: PLAN
- lane: high_risk
- review_required: true
- verification_mode: required_checks
- required_checks: 6

## Selected Context Files

- docs/context/memory-index.json
- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md
- docs/context/conventions.md
- docs/context/runbooks.md
- docs/context/known-errors.md
- docs/context/discussions.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/working-memory.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/localization.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/brownfield-conventions.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/repo-knowledge-selection.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/impact-scan.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/convention-awareness.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/business-rule-awareness.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/regression-scope.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/verification-scope.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/environment-state.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/human-approval.md
- docs/evidence/v3_core_bootstrap_contract_and_baseline/adr-review.md
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

## Repo Mode Summary

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true

## Repository Intelligence

# Repo Knowledge Selection

task_id: v3_core_bootstrap_contract_and_baseline
result: pass
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
recorded_at: 2026-07-10 14:19:42 +0700

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

task_id: v3_core_bootstrap_contract_and_baseline
result: pass
repo_mode: brownfield
task_change_type: extend_existing
recorded_at: 2026-07-10 14:19:42 +0700

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
- docs/evidence/v3_core_bootstrap_contract_and_baseline/**
- tests/harness/**

## Convention Awareness

# Convention Awareness

task_id: v3_core_bootstrap_contract_and_baseline
result: pass
recorded_at: 2026-07-10 14:19:42 +0700

## Conventions

- Keep shell scripts in strict mode.
- Use `rtk` for harness commands.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.

## Business Rule Awareness

# Business Rule Awareness

task_id: v3_core_bootstrap_contract_and_baseline
result: pass
recorded_at: 2026-07-10 14:19:42 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.

## Regression Scope

# Regression Scope

task_id: v3_core_bootstrap_contract_and_baseline
result: pass
recorded_at: 2026-07-10 14:19:42 +0700

## Scope

- harness plan contract tests
- context pack and work alignment tests
- repository intelligence selection tests
- template export regression tests

## Verification Scope

# Verification Scope

task_id: v3_core_bootstrap_contract_and_baseline
result: pass
recorded_at: 2026-07-10 14:19:42 +0700

## Commands

- `rtk ./tests/harness/run_all.sh`
- `rtk ./scripts/verify.sh`
- `rtk ./scripts/finalize-task.sh`

## Environment State

# Environment State

task_id: v3_core_bootstrap_contract_and_baseline
result: pass
recorded_at: 2026-07-10 14:19:42 +0700

## State

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- git_commit: ed416bc84d9ffe998d140243772ecc6e120186c1
- working_tree_status: 42 changed path(s)

## Human Approval

# Human Approval

task_id: v3_core_bootstrap_contract_and_baseline
result: pass
recorded_at: 2026-07-10 14:19:42 +0700

## Approval

The active plan approval is the required human approval for the approved scope.

## Parent Epic Summary

No parent epic.

## Parent Story Summary

No parent story.

## Epic Memory Summary

No epic memory.

## Integration Contract Summary

No integration contract.

## Clarification Summary

No clarifications.

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

task_id: v3_core_bootstrap_contract_and_baseline
recorded_at: "2026-07-10 14:19"

## Selected Context

- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md

## Notes

Use local repository context only; keep the selection narrow.

## Brownfield Conventions

# Brownfield Conventions

task_id: v3_core_bootstrap_contract_and_baseline
recorded_at: "2026-07-10 14:19"

## Selected Conventions

- Keep diffs small.
- Preserve existing workflow unless the plan changes it.
- Prefer harness-owned docs and scripts.
- Keep evidence in docs/evidence/<task_id>/.

## Required Checks

- id: dirty-git-baseline | type: automated | command: rtk ./tests/harness/test_dirty_git_baseline_snapshot.sh | blocking: true | timeout_seconds: 180 | evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/dirty-git-baseline.md
- id: baseline-regressions | type: automated | command: rtk ./tests/harness/test_create_baseline_snapshot.sh | blocking: true | timeout_seconds: 180 | evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/baseline-regressions.md
- id: snapshot-file-map | type: automated | command: rtk ./tests/harness/test_check_file_map_snapshot.sh | blocking: true | timeout_seconds: 180 | evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/snapshot-file-map.md
- id: baseline-report-contract | type: automated | command: rtk rg -n 'workflow_version|public_cli|package_shape|known_gaps|release_invariants' docs/reports/vnext-baseline.md docs/TEST_MATRIX.md | blocking: true | timeout_seconds: 180 | evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/baseline-report-contract.md
- id: harness-regression-suite | type: automated | command: rtk ./tests/harness/run_all.sh | blocking: true | timeout_seconds: 900 | evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/harness-regression-suite.md
- id: release-check | type: automated | command: rtk ./scripts/harness.sh release-check | blocking: true | timeout_seconds: 900 | evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/release-check.md

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/verification-pass.md
- docs/evidence/*/autonomous-run-report.md
