---
task_id: implement_verifier_adapter_enforcement
title: "Implement capability-bound verifier adapter"
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
approved_at: "2026-07-11 17:14"
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
spec_clarification_evidence: docs/evidence/implement_verifier_adapter_enforcement/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_verifier_adapter_enforcement/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_verifier_adapter_enforcement/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_verifier_adapter_enforcement/context-pack.md
working_memory_path: docs/evidence/implement_verifier_adapter_enforcement/working-memory.md
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
    evidence: "docs/evidence/implement_verifier_adapter_enforcement/plan-check.md"
completed_at: "2026-07-11 17:19"
---

# Execution Plan: Implement capability-bound verifier adapter

## Update History

Updated: 2026-06-04 16:40

## Goal

Make normal and high-risk verifier evidence originate from a fresh,
capability-bound, read-only Verifier session whose exact identities and
assurance limitations are technically validated before submission.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_verifier_adapter_enforcement/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_verifier_adapter_enforcement/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_verifier_adapter_enforcement/approval-snapshot.md

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

Existing verdict validation checks JSON claims but does not bind evidence
production to a capability or consume a one-time verifier session. A Primary
could otherwise self-report a Verifier role.

### Scope

Implement a capability-bound verifier adapter with immutable session and
submission records, exact intake/task/run/specification/policy/snapshot
freshness checks, role/session separation, read-only enforcement, model and
provider independence reporting, and AUDIT_ONLY restrictions. Add public
routing and negative/positive fixtures.

### Out of Scope

Model hosting, external attestation, human approval UX, and platform sandbox
implementation are separate controls.

### Success Criteria

- Primary capabilities cannot start or submit verifier evidence.
- A verifier session is fresh, read-only, exact-context, and single-use.
- High-risk AUDIT_ONLY isolation-dependent verification is denied.
- Model/provider independence is reported honestly and cannot be inferred.
- Focused tests, benchmark, full verification, review, and finalization pass.

### Dependencies

Use `capability`, `check-verifier-verdict`, `run-in-sandbox`, and existing
policy/risk contracts.

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

- Role identity is technical only when capability validation gates adapter
  entry and submission.
- High-risk model independence is either proven or explicitly reported as
  unavailable; it is never silently assumed.

## Scope

### In Scope

- `.agent-harness/scripts/verifier-adapter`
- `.agent-harness/scripts/harness.sh`
- `.agent-harness/tests/harness/test_verifier_adapter.sh`
- task-local evidence and schemas

### Out of Scope

- external signer and human approval UI

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: capability-bound session issuance and immutable context record.
- [ ] Phase B: single-use verdict submission and assurance enforcement.

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

Review is required: verifier authority and finalization evidence are
high-risk control-plane behavior.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
