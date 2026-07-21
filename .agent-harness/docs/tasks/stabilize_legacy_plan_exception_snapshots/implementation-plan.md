---
task_id: stabilize_legacy_plan_exception_snapshots
title: "stabilize_legacy_plan_exception_snapshots"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: tiny
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 1
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-13 10:31"
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
  - .agent-harness/policies/task-plan-exceptions.json
  - .agent-harness/policies/task-plan-exception-snapshots/**
  - .agent-harness/scripts/check-task-plan-consistency.sh
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
spec_clarification_evidence: docs/evidence/stabilize_legacy_plan_exception_snapshots/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/stabilize_legacy_plan_exception_snapshots/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/stabilize_legacy_plan_exception_snapshots/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/stabilize_legacy_plan_exception_snapshots/context-pack.md
working_memory_path: docs/evidence/stabilize_legacy_plan_exception_snapshots/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001
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
    command: "rtk ./scripts/harness.sh next"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: "docs/evidence/stabilize_legacy_plan_exception_snapshots/plan-check.md"
completed_at: "2026-07-13 10:32"
---

# Execution Plan: stabilize_legacy_plan_exception_snapshots

## Update History

Updated: 2026-07-13 10:35
Updated: 2026-06-04 16:40

## Goal

Make legacy task-plan exceptions immutable by validating protected snapshot
hashes instead of mutable fixture plan files.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/stabilize_legacy_plan_exception_snapshots/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/stabilize_legacy_plan_exception_snapshots/behavior-baseline.md
  approval_snapshot_path: docs/evidence/stabilize_legacy_plan_exception_snapshots/approval-snapshot.md

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

Release fixtures rewrite legacy plans, invalidating live-file hashes.

### Scope

Add six snapshot copies, point the exception manifest at them, and update the
checker to validate snapshot hashes while treating live plans as untrusted.

### Out of Scope

No lifecycle or fixture behavior changes; the task only protects the
immutable evidence used by Epic 1 and AC-001.

### Success Criteria

The checker passes before and after fixture rewrites; tampered snapshots fail.

### Dependencies

Depends on the existing exception manifest and checker.

## Epic / Story / Task Breakdown

### Epic 1: Immutable legacy exception evidence

Dependencies:

- Existing task-plan consistency checker.

Acceptance Criteria:

- AC-001: exception hashes bind immutable snapshots.

Stories:

- Protect historical plan evidence.

Tasks:

- Add snapshots and validate their hashes.

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

- Mutable legacy plans remain untrusted; only snapshot hashes are accepted.

## Scope

### In Scope

- Exception manifest, snapshot files, and checker logic.

### Out of Scope

- Mutable legacy plan contents.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: snapshot and checker update
- [ ] Phase B: verify and finalize

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
