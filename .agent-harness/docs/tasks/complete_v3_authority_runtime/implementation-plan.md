---
task_id: complete_v3_authority_runtime
title: "Implement complete v3 authority runtime and remove legacy fallback"
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
approved_at: "2026-07-15 16:41"
baseline_ref: ed416bc84d9ffe998d140243772ecc6e120186c1
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
  - runtime/v3-workflow.json
  - runtime/state.json
  - runtime/events.jsonl
  - runtime/current.md
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
spec_clarification_evidence: docs/evidence/complete_v3_authority_runtime/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/complete_v3_authority_runtime/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/complete_v3_authority_runtime/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/complete_v3_authority_runtime/context-pack.md
working_memory_path: docs/evidence/complete_v3_authority_runtime/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001: The public harness path dispatches v3-only authority, rejects legacy or mixed authority artifacts, and uses canonical v3 lifecycle state without v2 fallback.
  - AC-002: v3 state transitions and append-only event-chain integrity are enforced by focused regression tests.
  - AC-003: The v3 runtime reports its actual implementation and assurance status without legacy-v2 claims.
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
    evidence: "docs/evidence/complete_v3_authority_runtime/plan-check.md"
completed_at: "2026-07-15 16:52"
---

# Execution Plan: Implement complete v3 authority runtime and remove legacy fallback

## Update History

Updated: 2026-07-15 19:10

## Goal

Implement the first complete-v3 runtime slice: v3-only public dispatch,
canonical lifecycle authority, legacy-artifact rejection, and truthful runtime
status reporting. Preserve existing compliant event-chain behavior.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/complete_v3_authority_runtime/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/complete_v3_authority_runtime/behavior-baseline.md
  approval_snapshot_path: docs/evidence/complete_v3_authority_runtime/approval-snapshot.md

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

The repository still defaults to legacy v2/current.md authority and reports
`legacy-v2`, while the TOC requires v3-only state authority with no fallback.

### Scope

Update the public harness dispatcher/status path, v3 state validation and
transition policy, and focused tests needed to prove v3 authority exclusivity.

### Out of Scope

Do not implement external identity, sandboxing, network restriction, signed
releases, deployment control, or agent-specific adapters in this slice.
Do not change unrelated application files or the human-owned TOC.

### Success Criteria

The v3 dispatcher is the only normal public path; legacy and mixed artifacts
fail closed; state and event-chain tests pass; runtime status truthfully reports
v3; and the focused v3 suite passes.

### Dependencies

The active TOC is the governing contract. Existing v3 event-store and
projection code should be preserved where compliant; old tests that assert v2
authority must be replaced with v3 contract tests.

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
