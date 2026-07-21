---
task_id: implement_independent_release_attestation
title: "Require independent prior-release validation for harness release"
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
approved_at: "2026-07-11 17:27"
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
spec_clarification_evidence: docs/evidence/implement_independent_release_attestation/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_independent_release_attestation/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_independent_release_attestation/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_independent_release_attestation/context-pack.md
working_memory_path: docs/evidence/implement_independent_release_attestation/working-memory.md
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
    evidence: "docs/evidence/implement_independent_release_attestation/plan-check.md"
completed_at: "2026-07-11 17:35"
---

# Execution Plan: Require independent prior-release validation for harness release

## Update History

Updated: 2026-06-04 16:40

## Goal

Require every harness release candidate to be independently exercised by a
trusted prior release or protected external validator before release
activation, while preserving explicit assurance limitations and package
identity evidence.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_independent_release_attestation/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_independent_release_attestation/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_independent_release_attestation/approval-snapshot.md

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

The candidate harness currently runs its own release fixtures and package
checks but can therefore become the sole authority that verifies and packages
its own control-plane changes.

### Scope

Add an independent attestation command that invokes a trusted prior release
against the candidate, binds both package hashes, records fixture and
compatibility results, and blocks activation when the prior validator is
missing, ambiguous, or failing. Integrate the attestation requirement into
`release-check` with an explicit audit-only diagnostic mode.

### Out of Scope

External signing infrastructure, secure bootstrapping of the first release,
and deployment orchestration remain separate controls.

### Success Criteria

- Release activation fails without an exact trusted prior validator.
- Candidate and prior package hashes are immutable and recorded together.
- Prior validation failure or base/package ambiguity blocks release.
- Audit-only diagnostics never claim release eligibility.
- Focused fixtures, benchmark, full verification, review, and finalization
  pass.

### Dependencies

Use `release-invariants`, package export/integrity, install integrity, CLI
dispatch, and AUDIT_ONLY reporting contracts.

## Task Boundary

This is one governed executable task; registry relationships are not
duplicated in the active plan.

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

- The candidate may provide supporting evidence but cannot be its own sole
  release authority.
- Missing trusted prior validation is a hard release block, not a warning.
- Local prior validation is reported as tamper evidence, not external trust.

## Scope

### In Scope

- `.agent-harness/scripts/release-attest`
- `.agent-harness/scripts/release-check.sh`
- `.agent-harness/scripts/harness.sh`
- `.agent-harness/tests/harness/test_release_attestation.sh`
- task-local evidence and schemas

### Out of Scope

- signing service and secure bootstrap authority

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: exact prior/candidate package identity and independent fixture
  execution.
- [ ] Phase B: release-check integration and negative-security fixtures.

## Verification

Check types are stack-agnostic:

- `setup`: prepares dependencies or services; command required, RTK-wrapped,
  and always blocking.
- `automated`: runs a command; command required, timeout required, and
  RTK-wrapped.

```bash
rtk ./scripts/harness.sh next
rtk ./scripts/harness.sh benchmark --no-history --timeout 60
rtk .agent-harness/scripts/create-full-context.sh && rtk .agent-harness/harness.sh verify
```

## Review

Review is required: this changes the bootstrap trust boundary and release
eligibility authority.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
