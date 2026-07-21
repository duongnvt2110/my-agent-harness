---
task_id: implement_policy_binding_artifact
title: "Implement immutable policy binding artifacts"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: high_risk
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 1
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-11 16:06"
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
spec_clarification_evidence: docs/evidence/implement_policy_binding_artifact/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_policy_binding_artifact/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_policy_binding_artifact/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_policy_binding_artifact/context-pack.md
working_memory_path: docs/evidence/implement_policy_binding_artifact/working-memory.md
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
    evidence: "docs/evidence/implement_policy_binding_artifact/plan-check.md"
completed_at: "2026-07-11 16:07"
---

# Execution Plan: Implement immutable policy binding artifacts

## Update History

Updated: 2026-06-04 16:40

## Goal

Persist an immutable, schema-validated policy binding for one exact intake,
task, run, policy bundle, and enforcement mode.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_policy_binding_artifact/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_policy_binding_artifact/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_policy_binding_artifact/approval-snapshot.md

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

Policy binding currently emits transient JSON and does not establish a durable
control-plane snapshot or reject unknown policy schema/version content.

### Scope

Validate policy bundle schema and canonicalization metadata, persist a binding
artifact with exact hash identities, and refuse overwrite or malformed bundles.

### Out of Scope

Emergency revocation, capability issuance, and full policy decision routing
remain later slices.

### Success Criteria

Binding artifacts are immutable, hash-bound, schema-valid, and include intake,
task, run, enforcement mode, and policy identities; tampering and overwrite
fail closed.

### Dependencies

Unknown policy schemas and versions fail closed; AUDIT_ONLY is reported rather
than presented as technical enforcement.

## Task Boundary

This is one governed executable task; registry relationships are not duplicated
in the active plan.

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
