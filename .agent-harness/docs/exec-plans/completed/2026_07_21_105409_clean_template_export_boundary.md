---
task_id: clean_template_export_boundary
title: "Clean template export for business repositories"
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
approved_at: "2026-07-21 10:53"
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
spec_clarification_evidence: docs/evidence/clean_template_export_boundary/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/clean_template_export_boundary/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/clean_template_export_boundary/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/clean_template_export_boundary/context-pack.md
working_memory_path: docs/evidence/clean_template_export_boundary/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - clean-template excludes repository-specific context and benchmark fixtures
  - source-snapshot and audit-snapshot retain their existing export behavior
  - export regression checks cover the reduced clean-template boundary
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
    evidence: "docs/evidence/clean_template_export_boundary/plan-check.md"
  - id: export-regression
    type: automated
    command: "rtk ./tests/harness/test_export_harness_package.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - clean-template excludes repository-specific context and benchmark fixtures
    evidence: "docs/evidence/clean_template_export_boundary/export-regression.md"
completed_at: "2026-07-21 10:54"
---

# Execution Plan: Clean template export for business repositories

## Update History

Updated: 2026-07-21 00:00

## Goal

Make the default `clean-template` export suitable for copying into a business
repository by excluding scratch-repository context and benchmark fixtures while
preserving the reusable harness package. Leave non-clean export modes unchanged.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/clean_template_export_boundary/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/clean_template_export_boundary/behavior-baseline.md
  approval_snapshot_path: docs/evidence/clean_template_export_boundary/approval-snapshot.md

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

The current clean export copies generated repository-intelligence/context files
and benchmark fixtures, causing a business repository export to include
scratch-repository material and unnecessary size.

### Scope

Update the existing export script and existing export regression test. For
`clean-template`, omit `.agent-harness/docs/context/**` and
`.agent-harness/benchmarks/**`; retain the harness scripts, tests, policies,
recipes, runtime bootstrap, and reusable template docs.

### Out of Scope

Do not create new scripts, change source-snapshot or audit-snapshot behavior,
remove reusable harness scripts, or mutate the source repository during export.

### Success Criteria

The clean export contains no context or benchmark files, remains installable,
and passes package integrity and template cleanliness checks. Existing target
files remain preserved.

### Dependencies

The public entry point remains `bash .agent-harness/harness.sh export` and all
shell commands use `rtk` where supported.

## Epic / Story / Task Breakdown

### Epic 1: Portable clean export

Dependencies:

- Existing export implementation and regression test

Acceptance Criteria:

- Clean-template output contains only portable harness material

Stories:

- Narrow clean-template source selection and verify output

Tasks:

- Patch existing export script and test

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

- Clean-template is intentionally smaller and business-repository safe.

## Scope

### In Scope

- Existing export script and existing export regression test only.

### Out of Scope

- No new scripts or changes to alternate export modes.

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
