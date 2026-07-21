# Context Pack

task_id: clean_template_export_sanitization
budget: 5000
packed_at: "2026-07-21 11:00"

## Active Task

- task_id: clean_template_export_sanitization
- title: Sanitize clean-template export contents
- status: DRAFT
- lifecycle_phase: PLAN
- lane: tiny
- review_required: false
- verification_mode: required_checks
- required_checks: 2

## Selected Context Files

- docs/context/memory-index.json
- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md
- docs/context/conventions.md
- docs/context/runbooks.md
- docs/context/known-errors.md
- docs/context/discussions.md
- docs/evidence/clean_template_export_sanitization/working-memory.md
- docs/evidence/clean_template_export_sanitization/localization.md
- docs/evidence/clean_template_export_sanitization/brownfield-conventions.md
- docs/evidence/clean_template_export_sanitization/repo-knowledge-selection.md
- docs/evidence/clean_template_export_sanitization/impact-scan.md
- docs/evidence/clean_template_export_sanitization/convention-awareness.md
- docs/evidence/clean_template_export_sanitization/business-rule-awareness.md
- docs/evidence/clean_template_export_sanitization/regression-scope.md
- docs/evidence/clean_template_export_sanitization/verification-scope.md
- docs/evidence/clean_template_export_sanitization/environment-state.md
- docs/evidence/clean_template_export_sanitization/human-approval.md
- docs/evidence/clean_template_export_sanitization/adr-review.md
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

task_id: clean_template_export_sanitization
result: generated
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
recorded_at: 2026-07-21 11:00:35 +0700

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

task_id: clean_template_export_sanitization
result: generated
repo_mode: brownfield
task_change_type: extend_existing
recorded_at: 2026-07-21 11:00:35 +0700

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
- docs/evidence/clean_template_export_sanitization/**
- tests/harness/**

## Convention Awareness

# Convention Awareness

task_id: clean_template_export_sanitization
result: generated
recorded_at: 2026-07-21 11:00:35 +0700

## Conventions

- Keep shell scripts in strict mode.
- Use the public harness driver; prefer `rtk` when installed and fall back to `bash`.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.

## Business Rule Awareness

# Business Rule Awareness

task_id: clean_template_export_sanitization
result: generated
recorded_at: 2026-07-21 11:00:35 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.

## Regression Scope

# Regression Scope

task_id: clean_template_export_sanitization
result: generated
recorded_at: 2026-07-21 11:00:35 +0700

## Scope

- harness plan contract tests
- context pack and work alignment tests
- repository intelligence selection tests
- template export regression tests

## Verification Scope

# Verification Scope

task_id: clean_template_export_sanitization
result: generated
recorded_at: 2026-07-21 11:00:35 +0700

## Commands

- `rtk ./tests/harness/run_all.sh`
- `rtk ./scripts/verify.sh`
- `rtk ./scripts/finalize-task.sh`

## Environment State

# Environment State

task_id: clean_template_export_sanitization
result: generated
recorded_at: 2026-07-21 11:00:35 +0700

## State

- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- git_commit: d634f92bc7c035a9ef3fabf1c61f3a0164dcfec6
- working_tree_status: 14 changed path(s)

## Human Approval

# Human Approval

task_id: clean_template_export_sanitization
result: generated
recorded_at: 2026-07-21 11:00:35 +0700

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

task_id: clean_template_export_sanitization
recorded_at: "2026-07-21 11:00"

## Selected Context

- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md

## Notes

Use local repository context only; keep the selection narrow.

## Brownfield Conventions

# Brownfield Conventions

task_id: clean_template_export_sanitization
recorded_at: "2026-07-21 11:00"

## Selected Conventions

- Keep diffs small.
- Preserve existing workflow unless the plan changes it.
- Prefer harness-owned docs and scripts.
- Keep evidence in docs/evidence/<task_id>/.

## Required Checks

- id: plan-check | type: automated | command: rtk ./scripts/harness.sh next | blocking: true | timeout_seconds: 180 | evidence: docs/evidence/clean_template_export_sanitization/plan-check.md
- id: export-regression | type: automated | command: rtk ./tests/harness/test_export_harness_package.sh | blocking: true | timeout_seconds: 180 | evidence: docs/evidence/clean_template_export_sanitization/export-regression.md

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/verification-pass.md
- docs/evidence/*/autonomous-run-report.md
