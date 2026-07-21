---
task_id: reconcile_v4_core_implementation_contract
title: "Reconcile the v4 plan into an implementation-ready v4-core contract"
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
approved_at: "2026-07-18 13:29"
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
approved_files:
  - my_docs/agent-harness-v4-detailed-implementation-plan.md
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
spec_clarification_evidence: docs/evidence/reconcile_v4_core_implementation_contract/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/reconcile_v4_core_implementation_contract/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/reconcile_v4_core_implementation_contract/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/reconcile_v4_core_implementation_contract/context-pack.md
working_memory_path: docs/evidence/reconcile_v4_core_implementation_contract/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - The v4 plan explicitly defines the v4-core scope and excludes deferred integrations.
  - The plan contains ordered implementation slices with files, inputs, outputs, tests, and exit gates.
  - The plan defines context-preservation and handoff requirements for every implementation slice.
  - The original v3 control-plane decisions and TOC are preserved.
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: plan-contract-check
    type: automated
    command: rtk rg -n 'v4-core|Context Preservation Contract|Deferred' ../my_docs/agent-harness-v4-detailed-implementation-plan.md
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: "docs/evidence/reconcile_v4_core_implementation_contract/plan-check.md"
completed_at: "2026-07-18 13:31"
---

# Execution Plan: Reconcile the v4 plan into an implementation-ready v4-core contract

## Update History

Updated: 2026-06-04 16:40

## Goal

Update the v4 research plan into an implementation-ready v4-core contract
without changing the v3 implementation or original TOC.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/reconcile_v4_core_implementation_contract/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/reconcile_v4_core_implementation_contract/behavior-baseline.md
  approval_snapshot_path: docs/evidence/reconcile_v4_core_implementation_contract/approval-snapshot.md

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

The existing v4 plan combines core control-plane enhancements with deferred
runtime, sandbox, provider, and multi-agent integrations. That breadth can
cause agents to lose settled decisions and implement out-of-scope features.

### Scope

Update only the named v4 plan. Add explicit scope, exclusions, ordered slices,
context-preservation rules, and machine-checkable exit gates.

### Out of Scope

Do not implement v4 code. Do not modify the v3 harness, the original TOC, or
any external runtime integration.

### Success Criteria

The document is detailed enough for an implementation agent to execute one
slice at a time and resume from a handoff without reconstructing decisions.

### Dependencies

The plan must remain compatible with the current v3 repository-local,
AUDIT_ONLY control system.

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
