# Full Context

task_id: implement_v3_contract_coverage_finalization_hardening
title: Implement v3 contract coverage and finalization hardening
generated_at: 2026-07-16 11:38:25 +0700
source_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
source_context_pack: docs/evidence/implement_v3_contract_coverage_finalization_hardening/context-pack.md

## Problem Statement

The current harness has multiple finalization and task-projection entry points.
Some requirements are documented but are not mechanically linked to every
entry point, denial test, or recovery test. This allows forgotten features and
alternate paths to pass the happy-path benchmark.

## Goal

Implement the approved v3 contract-coverage and finalization-hardening plan.
Every blocking authority rule must map to implementation, denial, and
recovery evidence. Final human approval must be complete and provenance-bound;
direct task completion must be denied; every finalization entry point must use
the same v3 validation; and uncovered blocking rules must block verification.

## Current Repo State

- active_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
- repo_mode: brownfield
- task_change_type: extend_existing
- task_touches_existing_behavior: true
- task_backward_compatibility_required: true
- baseline_ref: null
- approved_scopes: harness_core, harness_docs, app_tests
- context_pack: docs/evidence/implement_v3_contract_coverage_finalization_hardening/context-pack.md

## Relevant Docs

- docs/context/memory-index.json
- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md
- docs/context/conventions.md
- docs/context/runbooks.md
- docs/context/known-errors.md
- docs/context/discussions.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/working-memory.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/localization.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/brownfield-conventions.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/repo-knowledge-selection.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/impact-scan.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/convention-awareness.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/business-rule-awareness.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/regression-scope.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/verification-scope.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/environment-state.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/human-approval.md
- docs/evidence/implement_v3_contract_coverage_finalization_hardening/adr-review.md
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

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: Makes state.json the sole v3 lifecycle authority and current.md a generated projection.

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

## V3 Contract Coverage

```text
{"rule_count": 9, "uncovered_blocking_rules": 0, "valid": true, "workflow_version": "v3"}
bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8): No such file or directory
```
