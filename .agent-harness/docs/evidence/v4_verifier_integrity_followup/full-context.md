# Full Context

task_id: v4_verifier_integrity_followup
title: Harden standalone v4 verification and add finalization integration coverage
generated_at: 2026-07-18 18:40:12 +0700
source_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
source_context_pack: docs/evidence/v4_verifier_integrity_followup/context-pack.md

## Problem Statement

The standalone v4 verdict checker trusts a supplied workspace hash, and the
repository lacks a real finalization regression test for v4 authority.

## Goal

Ensure the standalone v4 verifier validates the workspace binding itself and
add end-to-end finalization coverage for accepted and forged v4 verdicts.

## Current Repo State

- active_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- baseline_ref: null
- approved_scopes: harness_core, harness_docs, app_tests
- context_pack: docs/evidence/v4_verifier_integrity_followup/context-pack.md

## Relevant Docs

- docs/context/memory-index.json
- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md
- docs/context/conventions.md
- docs/context/runbooks.md
- docs/context/known-errors.md
- docs/context/discussions.md
- docs/evidence/v4_verifier_integrity_followup/working-memory.md
- docs/evidence/v4_verifier_integrity_followup/localization.md
- docs/evidence/v4_verifier_integrity_followup/brownfield-conventions.md
- docs/evidence/v4_verifier_integrity_followup/repo-knowledge-selection.md
- docs/evidence/v4_verifier_integrity_followup/impact-scan.md
- docs/evidence/v4_verifier_integrity_followup/convention-awareness.md
- docs/evidence/v4_verifier_integrity_followup/business-rule-awareness.md
- docs/evidence/v4_verifier_integrity_followup/regression-scope.md
- docs/evidence/v4_verifier_integrity_followup/verification-scope.md
- docs/evidence/v4_verifier_integrity_followup/environment-state.md
- docs/evidence/v4_verifier_integrity_followup/human-approval.md
- docs/evidence/v4_verifier_integrity_followup/adr-review.md
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

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | hash: b6cde0431dbce0fc497e3aa9eb4945e613a64752d37bbf0ed85380418c2974b5 | status: Accepted | reason: Makes state.json the sole v3 lifecycle authority and current.md a generated projection.

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

### Epic 1: v4 verification integrity follow-up

Dependencies:

- Existing v4 verifier and v3 finalization contracts.

Acceptance Criteria:

- The repository snapshot digest is independently recomputed.
- Finalization integration accepts only harness-produced v4 verification.

Stories:

- Harden standalone verification and finalization coverage.

Tasks:

- Recompute workspace hash in the standalone checker.
- Add valid and forged finalization integration cases.

Replace the placeholders above with concrete epics, stories, tasks,
dependencies, and acceptance criteria before approval.

## Validation Notes

- Generated from the active plan, repository intelligence, and task-local context pack.
- Validate the artifact before allowing any epic, story, or task breakdown.
- This file is the pre-breakdown context source for the current task.

## V3 Contract Coverage

```text
{"rule_count": 10, "uncovered_blocking_rules": 0, "valid": true, "workflow_version": "v3"}
bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8): No such file or directory
```

## Implementation Readiness

```text
readiness record not bound for this task
```
