# Full Context

task_id: v3_core_bootstrap_contract_and_baseline
title: Protect v3-core bootstrap contract and dirty baseline
generated_at: 2026-07-10 14:19:42 +0700
source_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
source_context_pack: docs/evidence/v3_core_bootstrap_contract_and_baseline/context-pack.md

## Problem Statement

The legacy baseline detector always selects Git `HEAD` when a repository is
present, even if the checkout is dirty. In this repository, `HEAD` predates the
active `.agent-harness` namespace migration, so later tasks would absorb or
misattribute pre-existing tracked, staged, untracked, hidden, generated, and
symlink state. The snapshot generator also drops `.github` directories. The
current release report uses an aggregate score and does not express the
non-compensable v3-core invariants.

## Goal

Protect the v3-core bootstrap with a complete dirty-worktree snapshot baseline,
an exact v2 compatibility report, and a release-blocking invariant matrix
before any v3 authority implementation begins.

## Current Repo State

- active_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- baseline_ref: null
- approved_scopes: harness_core, harness_docs, app_tests
- context_pack: docs/evidence/v3_core_bootstrap_contract_and_baseline/context-pack.md

## Relevant Docs

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

## Relevant ADRs

- id: ADR-0001 | path: docs/decisions/0001-define-scratch-harness-lifecycle-terminology.md | status: Accepted | reason: Defines the canonical lifecycle terms for the scratch harness.
- id: ADR-0002 | path: docs/decisions/0002-remove-harness-skill-selection-contract.md | status: Accepted | reason: Removes the live skill-selection contract from the harness.
- id: ADR-0003 | path: docs/decisions/0003-brownfield-agent-ready-execution-harness.md | status: Accepted | reason: Adds repo memory, ADR control, context packs, and structured task evidence.

## Constraints

- The full-context artifact must be generated before epic, story, or task decomposition.
- The artifact must remain task-scoped and repo-grounded.
- The harness should not require the user to hand-author the context layer.
- Existing task lifecycle commands remain the source of truth.

## Risks

- Repo state may change after the artifact is generated.
- Selected context may omit a newly relevant file if the pack is stale.
- A missing full-context file would cause breakdown commands to block.

## Unknowns

- Whether future tasks should store a canonical copy outside task evidence.
- How much of the generated context should be reused across follow-on tasks.
- Whether some breakdowns should require explicit human review before create.

## Assumptions

- The active plan and repository intelligence are sufficient to ground the breakdown.
- The selected docs and ADRs reflect the current implementation constraints.
- The full-context layer is a generation step, not a new lifecycle phase.

## Implementation Boundaries

- Add the full-context generator and validator.
- Wire the harness packet and task breakdown commands to require the artifact.
- Update workflow and context docs to name the new layer.
- Avoid broad task-store or lifecycle redesign.

## Recommended Breakdown

### Epic 1: Protect the v3-core bootstrap baseline

Dependencies:

- Requires the finalized vNext governance contract and preservation of the
  current dirty namespace migration.

Acceptance Criteria:

- Dirty, hidden, and symlink repository state is captured deterministically.
- Existing v2 behavior and package shape have inspectable baseline evidence.
- Correctness and security invariants cannot be offset by aggregate scores.

Stories:

- Establish trustworthy change attribution and release proof before v3 code.

Tasks:

- Implement dirty-worktree baseline protection and v3-core invariant evidence.

## Validation Notes

- Generated from the active plan, repository intelligence, and task-local context pack.
- Validate the artifact before allowing any epic, story, or task breakdown.
- This file is the pre-breakdown context source for the current task.
