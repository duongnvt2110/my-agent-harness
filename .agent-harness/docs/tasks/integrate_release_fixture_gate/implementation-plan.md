---
task_id: integrate_release_fixture_gate
title: "Integrate release fixture audit into blocking invariants"
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
approved_at: "2026-07-11 20:08"
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
  - scripts/release-invariants.sh
  - tests/harness/test_release_invariant_fixture_gate.sh
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
spec_clarification_evidence: docs/evidence/integrate_release_fixture_gate/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/integrate_release_fixture_gate/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/integrate_release_fixture_gate/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/integrate_release_fixture_gate/context-pack.md
working_memory_path: docs/evidence/integrate_release_fixture_gate/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001: release invariants invoke the versioned fixture audit as a blocking check
  - AC-002: fixture audit failures prevent release pass without fallback or score compensation
  - AC-003: release reports identify fixture manifest hash and assurance limitations
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
    evidence: "docs/evidence/integrate_release_fixture_gate/plan-check.md"
  - id: focused-test
    type: automated
    command: "rtk ./tests/harness/test_release_invariant_fixture_gate.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-002
      - AC-003
    evidence: "docs/evidence/integrate_release_fixture_gate/focused-test.md"
completed_at: "2026-07-11 20:14"
---

# Execution Plan: Integrate release fixture audit into blocking invariants

## Update History

Updated: 2026-07-11 20:10

## Goal

Make `release-invariants.sh` invoke the immutable release-fixture audit and
fail closed when the manifest is missing, tampered, or incomplete. The release
report must include the fixture manifest hash and explicitly state that fixture
evidence is independent validation input, not self-authorization.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/integrate_release_fixture_gate/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/integrate_release_fixture_gate/behavior-baseline.md
  approval_snapshot_path: docs/evidence/integrate_release_fixture_gate/approval-snapshot.md

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

The fixture inventory would otherwise be informational and could be omitted by
the release gate, violating release-blocking invariant requirements.

### Scope

Update release invariants, add a focused failure/pass fixture, and preserve
existing trusted-prior and package checks.

### Out of Scope

No change to fixture definitions, package signing, or release score semantics is
in scope.

### Success Criteria

Release invariants pass only when fixture audit passes; tampering the manifest
causes a non-zero result; and successful output contains the manifest hash.

### Dependencies

Depends on `check-release-fixtures` and the current release invariant runner.
No audit-only fallback may produce a release pass.

## Epic / Story / Task Breakdown

### Epic 1: blocking release fixture gate

Dependencies:

- Versioned release fixture inventory and existing release invariants

Acceptance Criteria:

- Fixture completeness is a release-blocking invariant

Stories:

- Integrate fixture audit into release gate

Tasks:

- Implement invocation, report binding, and regression fixture

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

- [ ] Phase A: wire audit into release invariants
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

Required: independent read-only review because release eligibility is a
high-risk control-plane decision.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
