---
task_id: implement_run_successor_lineage
title: "Implement immutable successor run lineage"
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
approved_at: "2026-07-11 20:24"
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
  - scripts/run-events.sh
  - tests/harness/test_run_successor_lineage.sh
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
spec_clarification_evidence: docs/evidence/implement_run_successor_lineage/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_run_successor_lineage/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_run_successor_lineage/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_run_successor_lineage/context-pack.md
working_memory_path: docs/evidence/implement_run_successor_lineage/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001: successor runs carry immutable supersedes_run_id linkage and exact task/spec/policy identity
  - AC-002: self-links, missing predecessor identity, and mismatched bindings fail closed
  - AC-003: legacy run creation remains compatible and event-chain verification includes lineage
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
    evidence: "docs/evidence/implement_run_successor_lineage/plan-check.md"
  - id: focused-test
    type: automated
    command: "rtk ./tests/harness/test_run_successor_lineage.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-002
      - AC-003
    evidence: "docs/evidence/implement_run_successor_lineage/focused-test.md"
completed_at: "2026-07-11 20:31"
---

# Execution Plan: Implement immutable successor run lineage

## Update History

Updated: 2026-07-11 20:30

## Goal

Extend `run-events create` with an optional predecessor run identity. A
successor run records `supersedes_run_id`, predecessor task/spec/policy hashes,
and a lineage hash; the record is immutable and event verification reports the
lineage. Existing calls without a predecessor retain their behavior.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_run_successor_lineage/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_run_successor_lineage/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_run_successor_lineage/approval-snapshot.md

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

Rollback and materially new execution attempts currently create unlinked run
records, weakening auditability and successor authority isolation.

### Scope

Update run identity creation/verification and add focused lineage fixtures.

### Out of Scope

No automatic approval inheritance, lifecycle migration, or predecessor state
mutation is in scope.

### Success Criteria

Legacy create and append tests pass; valid successor linkage verifies; invalid
or mismatched links fail without writing artifacts; and lineage hashes are
stable and sanitized.

### Dependencies

Depends on existing immutable `run.json` and `events.jsonl` schemas. A
predecessor record must be readable and exact-bound before creating a successor.

## Epic / Story / Task Breakdown

### Epic 1: auditable successor runs

Dependencies:

- Existing run identity and event-chain format

Acceptance Criteria:

- Successor authority is linked but never inherited

Stories:

- Immutable run lineage

Tasks:

- Implement predecessor validation, lineage hash, and tests

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

- [ ] Phase A: implement lineage fields and validation
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

Required: independent read-only review because run identity and successor
authority are high-risk audit boundaries.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
