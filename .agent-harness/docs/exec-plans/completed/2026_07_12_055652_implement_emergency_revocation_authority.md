---
task_id: implement_emergency_revocation_authority
title: "Implement emergency revocation authority"
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
approved_at: "2026-07-12 05:49"
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
  - scripts/emergency-revoke
  - scripts/capability.sh
  - scripts/approval.sh
  - tests/harness/test_emergency_revocation.sh
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
spec_clarification_evidence: docs/evidence/implement_emergency_revocation_authority/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_emergency_revocation_authority/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_emergency_revocation_authority/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_emergency_revocation_authority/context-pack.md
working_memory_path: docs/evidence/implement_emergency_revocation_authority/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001: immutable emergency revocations bind scope, reason, expiry, and hash
  - AC-002: capability and approval validation fail closed for matching revocations
  - AC-003: revocations can deny but never grant authority and report sanitized limitations
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
    evidence: "docs/evidence/implement_emergency_revocation_authority/plan-check.md"
  - id: focused-test
    type: automated
    command: "rtk ./tests/harness/test_emergency_revocation.sh"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-002
      - AC-003
    evidence: "docs/evidence/implement_emergency_revocation_authority/focused-test.md"
completed_at: "2026-07-12 05:56"
---

# Execution Plan: Implement emergency revocation authority

## Update History

Updated: 2026-07-12 09:00

## Goal

Add an immutable emergency-revocation artifact and bind it to capability and
approval validation through an optional control-plane revocation path. Matching
run/task/spec/policy/artifact scopes deny authority immediately; emergency
records may restrict or invalidate but never grant authority.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_emergency_revocation_authority/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_emergency_revocation_authority/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_emergency_revocation_authority/approval-snapshot.md

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

Existing capabilities and approvals can remain valid until ordinary expiry even
when emergency policy must immediately reduce authority across active runs.

### Scope

Add issue/check commands, capability and approval revocation checks, public route,
and focused fixtures for matching, nonmatching, tampering, and immutable records.

### Out of Scope

No emergency authority grant, automatic workspace rollback, or external policy
distribution is in scope.

### Success Criteria

Matching revocations cause non-zero validation; nonmatching artifacts remain
valid; tampered revocations fail closed; and no revocation path grants an
operation.

### Dependencies

Depends on existing capability/approval hashes and trusted control-plane time.
Revocation artifacts are immutable and contain no credentials.

## Epic / Story / Task Breakdown

### Epic 1: emergency authority reduction

Dependencies:

- Existing capability and contextual approval validators

Acceptance Criteria:

- Emergency policy can deny across active runs without granting authority

Stories:

- Revocation artifact and validator binding

Tasks:

- Implement issue/check, integrations, and fixtures

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

- [ ] Phase A: implement artifact and validator checks
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

Required: independent read-only review because emergency revocation is a
high-risk authority boundary.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
