---
task_id: implement_v3_projection_replay_audit
title: "Implement v3 projection replay audit"
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
approved_at: "2026-07-11 19:20"
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
  - scripts/check-v3-projections
  - tests/test_v3_projection_replay_audit.sh
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
spec_clarification_evidence: docs/evidence/implement_v3_projection_replay_audit/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_v3_projection_replay_audit/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_v3_projection_replay_audit/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_v3_projection_replay_audit/context-pack.md
working_memory_path: docs/evidence/implement_v3_projection_replay_audit/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001: authoritative state and event-chain replay deterministically identify projection drift
  - AC-002: stale or malformed projections fail closed without mutation
  - AC-003: audit output is sanitized, hash-bound, and regression-tested
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
    evidence: "docs/evidence/implement_v3_projection_replay_audit/plan-check.md"
  - id: focused-test
    type: automated
    command: "rtk ./tests/test_v3_projection_replay_audit.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-002
      - AC-003
    evidence: "docs/evidence/implement_v3_projection_replay_audit/focused-test.md"
completed_at: "2026-07-11 19:27"
---

# Execution Plan: Implement v3 projection replay audit

## Update History

Updated: 2026-07-11 19:25

## Goal

Provide a read-only v3 projection replay audit. Given a run directory, replay
the immutable event chain into the expected authoritative lifecycle state and
compare it with generated `current.md` and task-store status projections.
Report exact hashes and drift classes, return non-zero on any mismatch, and
never rewrite authority or projections.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_v3_projection_replay_audit/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_v3_projection_replay_audit/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_v3_projection_replay_audit/approval-snapshot.md

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

Finalization currently has legacy projection writers. A deterministic audit is
needed to detect when projections diverge from `state.json` or `events.jsonl`
without treating projections as authority.

### Scope

Add the audit script, public harness routing, and focused fixtures covering
matching projections, stale status, event-chain corruption, and malformed
projection input.

### Out of Scope

No projection repair, lifecycle transition, schema migration, task-store
rewrite, or change to legacy v2 finalization behavior is in scope.

### Success Criteria

All focused fixtures pass; mismatched or untrusted inputs return a failure
diagnostic and leave files byte-identical; output includes workflow version,
implementation version, enforcement mode, and authority/projection hashes.

### Dependencies

Depends on existing state/event schemas and public `harness.sh` dispatch.
The command must be read-only and use only sanitized metadata.

## Epic / Story / Task Breakdown

### Epic 1: v3 authority projection integrity

Dependencies:

- Existing canonical state, event-chain, and task-store schemas

Acceptance Criteria:

- Replay authority and detect projection drift without mutation

Stories:

- Read-only projection audit

Tasks:

- Implement script, route, and regression fixtures

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

- [ ] Phase A: implement read-only audit and public route
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

Required: independent read-only review because this is a high-risk
control-plane integrity change.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
