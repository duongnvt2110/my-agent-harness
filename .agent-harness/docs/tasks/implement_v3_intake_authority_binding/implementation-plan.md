---
task_id: implement_v3_intake_authority_binding
title: "implement_v3_intake_authority_binding"
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
approved_at: "2026-07-15 21:45"
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
approved_files: []
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
spec_clarification_evidence: docs/evidence/implement_v3_intake_authority_binding/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_v3_intake_authority_binding/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_v3_intake_authority_binding/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_v3_intake_authority_binding/context-pack.md
working_memory_path: docs/evidence/implement_v3_intake_authority_binding/working-memory.md
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
    evidence: "docs/evidence/implement_v3_intake_authority_binding/plan-check.md"
completed_at: "2026-07-15 21:50"
---

# Execution Plan: implement_v3_intake_authority_binding

## Update History

Updated: 2026-06-04 16:40
Updated: 2026-07-15 22:55

## Goal

Bind the one-file Change Package to the existing v3 lifecycle authority. The
approved package hash must be protected, recorded in the event chain, and
bound to `state.json` through `transition-state` before implementation can
begin.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_v3_intake_authority_binding/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_v3_intake_authority_binding/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_v3_intake_authority_binding/approval-snapshot.md

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

The intake package currently validates independently but does not establish
the v3 lifecycle lock. A package can be marked `SPEC_LOCKED` without a
matching state binding and authoritative lock event.

### Scope

- Extend the package schema and approval binding with `task_id`, `run_id`,
  `spec_version`, and `risk_decision_hash`.
- Require an exact candidate package hash and protected approval provenance.
- Record the lock through the existing hash-chained event store.
- Use `transition-state` as the only lifecycle writer and bind
  `state.json.spec_hash` to the package hash.
- Add focused regression coverage for valid and invalid bindings.

### Out of Scope

- A second specification artifact or approval workflow.
- Changes to the original research-review TOC.
- v2 compatibility, sandboxing, network restriction, external identity,
  signed releases, deployment control, or agent-specific adapters.

### Success Criteria

- Valid approval creates one locked package, one lock event, and matching
  state/package hashes.
- Missing, expired, mismatched, forged, or duplicate approvals fail closed.
- Direct state edits and package/state hash mismatches are rejected.
- Existing v3 lifecycle and full benchmark tests continue to pass.

### Dependencies

- Existing `spec-lock.sh` validation primitives.
- Existing `transition-state` and `event_store.py` hash-chain authority.
- Existing `HARNESS_PROVENANCE_KEY_FILE` provenance mechanism.

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

- The Change Package is the single specification authority.
- `state.json` is the sole lifecycle authority.
- `transition-state` is the sole lifecycle writer.
- `events.jsonl` remains append-only and hash chained.
- `current.md` and task-store status remain derived projections.

## Scope

### In Scope

- `.agent-harness/scripts/intake-control.sh`
- `.agent-harness/scripts/spec-lock.sh` only where shared validation is needed
- `.agent-harness/scripts/transition-state`
- `.agent-harness/scripts/event_store.py`
- focused harness regression tests

### Out of Scope

- The original TOC and the new reconciliation document
- Runtime isolation or external trust services

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: add exact package/run/task/provenance bindings
- [ ] Phase B: record lock event, transition state, and test fail-closed paths

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

Review required after focused tests and full harness verification.

## Risks

| Risk | Mitigation |
|---|---|
| Two lock mechanisms diverge | Keep one package authority and reuse existing validation only |
| State/event mismatch | Write through `transition-state` and verify the hash chain |
| Approval forgery | Require exact candidate hash and protected provenance |
