# Full Context

task_id: 1_repair_automatic_remediation_epochs_only_if_needed
title: .1: Repair automatic remediation epochs only if needed
generated_at: 2026-07-16 17:08:04 +0700
source_plan: /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/exec-plans/active/current.md
source_context_pack: docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/context-pack.md

## Problem Statement

The harness needs a repo-grounded context layer before decomposition.

## Goal

.1: Repair automatic remediation epochs only if needed

## Parent References

- epic_id: `plan_v3_harness_scope_reconciliation_and_completion_epic`
- story_id: `implementation_tasks`
- source_plan_path: `/Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/intake/2026_07_15_v3_harness_scope_reconciliation_plan.md`
- implementation_plan_path: `/Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness/docs/tasks/1_repair_automatic_remediation_epochs_only_if_needed/implementation-plan.md`

## Scope

### Approved Scopes

- harness_core
- harness_docs
- app_tests

### Approved Files

- None

## Acceptance Criteria

- Implement: .1: Repair automatic remediation epochs only if needed
- Required checks pass
- Changes stay inside approved scopes/files

## Required Checks

- `rtk ./scripts/harness.sh benchmark --no-history --timeout 60`

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
- context_pack: docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/context-pack.md

## Relevant Docs

- docs/context/memory-index.json
- docs/context/repo-profile.md
- docs/context/commands.md
- docs/context/boundaries.md
- docs/context/conventions.md
- docs/context/runbooks.md
- docs/context/known-errors.md
- docs/context/discussions.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/working-memory.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/localization.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/brownfield-conventions.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/repo-knowledge-selection.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/impact-scan.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/convention-awareness.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/business-rule-awareness.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/regression-scope.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/verification-scope.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/environment-state.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/human-approval.md
- docs/evidence/1_repair_automatic_remediation_epochs_only_if_needed/adr-review.md
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
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/epic.md
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/epic-memory.md
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/integration-contract.md
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/clarifications.md
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/progress.md
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/stories.jsonl
- docs/epics/plan_v3_harness_scope_reconciliation_and_completion_epic/stories.jsonl#story:implementation_tasks

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
{"rule_count": 10, "uncovered_blocking_rules": 0, "valid": true, "workflow_version": "v3"}
bash: warning: setlocale: LC_ALL: cannot change locale (C.UTF-8): No such file or directory
```

## Implementation Readiness

```text
readiness record not bound for this task
```
