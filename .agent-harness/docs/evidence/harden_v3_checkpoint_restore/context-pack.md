# Context Pack

task_id: harden_v3_checkpoint_restore
budget: 5000
packed_at: "2026-07-15 17:27"

## Active Task

- task_id: harden_v3_checkpoint_restore
- title: Harden v3 checkpoint verification and restore
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
- docs/evidence/harden_v3_checkpoint_restore/working-memory.md
- docs/evidence/harden_v3_checkpoint_restore/localization.md
- docs/evidence/harden_v3_checkpoint_restore/brownfield-conventions.md
- docs/evidence/harden_v3_checkpoint_restore/repo-knowledge-selection.md
- docs/evidence/harden_v3_checkpoint_restore/impact-scan.md
- docs/evidence/harden_v3_checkpoint_restore/convention-awareness.md
- docs/evidence/harden_v3_checkpoint_restore/business-rule-awareness.md
- docs/evidence/harden_v3_checkpoint_restore/regression-scope.md
- docs/evidence/harden_v3_checkpoint_restore/verification-scope.md
- docs/evidence/harden_v3_checkpoint_restore/environment-state.md
- docs/evidence/harden_v3_checkpoint_restore/human-approval.md
- docs/evidence/harden_v3_checkpoint_restore/adr-review.md
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

task_id: harden_v3_checkpoint_restore
result: pass
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
recorded_at: 2026-07-15 17:27:37 +0700

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

task_id: harden_v3_checkpoint_restore
result: pass
repo_mode: brownfield
task_change_type: extend_existing
recorded_at: 2026-07-15 17:27:37 +0700

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
- docs/evidence/harden_v3_checkpoint_restore/**
- tests/harness/**

## Convention Awareness

# Convention Awareness

task_id: harden_v3_checkpoint_restore
result: pass
recorded_at: 2026-07-15 17:27:37 +0700

## Conventions

- Keep shell scripts in strict mode.
- Use `rtk` for harness commands.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.

## Business Rule Awareness

# Business Rule Awareness

task_id: harden_v3_checkpoint_restore
result: pass
recorded_at: 2026-07-15 17:27:37 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.

## Regression Scope

# Regression Scope

task_id: harden_v3_checkpoint_restore
result: pass
recorded_at: 2026-07-15 17:27:37 +0700

## Scope

- harness plan contract tests
- context pack and work alignment tests
- repository intelligence selection tests
- template export regression tests

## Verification Scope

# Verification Scope

task_id: harden_v3_checkpoint_restore
result: pass
recorded_at: 2026-07-15 17:27:37 +0700

## Commands

- `rtk ./tests/harness/run_all.sh`
- `rtk ./scripts/verify.sh`
- `rtk ./scripts/finalize-task.sh`

## Environment State

# Environment State

task_id: harden_v3_checkpoint_restore
result: pass
recorded_at: 2026-07-15 17:27:37 +0700

## State

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- git_commit: ed416bc84d9ffe998d140243772ecc6e120186c1
- working_tree_status: 43 changed path(s)

## Human Approval

# Human Approval

task_id: harden_v3_checkpoint_restore
result: pass
recorded_at: 2026-07-15 17:27:37 +0700

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

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: Defines checkpoint integrity and recovery authority.

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

task_id: harden_v3_checkpoint_restore
recorded_at: "2026-07-15 17:27"

## Selected Context

- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md

## Notes

Use local repository context only; keep the selection narrow.

## Brownfield Conventions

# Brownfield Conventions

task_id: harden_v3_checkpoint_restore
recorded_at: "2026-07-15 17:27"

## Selected Conventions

- Keep diffs small.
- Preserve existing workflow unless the plan changes it.
- Prefer harness-owned docs and scripts.
- Keep evidence in docs/evidence/<task_id>/.

## Required Checks

- id: checkpoint-test | type: automated | command: rtk bash tests/harness/test_checkpoint_contract.sh | blocking: true | timeout_seconds: 180 | evidence: docs/evidence/harden_v3_checkpoint_restore/checkpoint-test.md

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/verification-pass.md
- docs/evidence/*/autonomous-run-report.md
