---
task_id: reconcile_stale_task_projections
title: "Reconcile stale canonical and legacy task projections"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: tiny
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 3
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-16 21:37"
baseline_ref: null
file_map_approved: true
review_required: false
evidence_required: true
requires_rollback_plan: false
requires_human_approval: false
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
approved_scopes:
  - harness_core
  - harness_docs
  - app_tests
approved_files:
  - .agent-harness/docs/tasks/tasks.jsonl
  - .agent-harness/docs/tasks/implementation_readiness_tasks.jsonl
approved_deletions: []
environment_mode: local
environment_setup_required: false
environment_run_prefix: ""
environment_compose_file: null
environment_service: null
environment_reason: null
verification_mode: required_checks
testing_required: true
testing_skip_reason: ""
parent_epic_id: null
parent_story_id: null
epic_path: null
story_registry: null
epic_memory: null
epic_progress: null
integration_contract: null
epic_clarifications: null
epic_context_required: false
spec_clarification_required: false
spec_clarification_evidence: docs/evidence/reconcile_stale_task_projections/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/reconcile_stale_task_projections/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/reconcile_stale_task_projections/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/reconcile_stale_task_projections/context-pack.md
working_memory_path: docs/evidence/reconcile_stale_task_projections/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - Canonical stale task align_v3_plan_and_review_authority is projected as DONE, matching finalized evidence.
  - Legacy implementation_readiness_tasks.jsonl contains no READY records that can be mistaken for active v3 backlog.
  - No implementation source files or the original TOC are changed.
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: plan-check
    type: automated
    command: rtk ./scripts/task.sh ready --limit 1
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: "docs/evidence/reconcile_stale_task_projections/plan-check.md"
completed_at: "2026-07-16 21:41"
---

# Execution Plan: Reconcile stale canonical and legacy task projections

## Update History

Updated: 2026-06-04 16:40

## Goal

Reconcile stale task projections so completed work is not reported as active or ready.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/reconcile_stale_task_projections/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/reconcile_stale_task_projections/behavior-baseline.md
  approval_snapshot_path: docs/evidence/reconcile_stale_task_projections/approval-snapshot.md

  created_before_execution: false

  policy:
    brownfield_requires_behavior_baseline: true
    missing_change_baseline: create_snapshot
    missing_behavior_baseline: block # block | human_approval
```

Do not publicly expose these legacy baseline modes:

```text
manifest
ephemeral
none_strict
```

## Feature Intake

### Problem

The canonical task registry contains one historical task marked IN_PROGRESS,
and the legacy readiness registry contains old READY records. These records
confuse backlog audits even though the v3 implementation batch is complete.

### Scope

Update only the two task registries listed in approved_files. Mark the
finalized canonical task DONE and mark legacy readiness records DONE so they
cannot appear as pending work.

### Out of Scope

Do not change implementation code, harness behavior, task evidence, the v3
TOC, or any external batch approval artifact.

### Success Criteria

The canonical registry has no READY or IN_PROGRESS records. The legacy
registry has no READY records. Existing finalized evidence remains consistent.

### Dependencies

This is a repository-local maintenance task and must use the normal v3
verify/finalize lifecycle.

Replace the placeholders above with concrete epics, stories, tasks,
dependencies, and acceptance criteria before approval.

## Brownfield Evidence

When the task is brownfield or plan-driven, create task-local evidence for:

- `intake.md`
- `full-context.md`
- `adr-review.md`
- `discussion-summary.md`
- `localization.md`
- `brownfield-conventions.md`
- `context-pack.md`
- `working-memory.md`

## Report Shape

Autonomous run reports should summarize:

- relevant ADRs
- context pack path
- working memory path
- files read
- files changed
- actions taken
- decisions made
- harness friction
- token estimate
- outcome

## Approved Decisions

- 

## Scope

### In Scope

- 

### Out of Scope

- 

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A:
- [ ] Phase B:

## Verification

Check types are stack-agnostic:

- `setup`: prepares dependencies or services; command required, RTK-wrapped,
  and always blocking.
- `automated`: runs a command; command required, timeout required, and
  RTK-wrapped.

```bash
rtk ./scripts/verify.sh
```

## Review

State whether review is required for this lane.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
