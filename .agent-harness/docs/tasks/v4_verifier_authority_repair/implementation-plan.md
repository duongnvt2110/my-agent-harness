---
task_id: v4_verifier_authority_repair
title: "Make v4 verification authoritative and detect working-tree changes"
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
approved_at: "2026-07-18 14:44"
baseline_ref: null
file_map_approved: true
review_required: false
evidence_required: true
requires_rollback_plan: false
requires_human_approval: false
v4_verification_required: true
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
approved_scopes:
  - harness_core
  - harness_docs
  - app_tests
approved_files:
  - .agent-harness/scripts/verify-proposal.sh
  - .agent-harness/scripts/check-v4-verification.sh
  - .agent-harness/scripts/harness.sh
  - .agent-harness/scripts/finalize-task.sh
  - .agent-harness/tests/harness/test_v4_slice_4_independent_verification.sh
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
spec_clarification_evidence: docs/evidence/v4_verifier_authority_repair/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/v4_verifier_authority_repair/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/v4_verifier_authority_repair/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/v4_verifier_authority_repair/context-pack.md
working_memory_path: docs/evidence/v4_verifier_authority_repair/working-memory.md
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
    raw_command_reason: "The required-check subprocess cannot execute the interactive rtk wrapper; the harness entrypoint is still invoked directly for this local plan check."
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: "docs/evidence/v4_verifier_authority_repair/plan-check.md"
completed_at: "2026-07-18 14:55"
---

# Execution Plan: Make v4 verification authoritative and detect working-tree changes

## Update History

Updated: 2026-07-18 23:10

## Goal

Make the v4 independent verifier authoritative at finalization and make its
workspace snapshot detect tracked working-tree edits and untracked files.
Preserve the v3 lifecycle and repository-local AUDIT_ONLY boundary.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/v4_verifier_authority_repair/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/v4_verifier_authority_repair/behavior-baseline.md
  approval_snapshot_path: docs/evidence/v4_verifier_authority_repair/approval-snapshot.md

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

The v4 verifier currently hashes the Git index instead of the working tree,
and finalization still consumes the legacy v3 verdict path. This can allow a
changed or untracked source file to evade the v4 snapshot and can leave the
v4 authoritative verdict unused at finalization.

### Scope

Update the v4 proposal verifier, finalization integration, and harness tests.
Use a deterministic repository snapshot that includes tracked file contents,
untracked files, paths, and file modes while excluding volatile harness
runtime output. Bind the finalization decision to the v4 verifier result.

### Out of Scope

OS isolation, network controls, identity, signed releases, provider adapters,
deployment, multi-agent orchestration, v2 support, and unrelated deferred
backlog tasks remain out of scope.

### Success Criteria

- A tracked working-tree content change causes a proposal verification failure.
- An untracked source file causes a proposal verification failure.
- A forged agent success cannot produce a finalizable v4 verdict.
- Finalization rejects missing, failed, or non-authoritative v4 verdicts.
- Existing v3 lifecycle and all existing harness tests remain green.

### Dependencies

The repair must preserve the current v3 state machine and use the existing
repository-local AUDIT_ONLY enforcement boundary. No new dependency is needed.

## Epic / Story / Task Breakdown

### Epic 1: v4 verifier authority repair

Dependencies:

- Existing v3 finalization and verifier schemas.

Acceptance Criteria:

- Snapshot comparison rejects tracked and untracked working-tree mutations.
- Only a harness-produced v4 verification result can authorize finalization.
- Regression and full harness verification checks pass.

Stories:

- Harden workspace snapshot and verifier authority.

Tasks:

- Update workspace snapshot hashing and add mutation regression tests.
- Wire v4 verification into finalization and test forged-agent rejection.
- Keep sandbox, network, identity, release, provider, and multi-agent features
  excluded from this v4 verifier repair.

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

- `.agent-harness/scripts/verify-proposal.sh`
- `.agent-harness/scripts/harness.sh`
- `.agent-harness/scripts/finalize-task.sh`
- `.agent-harness/scripts/finalize-v3-run`
- `.agent-harness/tests/harness/`
- `.agent-harness/docs/evidence/v4_verifier_authority_repair/`

### Out of Scope

- OS sandboxing, network restriction, external identity, signed releases,
  provider adapters, deployment control, and multi-agent orchestration.
- Replacing the v3 state machine or changing the original research TOC.
- Unrelated READY tasks generated from the deferred long plan.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

The repair is limited to the two review findings. The v4 verdict must be
validated by the existing finalization path, while v3 lifecycle transitions
remain unchanged.

## Phases

- [ ] Phase A: implement content-aware workspace snapshot and regression tests.
- [ ] Phase B: integrate v4 verification with finalization and regression test
  forged-agent rejection.

## Verification

Check types are stack-agnostic:

- `setup`: prepares dependencies or services; command required, RTK-wrapped,
  and always blocking.
- `automated`: runs a command; command required, timeout required, and
  RTK-wrapped.

```bash
rtk .agent-harness/tests/harness/test_v4_slice_4_independent_verification.sh
rtk .agent-harness/tests/harness/run_all.sh
rtk .agent-harness/harness.sh verify
```

## Review

State whether review is required for this lane.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
