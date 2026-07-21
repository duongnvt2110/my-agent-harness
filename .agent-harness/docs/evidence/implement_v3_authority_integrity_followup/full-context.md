# Full Context

task_id: implement_v3_authority_integrity_followup
title: Implement the approved v3 authority integrity fixes
generated_at: 2026-07-15 22:20:34 +0700
source_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
source_context_pack: docs/evidence/implement_v3_authority_integrity_followup/context-pack.md

## Problem Statement

The harness needs a repo-grounded context layer before decomposition.

## Goal

Implement the approved v3 authority integrity fixes

## Parent References

- epic_id: `none`
- story_id: `none`
- source_plan_path: `none`
- implementation_plan_path: `docs/tasks/implement_v3_authority_integrity_followup/implementation-plan.md`

## Scope

### Approved Scopes

- harness_core
- harness_docs
- app_tests

### Approved Files

- .agent-harness/scripts/**
- .agent-harness/tests/**
- .agent-harness/docs/**

## Acceptance Criteria

- Direct helper scripts cannot create parallel authority artifacts
- Implementation entry proves the exact locked Change Package and state bindings
- Snapshot, URL/MCP provenance, traceability, and atomic-write checks fail closed
- Integrity failures use autonomous remediation without bypassing verification
- Required checks pass and the original TOC remains unchanged

## Required Checks

- `rtk .agent-harness/harness.sh benchmark --no-history --timeout 60`

## Out of Scope

- Do not place the full epic/story/task tree in this active plan.
- Do not modify files outside approved scopes/files.

## Verification

Run the required checks listed in frontmatter, then run `rtk ./scripts/verify.sh` when implementation is complete.

## Current Repo State

- active_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- baseline_ref: null
- approved_scopes: harness_core, harness_docs, app_tests
- context_pack: docs/evidence/implement_v3_authority_integrity_followup/context-pack.md

## Relevant Docs

- docs/context/memory-index.json
- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md
- docs/context/conventions.md
- docs/context/runbooks.md
- docs/context/known-errors.md
- docs/context/discussions.md
- docs/evidence/implement_v3_authority_integrity_followup/working-memory.md
- docs/evidence/implement_v3_authority_integrity_followup/localization.md
- docs/evidence/implement_v3_authority_integrity_followup/brownfield-conventions.md
- docs/evidence/implement_v3_authority_integrity_followup/repo-knowledge-selection.md
- docs/evidence/implement_v3_authority_integrity_followup/impact-scan.md
- docs/evidence/implement_v3_authority_integrity_followup/convention-awareness.md
- docs/evidence/implement_v3_authority_integrity_followup/business-rule-awareness.md
- docs/evidence/implement_v3_authority_integrity_followup/regression-scope.md
- docs/evidence/implement_v3_authority_integrity_followup/verification-scope.md
- docs/evidence/implement_v3_authority_integrity_followup/environment-state.md
- docs/evidence/implement_v3_authority_integrity_followup/human-approval.md
- docs/evidence/implement_v3_authority_integrity_followup/adr-review.md
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

- Add a full-context generator command.
- Add a full-context validation command.
- Wire epic, story, and task creation to require the artifact.
- Update packet output and workflow docs.
- Add tests for generation and gating.

## Validation Notes

- Generated from the active plan, repository intelligence, and task-local context pack.
- Validate the artifact before allowing any epic, story, or task breakdown.
- This file is the pre-breakdown context source for the current task.
