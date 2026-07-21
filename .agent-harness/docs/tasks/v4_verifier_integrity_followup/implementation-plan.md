---
task_id: v4_verifier_integrity_followup
title: "Harden standalone v4 verification and add finalization integration coverage"
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
approved_at: "2026-07-18 18:40"
baseline_ref: null
file_map_approved: true
review_required: false
evidence_required: true
requires_rollback_plan: false
requires_human_approval: false
v4_verification_required: false
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
approved_scopes:
  - harness_core
  - harness_docs
  - app_tests
approved_files:
  - .agent-harness/scripts/check-v4-verification.sh
  - .agent-harness/tests/harness/test_v4_finalization_authority.sh
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
spec_clarification_evidence: docs/evidence/v4_verifier_integrity_followup/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/v4_verifier_integrity_followup/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/v4_verifier_integrity_followup/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/v4_verifier_integrity_followup/context-pack.md
working_memory_path: docs/evidence/v4_verifier_integrity_followup/working-memory.md
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
    command: "cd /Users/exe-macbook/duong/ai/harness-scratch-template/.agent-harness && bash harness.sh next"
    allow_raw_command: true
    raw_command_reason: "The required-check subprocess does not inherit the interactive rtk wrapper; this invokes the harness entrypoint directly."
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: "docs/evidence/v4_verifier_integrity_followup/plan-check.md"
completed_at: "2026-07-18 18:45"
---

# Execution Plan: Harden standalone v4 verification and add finalization integration coverage

## Update History

Updated: 2026-07-18 23:30

## Goal

Ensure the standalone v4 verifier validates the workspace binding itself and
add end-to-end finalization coverage for accepted and forged v4 verdicts.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/v4_verifier_integrity_followup/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/v4_verifier_integrity_followup/behavior-baseline.md
  approval_snapshot_path: docs/evidence/v4_verifier_integrity_followup/approval-snapshot.md

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

The standalone v4 verdict checker trusts a supplied workspace hash, and the
repository lacks a real finalization regression test for v4 authority.

### Scope

Recompute the workspace hash in the v4 verdict checker and add a fixture that
executes finalization with a valid proposal and rejects a forged verdict.

### Out of Scope

Do not change v3 lifecycle semantics, provider integrations, sandboxing,
network controls, identity, releases, deployment, or multi-agent behavior.

### Success Criteria

- A forged workspace hash is rejected by the standalone checker.
- A valid v4 proposal can pass the finalization authority path.
- A forged v4 verdict cannot finalize a task.
- The full harness regression suite remains green.

### Dependencies

Use the existing verifier and finalizer contracts without adding dependencies.

## Epic / Story / Task Breakdown

### Epic 1: v4 verification integrity follow-up

Dependencies:

- Existing v4 verifier and v3 finalization contracts.

Acceptance Criteria:

- The repository snapshot digest is independently recomputed.
- Finalization integration accepts only harness-produced v4 verification.

Stories:

- Harden standalone verification and finalization coverage.

Tasks:

- Recompute workspace hash in the standalone checker.
- Add valid and forged finalization integration cases.

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

- Keep v3 state transitions unchanged.
- Reuse the existing v4 workspace snapshot algorithm.

## Scope

### In Scope

- `.agent-harness/scripts/check-v4-verification.sh`
- `.agent-harness/tests/harness/test_v4_finalization_authority.sh`
- task-local evidence under `docs/evidence/v4_verifier_integrity_followup/`

### Out of Scope

- New runtime providers, OS enforcement, network or identity controls, and
  unrelated backlog tasks.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: add independent workspace binding validation.
- [ ] Phase B: add end-to-end finalization acceptance and rejection tests.

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
