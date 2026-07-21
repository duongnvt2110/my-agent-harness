---
task_id: implement_sandbox_adapter_enforcement
title: "Implement technical sandbox adapter enforcement"
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
approved_at: "2026-07-11 17:06"
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
spec_clarification_evidence: docs/evidence/implement_sandbox_adapter_enforcement/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_sandbox_adapter_enforcement/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_sandbox_adapter_enforcement/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_sandbox_adapter_enforcement/context-pack.md
working_memory_path: docs/evidence/implement_sandbox_adapter_enforcement/working-memory.md
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
    evidence: "docs/evidence/implement_sandbox_adapter_enforcement/plan-check.md"
completed_at: "2026-07-11 17:12"
---

# Execution Plan: Implement technical sandbox adapter enforcement

## Update History

Updated: 2026-06-04 16:40

## Goal

Provide a public, profile-driven sandbox runner that technically prevents
unauthorized filesystem and network effects when the host supports a known
enforcement adapter, and fails closed to AUDIT_ONLY when it does not.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_sandbox_adapter_enforcement/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_sandbox_adapter_enforcement/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_sandbox_adapter_enforcement/approval-snapshot.md

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

The harness currently has an enforcement declaration gate and a bootstrap
fixture, but no reusable public runner that binds a command to a profile and
proves the runtime boundary. Post-edit checks alone cannot support enforcement
claims, and unsupported runtimes must not authorize high-risk mutation.

### Scope

Implement `run-in-sandbox`, versioned sandbox profiles, public CLI routing,
profile/hash validation, constrained environment setup, deny-by-default
network policy, and fixtures proving canonical checkout write prevention,
network denial, profile mismatch rejection, and AUDIT_ONLY fail-closed
behavior. Bind execution to exact run/session/task/specification/policy and
record sanitized launch metadata.

### Out of Scope

Linux container orchestration, Windows adapters, external signing, production
deployment, and unrestricted network capability issuance remain later slices.

### Success Criteria

- Supported macOS sandbox execution prevents canonical checkout writes and
  network access for the declared profile.
- Unsupported or forced-AUDIT_ONLY runtimes report the limitation and deny
  high-risk mutation, integration, rollback, and finalization.
- Profile and policy hashes are exact and mismatches fail closed.
- Launch records contain no credentials or raw environment values.
- Focused fixtures, benchmark, full verification, review, and finalization
  pass.

### Dependencies

Use `enforcement-gate`, capability/session bindings, trusted-time policy,
writer/worktree identity, and the existing bootstrap sandbox conventions.

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

- Technical prevention is required for ENFORCED claims; detection is not
  prevention.
- AUDIT_ONLY is transparent and cannot authorize high-risk mutation.
- Network is denied by default inside every profile.

## Scope

### In Scope

- `.agent-harness/scripts/run-in-sandbox`
- `.agent-harness/policies/sandbox-profiles.yaml`
- `.agent-harness/scripts/harness.sh`
- `.agent-harness/tests/harness/test_sandbox_adapter.sh`
- task-local evidence and schemas

### Out of Scope

- non-macOS enforcement adapters
- external network capability implementation

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: implement profile validation, hash binding, and macOS
  sandbox-exec launch path with sanitized environment.
- [ ] Phase B: add fail-closed unsupported-runtime behavior and negative
  security fixtures.

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

Review is required: this task changes technical authority and enforcement
claims.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
