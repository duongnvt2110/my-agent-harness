---
task_id: v3_core_bootstrap_contract_and_baseline
title: "Protect v3-core bootstrap contract and dirty baseline"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: high_risk
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 2
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-10 14:19"
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
spec_clarification_evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/v3_core_bootstrap_contract_and_baseline/context-pack.md
working_memory_path: docs/evidence/v3_core_bootstrap_contract_and_baseline/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001
  - AC-002
  - AC-003
  - AC-004
  - AC-005
  - AC-006
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: dirty-git-baseline
    type: automated
    command: "rtk ./tests/harness/test_dirty_git_baseline_snapshot.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-002
      - AC-003
    evidence: "docs/evidence/v3_core_bootstrap_contract_and_baseline/dirty-git-baseline.md"
  - id: baseline-regressions
    type: automated
    command: "rtk ./tests/harness/test_create_baseline_snapshot.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-002
      - AC-003
    evidence: "docs/evidence/v3_core_bootstrap_contract_and_baseline/baseline-regressions.md"
  - id: snapshot-file-map
    type: automated
    command: "rtk ./tests/harness/test_check_file_map_snapshot.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-002
      - AC-003
    evidence: "docs/evidence/v3_core_bootstrap_contract_and_baseline/snapshot-file-map.md"
  - id: baseline-report-contract
    type: automated
    command: "rtk rg -n 'workflow_version|public_cli|package_shape|known_gaps|release_invariants' docs/reports/vnext-baseline.md docs/TEST_MATRIX.md"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-004
      - AC-005
    evidence: "docs/evidence/v3_core_bootstrap_contract_and_baseline/baseline-report-contract.md"
  - id: harness-regression-suite
    type: automated
    command: "rtk ./tests/harness/run_all.sh"
    blocking: true
    timeout_seconds: 900
    covers:
      - AC-001
      - AC-002
      - AC-003
      - AC-006
    evidence: "docs/evidence/v3_core_bootstrap_contract_and_baseline/harness-regression-suite.md"
  - id: release-check
    type: automated
    command: "rtk ./scripts/harness.sh release-check"
    blocking: true
    timeout_seconds: 900
    covers:
      - AC-004
      - AC-005
      - AC-006
    evidence: "docs/evidence/v3_core_bootstrap_contract_and_baseline/release-check.md"
completed_at: "2026-07-10 22:55"
---

# Execution Plan: Protect v3-core bootstrap contract and dirty baseline

## Update History

Updated: 2026-07-10 14:17
Updated: 2026-06-04 16:40

## Goal

Protect the v3-core bootstrap with a complete dirty-worktree snapshot baseline,
an exact v2 compatibility report, and a release-blocking invariant matrix
before any v3 authority implementation begins.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: snapshot
  behavior_tracking: existing_tests

  git_ref: null
  snapshot_path: docs/evidence/v3_core_bootstrap_contract_and_baseline/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/v3_core_bootstrap_contract_and_baseline/behavior-baseline.md
  approval_snapshot_path: docs/evidence/v3_core_bootstrap_contract_and_baseline/approval-snapshot.md

  created_before_execution: true

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

The legacy baseline detector always selects Git `HEAD` when a repository is
present, even if the checkout is dirty. In this repository, `HEAD` predates the
active `.agent-harness` namespace migration, so later tasks would absorb or
misattribute pre-existing tracked, staged, untracked, hidden, generated, and
symlink state. The snapshot generator also drops `.github` directories. The
current release report uses an aggregate score and does not express the
non-compensable v3-core invariants.

### Scope

Make dirty Git repositories choose content snapshots; make snapshot creation
and comparison represent hidden non-Git directories and symlink identities
without reading external targets; add regression coverage; record the current
v2 CLI/schema/test/package baseline and known gaps; and add the v3-core
release-invariant matrix to the harness test documentation.

### Out of Scope

Do not implement workflow version 3, state transitions, event chains, policy
authority, intake/spec locks, AC verification, journaled finalization, v2
migration, immutable installation, adapters, worktrees, sandboxing, network
access, or later release trains. Do not alter pre-existing dirty user work.

### Success Criteria

- Dirty Git workspaces select snapshot change tracking instead of `HEAD`.
- Snapshots include hidden non-Git directories and symlink identity while
  excluding `.git` internals and external symlink targets.
- Snapshot comparison detects post-baseline changes without deleting or
  absorbing pre-existing work.
- `docs/reports/vnext-baseline.md` records exact workflow, CLI, schema, test,
  package, and known-gap evidence for the current v2 harness.
- `docs/TEST_MATRIX.md` records every v3-core zero-tolerance release invariant
  independently from performance scoring.
- Focused baseline tests, the full v2 suite, and release check pass.

### Dependencies

Depends on the finalized vNext approved design, ADR-0004, the pre-edit snapshot
for this task, and the current v2 harness as bootstrap validator. The task is
mandatory high-risk but changes only baseline/release protection; no v3 action
may claim enforcement from this slice.

## Epic / Story / Task Breakdown

### Epic 1: Protect the v3-core bootstrap baseline

Dependencies:

- Requires the finalized vNext governance contract and preservation of the
  current dirty namespace migration.

Acceptance Criteria:

- Dirty, hidden, and symlink repository state is captured deterministically.
- Existing v2 behavior and package shape have inspectable baseline evidence.
- Correctness and security invariants cannot be offset by aggregate scores.

Stories:

- Establish trustworthy change attribution and release proof before v3 code.

Tasks:

- Implement dirty-worktree baseline protection and v3-core invariant evidence.

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

- Existing dirty work is authoritative pre-task state and must be preserved.
- Snapshot mode records symlink identity, not external target contents.
- Correctness and security invariants are independently release-blocking.
- Aggregate quality or performance scores cannot compensate for invariant
  failure.
- This task remains v2 bootstrap work and grants no v3 execution authority.

## Scope

### In Scope

- `scripts/detect-change-baseline.sh`
- `scripts/create-baseline-snapshot.sh`
- `scripts/check-baseline-snapshot.sh`
- `scripts/check-file-map.sh`
- `tests/harness/test_dirty_git_baseline_snapshot.sh`
- Existing focused baseline tests when compatibility updates are required.
- `docs/reports/vnext-baseline.md`
- `docs/TEST_MATRIX.md`

### Out of Scope

- All workflow-version-3 runtime and authority implementation.
- Any change to application or external project data.
- Cleanup, revert, or commit of the existing namespace migration.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: fix dirty-worktree and snapshot completeness behavior with
  focused regression tests.
- [ ] Phase B: capture exact v2 compatibility, package, and known-gap evidence.
- [ ] Phase C: define release-blocking v3-core invariants and run full bootstrap
  verification.

## Verification

Run focused dirty baseline tests first, then the complete v2 harness regression
suite and release check. The baseline report must record the exact commands and
results rather than infer compatibility from a score.

```bash
rtk ./scripts/verify.sh
```

## Review

Independent review is required. The reviewer must compare the implementation
to the approved design, inspect preservation of existing dirty state, and
confirm the report does not overclaim v3 enforcement.

## Rollback Plan

Restore only the task-owned scripts, tests, and documentation from the task
snapshot. Preserve all pre-existing dirty migration content. If snapshot
completeness cannot be made deterministic without reading external symlink
targets or weakening exclusions, stop and retain the v2 behavior with a
documented blocker.

## Risks

| Risk | Mitigation |
|---|---|
| Snapshot consumes external or sensitive symlink data | Hash link text and type only; never follow the target. |
| Dirty work is mistaken for task output | Select a pre-edit content snapshot whenever Git status is non-clean. |
| Hidden control files remain omitted | Exclude only Git internals and test representative `.github` content. |
| Candidate harness validates itself | Preserve v2-focused fixtures and require independent review of reports and diffs. |
| Aggregate score masks an invariant failure | Make every correctness/security invariant independently blocking. |
