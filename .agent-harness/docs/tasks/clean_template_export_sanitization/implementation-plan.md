---
task_id: clean_template_export_sanitization
title: "Sanitize clean-template export contents"
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
approved_at: "2026-07-21 11:00"
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
spec_clarification_evidence: docs/evidence/clean_template_export_sanitization/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/clean_template_export_sanitization/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/clean_template_export_sanitization/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/clean_template_export_sanitization/context-pack.md
working_memory_path: docs/evidence/clean_template_export_sanitization/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - clean-template contains only generic reusable harness files
  - clean-template manifest contains no source repository provenance
  - source-snapshot and audit-snapshot behavior remains unchanged
  - existing export integrity and cleanliness checks pass
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
    evidence: "docs/evidence/clean_template_export_sanitization/plan-check.md"
  - id: export-regression
    type: automated
    command: "rtk ./tests/harness/test_export_harness_package.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - clean-template contains only generic reusable harness files
    evidence: "docs/evidence/clean_template_export_sanitization/export-regression.md"
completed_at: "2026-07-21 11:03"
---

# Execution Plan: Sanitize clean-template export contents

## Update History

Updated: 2026-07-21 00:00

## Goal

Sanitize the default clean-template export so a business repository receives
only generic reusable harness material, without scratch-repository history,
development docs, or source Git provenance.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/clean_template_export_sanitization/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/clean_template_export_sanitization/behavior-baseline.md
  approval_snapshot_path: docs/evidence/clean_template_export_sanitization/approval-snapshot.md

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

The current clean-template removes runtime residue but still exports source
repository identity, historical ADRs, scratch-oriented root docs, and internal
development documentation.

### Scope

Adjust the existing export script, integrity checks, and regression tests. Clean
exports should include the public harness, operational scripts, policies,
recipes, runtime bootstrap, tests, and generic templates only. Alternate export
modes remain unchanged.

### Out of Scope

Do not create scripts, change alternate export modes, or modify source files in
the business repository. Do not remove reusable runtime or policy contracts.

### Success Criteria

The clean export has no source commit/status metadata, historical decision
records, scratch root docs, development plans, or internal prompt docs; it
passes package/install integrity and template cleanliness checks.

### Dependencies

Use the existing public export command and preserve the current output merge
behavior for caller-provided target directories.

## Epic / Story / Task Breakdown

### Epic 1: Portable clean export

Dependencies:

- Existing export and integrity scripts

Acceptance Criteria:

- Clean export is generic and provenance-free

Stories:

- Curate clean export inputs and validate the package

Tasks:

- Patch existing scripts and tests

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

- Clean-template is a reusable package for business repositories.

## Scope

### In Scope

- Existing export/integrity scripts and regression tests.

### Out of Scope

- No new scripts or alternate-mode changes.

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
