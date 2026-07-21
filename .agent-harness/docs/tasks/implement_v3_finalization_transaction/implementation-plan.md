---
task_id: implement_v3_finalization_transaction
title: "Implement v3 finalization transaction"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: high_risk
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 3
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-11 19:45"
baseline_ref: null
file_map_approved: true
review_required: true
evidence_required: true
requires_rollback_plan: true
requires_human_approval: true
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
approved_scopes:
  - harness_core
  - harness_docs
  - app_tests
approved_files:
  - scripts/finalize-v3-run
  - policies/state-transitions.yaml
  - tests/harness/test_v3_finalization_transaction.sh
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
spec_clarification_evidence: docs/evidence/implement_v3_finalization_transaction/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_v3_finalization_transaction/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_v3_finalization_transaction/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_v3_finalization_transaction/context-pack.md
working_memory_path: docs/evidence/implement_v3_finalization_transaction/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001: v3 finalization validates AC, verifier, failure, and projection evidence before mutation
  - AC-002: lifecycle enters FINALIZING, journals task projection, and reaches FINALIZED only after ordered steps
  - AC-003: restart resumes idempotently and mismatched journal/state enters recovery without projection repair
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
    evidence: "docs/evidence/implement_v3_finalization_transaction/plan-check.md"
  - id: focused-test
    type: automated
    command: "rtk ./tests/harness/test_v3_finalization_transaction.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-002
      - AC-003
    evidence: "docs/evidence/implement_v3_finalization_transaction/focused-test.md"
completed_at: "2026-07-11 19:56"
---

# Execution Plan: Implement v3 finalization transaction

## Update History

Updated: 2026-07-11 19:45

## Goal

Add a v3-only finalization command that validates per-AC evidence, independent
Verifier evidence, failure history, and projection integrity; transitions
`PASSED -> FINALIZING -> FINALIZED`; and journals task-store projection updates
with expected before/after hashes. Restart must resume only matching steps and
otherwise report `RECOVERY_REQUIRED` without mutation.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_v3_finalization_transaction/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_v3_finalization_transaction/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_v3_finalization_transaction/approval-snapshot.md

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

The legacy finalizer directly mutates plan and task projections. v3 needs an
ordered, durable finalization transaction whose state authority remains
`state.json` and whose projections cannot authorize lifecycle success.

### Scope

Add the v3 finalization command, transition policy states, dispatcher route, and
fixtures for successful ordering, failed evidence, idempotent restart, and
journal/state mismatch.

### Out of Scope

No change to v2 finalization semantics, external saga compensation, or repair of
already-corrupt projections is in scope.

### Success Criteria

Focused fixtures prove all gates, state transitions, ordered journal steps,
replay safety, and fail-closed recovery. Existing v2 and full suites remain
green.

### Dependencies

Depends on transition-state, AC/verifier/failure validators, and task-store
projection conventions. `state.json` remains the only lifecycle writer.

## Epic / Story / Task Breakdown

### Epic 1: authoritative v3 finalization

Dependencies:

- Existing transition, evidence, verifier, failure, and projection validators

Acceptance Criteria:

- Ordered journaled finalization with fail-closed restart behavior

Stories:

- v3 finalization transaction

Tasks:

- Implement command, policy states, route, and tests

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

- [ ] Phase A: implement transaction and recovery fixtures
- [ ] Phase B: run focused/full/benchmark/harness/review/finalization gates

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

Required: independent read-only review because finalization is a high-risk
authority boundary.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
