# Full Context

task_id: v3_authority_binding_integrity_followup_plan
title: v3_authority_binding_integrity_followup_plan
generated_at: 2026-07-15 22:15:19 +0700
source_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
source_context_pack: docs/evidence/v3_authority_binding_integrity_followup_plan/context-pack.md

## Problem Statement

The current v3 implementation still has six integrity gaps that could permit
parallel authority paths, unverifiable package bindings, incomplete source
snapshots, weak traceability, or non-atomic intake artifacts.

## Goal

Create and grill a separate v3 authority-integrity follow-up fix plan for the six
remaining gaps found in the repository audit. This task is planning-only: it
must not implement source changes and must not edit the original TOC or prior
fix plans.

## Current Repo State

- active_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: false
- task_backward_compatibility_required: true
- baseline_ref: null
- approved_scopes: harness_docs
- context_pack: docs/evidence/v3_authority_binding_integrity_followup_plan/context-pack.md

## Relevant Docs

- docs/context/memory-index.json
- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md
- docs/context/conventions.md
- docs/context/runbooks.md
- docs/context/known-errors.md
- docs/context/discussions.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/working-memory.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/localization.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/brownfield-conventions.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/repo-knowledge-selection.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/impact-scan.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/convention-awareness.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/business-rule-awareness.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/regression-scope.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/verification-scope.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/environment-state.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/human-approval.md
- docs/evidence/v3_authority_binding_integrity_followup_plan/adr-review.md
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

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: The v3 authority model governs state authority, recovery, and generated projections.

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

### Epic 1: Authority-integrity follow-up planning

Dependencies:

- Existing v3 authority-binding implementation and the six-gap audit.

Acceptance Criteria:

- All six gaps are covered by decisions and implementation acceptance criteria.

Stories:

- Grill and record boundary, binding, snapshot, retrieval, traceability, and atomicity decisions.

Tasks:

- Produce the separate dated fix plan; do not implement it in this task.

The breakdown above is concrete and repository-grounded.

## Validation Notes

- Generated from the active plan, repository intelligence, and task-local context pack.
- Validate the artifact before allowing any epic, story, or task breakdown.
- This file is the pre-breakdown context source for the current task.
