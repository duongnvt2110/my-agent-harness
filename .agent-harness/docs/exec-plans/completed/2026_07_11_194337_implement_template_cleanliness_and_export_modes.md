---
task_id: implement_template_cleanliness_and_export_modes
title: "Implement template cleanliness guard and export modes"
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
approved_at: "2026-07-11 19:29"
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
approved_files:
  - scripts/check-template-cleanliness
  - tests/harness/test_template_cleanliness.sh
  - scripts/export-harness-package.sh
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
spec_clarification_evidence: docs/evidence/implement_template_cleanliness_and_export_modes/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_template_cleanliness_and_export_modes/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_template_cleanliness_and_export_modes/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_template_cleanliness_and_export_modes/context-pack.md
working_memory_path: docs/evidence/implement_template_cleanliness_and_export_modes/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001: clean-template is the default export mode and contains no runtime or audit state
  - AC-002: source-snapshot and audit-snapshot are explicit, bounded modes with manifest identities
  - AC-003: cleanliness violations are detected with sanitized diagnostics and never repaired implicitly
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
    evidence: "docs/evidence/implement_template_cleanliness_and_export_modes/plan-check.md"
  - id: focused-test
    type: automated
    command: "rtk ./tests/harness/test_template_cleanliness.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-002
      - AC-003
    evidence: "docs/evidence/implement_template_cleanliness_and_export_modes/focused-test.md"
completed_at: "2026-07-11 19:43"
---

# Execution Plan: Implement template cleanliness guard and export modes

## Update History

Updated: 2026-07-11 19:35

## Goal

Add explicit `clean-template`, `source-snapshot`, and `audit-snapshot` export
modes, with `clean-template` remaining the default. Add a read-only
`check-template-cleanliness` command that detects forbidden runtime artifacts,
cache files, histories, locks, active pointers, and package-shape violations.
Mode and package identity must be recorded in the manifest.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_template_cleanliness_and_export_modes/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_template_cleanliness_and_export_modes/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_template_cleanliness_and_export_modes/approval-snapshot.md

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

Exports currently rely on implicit cleanup and have no reusable integrity
detector. Consumers cannot distinguish a clean reusable template from a source
or audit snapshot by authoritative metadata.

### Scope

Extend export argument parsing and manifest mode identity, add the cleanliness
checker and public route, and add focused fixtures for each mode and forbidden
artifact detection.

### Out of Scope

No signing, installation activation, package cryptography, or unrelated runtime
state redesign is in scope.

### Success Criteria

Default export passes cleanliness and package/install integrity. Explicit source
and audit modes are distinguishable and do not silently downgrade to clean.
Injected `.git`, cache, lock, active-plan, or evidence artifacts are rejected
without mutation.

### Dependencies

Depends on existing export/install manifest schemas and public dispatcher.
Clean mode must preserve existing tests and package shape.

## Epic / Story / Task Breakdown

### Epic 1: explicit export trust boundaries

Dependencies:

- Existing export and package-integrity contracts

Acceptance Criteria:

- Mode-specific package boundaries and deterministic cleanliness checks

Stories:

- Export mode and template cleanliness enforcement

Tasks:

- Implement mode parsing, checker, route, and fixtures

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

- [ ] Phase A: implement mode-aware export and read-only cleanliness checker
- [ ] Phase B: run focused/full/benchmark/harness/review/finalization gates

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

Required: independent read-only review because package boundaries and release
artifacts are high-risk control-plane outputs.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
