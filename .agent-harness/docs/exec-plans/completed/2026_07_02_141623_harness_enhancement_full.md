---
task_id: harness_enhancement_full
title: "Implement harness enhancements from review and closure idea"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: normal
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 1
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-02 13:55"
baseline_ref: ed416bc84d9ffe998d140243772ecc6e120186c1
file_map_approved: true
review_required: true
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
  - harness_state
approved_files:
  - .gitignore
  - docs/intake/.gitkeep
  - my_docs/README.md
  - benchmarks/**
  - tests/**
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
spec_clarification_evidence: docs/evidence/harness_enhancement_full/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/harness_enhancement_full/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/harness_enhancement_full/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/harness_enhancement_full/context-pack.md
working_memory_path: docs/evidence/harness_enhancement_full/working-memory.md
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
    evidence: "docs/evidence/harness_enhancement_full/plan-check.md"
completed_at: "2026-07-02 14:16"
---

# Execution Plan: Implement harness enhancements from review and closure idea

## Update History

Updated: 2026-07-02 14:02
Updated: 2026-07-02 13:55
Updated: 2026-06-04 16:40

## Goal

Implement the remaining harness enhancements from the review:

- make deterministic runner timeouts portable and correctly detected
- keep the benchmark and report docs aligned with the live benchmark flow
- remove the snapshot-mode `my_docs` file-map bypass
- allow finalization to auto-close completed stories and epics when possible
- keep the current harness contracts and verification flow stable

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/harness_enhancement_full/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/harness_enhancement_full/behavior-baseline.md
  approval_snapshot_path: docs/evidence/harness_enhancement_full/approval-snapshot.md

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

The harness still has a few gaps after the migration and review pass: the test
runner is not portable on macOS Bash, timeout detection is fragile, snapshot
file-map mode still bypasses `my_docs`, finalization does not close stories or
epics automatically, and the reports docs still point at the old score/release
artifacts.

### Scope

- Fix the harness test runner portability and timeout classification.
- Make finalization automatically close completed stories and epics when the
  linked task finishes.
- Enforce `my_docs` through the same file-map approval logic in snapshot mode.
- Update the benchmark/report docs to match the live benchmark outputs.
- Add regressions for the new closeout and runner behavior.

### Out of Scope

- Broader workflow redesign.
- Reworking the benchmark suite structure.
- Changing the public task contract format beyond the needed fixes.

### Success Criteria

- The benchmark suite passes.
- The test runner regression covers `/bin/bash` list mode and timeout mode.
- Finalization closes a story and epic automatically when the last task is
  completed.
- Snapshot file-map mode rejects unauthorized `my_docs` changes.
- The reports README matches the current benchmark artifacts.

### Dependencies

- Existing harness scripts and fixtures.
- The current benchmark and release harness expectations.

## Epic / Story / Task Breakdown

### Epic 1: Harness enhancements

Dependencies:

- Existing harness lifecycle scripts

Acceptance Criteria:

- Timeout, closeout, and file-map behaviors are stable and covered by tests.

Stories:

- Fix runner portability and benchmark timeout detection.
- Implement automatic epic/story closeout.
- Tighten file-map and report documentation.

Tasks:

- Replace `mapfile` usage and normalize timeout exit handling.
- Auto-close completed stories and epics during finalization.
- Remove the snapshot-mode `my_docs` bypass.
- Update report docs and regression tests.

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

- Use the current active plan as the implementation vehicle.
- Keep the changes within the harness namespace and test fixtures.

## Scope

### In Scope

- Runner portability, closeout automation, file-map enforcement, benchmark docs.

### Out of Scope

- Benchmark runner semantics.
- Story/epic closure semantics.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [x] Phase A: scope and implementation
- [ ] Phase B: verification and finalize

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

Review is required for this lane.

## Risks

| Risk | Mitigation |
|---|---|
| Harness behavior spans multiple scripts and test fixtures | Add focused regressions for each change and verify the benchmark suite. |
