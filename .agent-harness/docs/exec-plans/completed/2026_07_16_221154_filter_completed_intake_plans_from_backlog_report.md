---
task_id: filter_completed_intake_plans_from_backlog_report
title: "Exclude completed intake plans from the active backlog report"
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
approved_at: "2026-07-16 22:09"
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
  - .agent-harness/scripts/harness.sh
  - .agent-harness/tests/harness/test_intake_backlog_report.sh
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
spec_clarification_evidence: docs/evidence/filter_completed_intake_plans_from_backlog_report/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/filter_completed_intake_plans_from_backlog_report/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/filter_completed_intake_plans_from_backlog_report/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/filter_completed_intake_plans_from_backlog_report/context-pack.md
working_memory_path: docs/evidence/filter_completed_intake_plans_from_backlog_report/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - Completed intake source plans are excluded from the active backlog count.
  - Intake plans with unfinished canonical tasks remain counted.
  - A focused regression test covers both cases without changing task authority.
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: intake-backlog-report-test
    type: automated
    command: rtk bash tests/harness/test_intake_backlog_report.sh
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: "docs/evidence/filter_completed_intake_plans_from_backlog_report/plan-check.md"
completed_at: "2026-07-16 22:11"
---

# Execution Plan: Exclude completed intake plans from the active backlog report

## Update History

Updated: 2026-06-04 16:40

## Goal

Make the backlog report distinguish historical source plans from actionable intake plans.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/filter_completed_intake_plans_from_backlog_report/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/filter_completed_intake_plans_from_backlog_report/behavior-baseline.md
  approval_snapshot_path: docs/evidence/filter_completed_intake_plans_from_backlog_report/approval-snapshot.md

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

The harness reports every intake markdown file as pending even when all tasks
derived from that plan are DONE. This makes an empty v3 backlog look active.

### Scope

Update the public next-report calculation and add a focused regression test.
An intake plan is actionable when at least one canonical task references it and
is not DONE; otherwise it is retained as historical provenance but excluded.

### Out of Scope

Do not delete or move intake plans. Do not change task lifecycle authority,
task statuses, implementation behavior, or the original TOC.

### Success Criteria

The report shows zero actionable intake plans after the completed v3 batch, and
the regression test proves an unfinished referenced plan is still counted.

### Dependencies

The canonical task registry remains the source of truth for whether an intake
plan is actionable.

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
