---
task_id: move_verifier_finalizer_to_functions
title: "Move verifier and finalizer from roles to harness functions"
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
approved_at: "2026-07-15 15:22"
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
  - my_docs/agent-harness-research-review-toc.md
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
spec_clarification_evidence: docs/evidence/move_verifier_finalizer_to_functions/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/move_verifier_finalizer_to_functions/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/move_verifier_finalizer_to_functions/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/move_verifier_finalizer_to_functions/context-pack.md
working_memory_path: docs/evidence/move_verifier_finalizer_to_functions/working-memory.md
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
    evidence: "docs/evidence/move_verifier_finalizer_to_functions/plan-check.md"
completed_at: "2026-07-15 15:23"
---

# Execution Plan: Move verifier and finalizer from roles to harness functions

## Update History

Updated: 2026-06-04 16:40

## Goal

Keep only Human and Agent as actors, and describe verification and finalization
as harness-controlled functions.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/move_verifier_finalizer_to_functions/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/move_verifier_finalizer_to_functions/behavior-baseline.md
  approval_snapshot_path: docs/evidence/move_verifier_finalizer_to_functions/approval-snapshot.md

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

The current role model can imply separate verifier and finalizer agents.

### Scope

Update the active role model and related verifier/finalizer wording in the
approved TOC; preserve the existing function sections.

### Out of Scope

Only the actor/function wording is in scope; implementation changes are out of
scope. Verification, evidence registration, recovery, state transition, and
finalization capabilities must remain.

### Success Criteria

- The actor list contains only Human and Agent.
- Verification and finalization remain documented as harness functions.
- Only the approved TOC file is changed.

### Dependencies

The existing v3 authority boundary remains authoritative.

## Epic / Story / Task Breakdown

### Epic 1: Simplify actor and function boundaries

Dependencies:

- Existing v3 role and authority model.

Acceptance Criteria:

- Verifier and Finalizer are not presented as separate agents.

Stories:

- Preserve their responsibilities in existing control-function sections,
  without creating separate verifier/finalizer agents or implementation
  changes that are out of scope for this TOC-only task.

Tasks:

- Edit and verify the approved TOC.


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

- Human and Agent are the only actors. Verification, finalization, recovery,
  state transition, and evidence registration remain harness functions.

## Scope

### In Scope

- The single approved TOC file.

### Out of Scope

- Implementation changes and all files outside the approved TOC.

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
