---
task_id: implement_complete_checkpoint_contract
title: "Implement complete portable checkpoint contract"
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
approved_at: "2026-07-11 17:37"
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
spec_clarification_evidence: docs/evidence/implement_complete_checkpoint_contract/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_complete_checkpoint_contract/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_complete_checkpoint_contract/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_complete_checkpoint_contract/context-pack.md
working_memory_path: docs/evidence/implement_complete_checkpoint_contract/working-memory.md
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
    evidence: "docs/evidence/implement_complete_checkpoint_contract/plan-check.md"
completed_at: "2026-07-11 17:43"
---

# Execution Plan: Implement complete portable checkpoint contract

## Update History

Updated: 2026-06-04 16:40

## Goal

Make checkpoints portable, content-addressed workspace-state contracts that
capture all state required to restore and validate a run without destroying
pre-existing work.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_complete_checkpoint_contract/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_complete_checkpoint_contract/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_complete_checkpoint_contract/approval-snapshot.md

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

The current checkpoint stores copied files and a minimal toolchain marker but
does not identify tracked/staged/untracked/generated state, controlling
specification or policy, lifecycle/event position, pending operations, or
unexpected extra files at restore time.

### Scope

Extend checkpoint creation, verification, and restoration with explicit
workspace/repository identity, file-state classes, toolchain fingerprints,
specification/policy/workflow/event/pending-operation bindings, manifest hash,
journaled restore, and fail-closed extra/missing/different content checks.
Support dirty/non-Git workspaces only when complete manifest restoration is
possible; otherwise deny high-risk checkpoint creation.

### Out of Scope

External recovery plans, cloud snapshot storage, and production rollback
compensation remain separate controls.

### Success Criteria

- Manifest captures repository/workspace identity, file classes, hashes,
  toolchain, authority hashes, event position, and pending operations.
- Verification rejects missing, extra, changed, or schema-incompatible state.
- Restore is journaled, idempotent, and refuses non-empty destinations or
  pre-existing user work.
- High-risk/rollback-dependent creation fails without complete restorable
  metadata.
- Focused fixtures, benchmark, full verification, review, and finalization
  pass.

### Dependencies

Use state/spec/policy/run-event schemas, evidence minimization, writer/worktree
identity, and existing checkpoint CLI routes.

## Task Boundary

This is one governed executable task; registry relationships are not
duplicated in the active plan.

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

- A checkpoint is a portable workspace contract, not a Git-only convenience.
- Unknown or incomplete restoration boundaries fail closed.
- Restoration never deletes pre-existing user work and is journaled.

## Scope

### In Scope

- `.agent-harness/scripts/create-checkpoint.sh`
- `.agent-harness/scripts/verify-checkpoint.sh`
- `.agent-harness/scripts/restore-checkpoint.sh`
- `.agent-harness/tests/harness/test_checkpoint_contract.sh`
- task-local evidence and schemas

### Out of Scope

- remote snapshots and external recovery plans

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: complete manifest and authority bindings.
- [ ] Phase B: journaled exact restoration and dirty/non-Git fail-closed
  behavior.

## Verification

Check types are stack-agnostic:

- `setup`: prepares dependencies or services; command required, RTK-wrapped,
  and always blocking.
- `automated`: runs a command; command required, timeout required, and
  RTK-wrapped.

```bash
rtk ./scripts/harness.sh next
rtk ./scripts/harness.sh benchmark --no-history --timeout 60
rtk .agent-harness/scripts/create-full-context.sh && rtk .agent-harness/harness.sh verify
```

## Review

Review is required: checkpoint restoration controls rollback and workspace
authority.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
