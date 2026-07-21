# Full Context

task_id: implement_v3_projection_replay_audit
title: Implement v3 projection replay audit
generated_at: 2026-07-11 19:26:19 +0700
source_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
source_context_pack: docs/evidence/implement_v3_projection_replay_audit/context-pack.md

## Problem Statement

Finalization currently has legacy projection writers. A deterministic audit is
needed to detect when projections diverge from `state.json` or `events.jsonl`
without treating projections as authority.

## Goal

Provide a read-only v3 projection replay audit. Given a run directory, replay
the immutable event chain into the expected authoritative lifecycle state and
compare it with generated `current.md` and task-store status projections.
Report exact hashes and drift classes, return non-zero on any mismatch, and
never rewrite authority or projections.

## Current Repo State

- active_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- baseline_ref: null
- approved_scopes: harness_core, harness_docs, app_tests
- context_pack: docs/evidence/implement_v3_projection_replay_audit/context-pack.md

## Relevant Docs

- docs/context/memory-index.json
- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md
- docs/context/conventions.md
- docs/context/runbooks.md
- docs/context/known-errors.md
- docs/context/discussions.md
- docs/evidence/implement_v3_projection_replay_audit/working-memory.md
- docs/evidence/implement_v3_projection_replay_audit/localization.md
- docs/evidence/implement_v3_projection_replay_audit/brownfield-conventions.md
- docs/evidence/implement_v3_projection_replay_audit/repo-knowledge-selection.md
- docs/evidence/implement_v3_projection_replay_audit/impact-scan.md
- docs/evidence/implement_v3_projection_replay_audit/convention-awareness.md
- docs/evidence/implement_v3_projection_replay_audit/business-rule-awareness.md
- docs/evidence/implement_v3_projection_replay_audit/regression-scope.md
- docs/evidence/implement_v3_projection_replay_audit/verification-scope.md
- docs/evidence/implement_v3_projection_replay_audit/environment-state.md
- docs/evidence/implement_v3_projection_replay_audit/human-approval.md
- docs/evidence/implement_v3_projection_replay_audit/adr-review.md
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

### Epic 1: v3 authority projection integrity

Dependencies:

- Existing canonical state, event-chain, and task-store schemas

Acceptance Criteria:

- Replay authority and detect projection drift without mutation

Stories:

- Read-only projection audit

Tasks:

- Implement script, route, and regression fixtures

Replace the placeholders above with concrete epics, stories, tasks,
dependencies, and acceptance criteria before approval.

## Validation Notes

- Generated from the active plan, repository intelligence, and task-local context pack.
- Validate the artifact before allowing any epic, story, or task breakdown.
- This file is the pre-breakdown context source for the current task.
