---
task_id: implement_release_fixture_inventory
title: "Implement release fixture inventory and audit"
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
approved_at: "2026-07-11 19:57"
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
  - policies/release-fixtures-v1.json
  - scripts/check-release-fixtures
  - tests/harness/test_release_fixture_inventory.sh
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
spec_clarification_evidence: docs/evidence/implement_release_fixture_inventory/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_release_fixture_inventory/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_release_fixture_inventory/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_release_fixture_inventory/context-pack.md
working_memory_path: docs/evidence/implement_release_fixture_inventory/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001: required v3 release fixtures have immutable IDs, commands, and evidence classes
  - AC-002: fixture audit rejects missing, duplicate, unknown, or unavailable fixture commands
  - AC-003: audit output is deterministic, hash-bound, and reports limitations without self-approval
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
    evidence: "docs/evidence/implement_release_fixture_inventory/plan-check.md"
  - id: focused-test
    type: automated
    command: "rtk ./tests/harness/test_release_fixture_inventory.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-002
      - AC-003
    evidence: "docs/evidence/implement_release_fixture_inventory/focused-test.md"
completed_at: "2026-07-11 20:07"
---

# Execution Plan: Implement release fixture inventory and audit

## Update History

Updated: 2026-07-11 20:00

## Goal

Create a versioned release-fixture manifest and read-only audit command. The
manifest names mandatory governance, ambiguity, permissions, recovery,
verification, finalization, security, and packaging fixtures with exact test
commands and evidence classes. The audit validates the manifest hash, required
IDs, command availability, and deterministic ordering; optional execution runs
the listed fixtures but never grants release authority.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_release_fixture_inventory/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_release_fixture_inventory/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_release_fixture_inventory/approval-snapshot.md

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

Release checks currently report aggregate benchmark counts without an explicit
proof that every named v3 release-blocking fixture exists and is runnable.

### Scope

Add the immutable fixture policy, audit command, public route, and focused tests
for manifest integrity and fail-closed handling.

### Out of Scope

No change to individual fixture behavior, release activation, signatures, or
external attestation is in scope.

### Success Criteria

All required fixture IDs are present exactly once; commands resolve inside the
harness; tampering or missing fixtures fails closed; and audit output includes
manifest hash, execution mode, and assurance limitations.

### Dependencies

Depends on existing harness test paths and release invariant terminology. The
manifest is control-plane data and must be treated as immutable once bound.

## Epic / Story / Task Breakdown

### Epic 1: explicit release proof inventory

Dependencies:

- Existing deterministic harness tests and release checks

Acceptance Criteria:

- Named fixtures are explicit, immutable, and auditable

Stories:

- Release fixture manifest and audit

Tasks:

- Implement manifest, checker, route, and regression fixtures

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

- [ ] Phase A: implement manifest and deterministic audit
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

Required: independent read-only review because release eligibility evidence is a
high-risk control-plane output.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
