---
task_id: implement_enforcement_gate
title: "Implement high-risk technical enforcement gate"
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
approved_at: "2026-07-11 16:35"
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
spec_clarification_evidence: docs/evidence/implement_enforcement_gate/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_enforcement_gate/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_enforcement_gate/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_enforcement_gate/context-pack.md
working_memory_path: docs/evidence/implement_enforcement_gate/working-memory.md
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
    evidence: "docs/evidence/implement_enforcement_gate/plan-check.md"
completed_at: "2026-07-11 16:36"
---

# Execution Plan: Implement high-risk technical enforcement gate

## Update History

Updated: 2026-06-04 16:40

## Goal

Enforce a technical control gate that denies high-risk and irreversible
mutations when required sandbox, adapter, network, or worktree controls are
not technically available.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_enforcement_gate/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_enforcement_gate/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_enforcement_gate/approval-snapshot.md

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

The harness can label AUDIT_ONLY but lacks one centralized prevention gate that
blocks unsafe high-risk operations before dispatch.

### Scope

Add enforcement-check command accepting risk, operation class, enforcement
mode, and declared control capabilities. Permit low-risk/read-only actions in
AUDIT_ONLY, but deny high-risk mutation, network, integration, rollback, and
finalization without all mandatory controls.

### Out of Scope

Implementing the sandbox or network proxy itself remains a later adapter task.

### Success Criteria

High-risk missing controls fail before execution; human approval cannot bypass
the gate; AUDIT_ONLY limitations are explicit; supported low-risk inspection
remains usable.

### Dependencies

Control declarations are untrusted input until registered; unknown controls
fail closed.

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
