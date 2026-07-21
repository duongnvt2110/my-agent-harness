---
task_id: implement_v3_intake_graph
title: "Implement v3 intake ownership and task acceptance graph"
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
approved_at: "2026-07-11 16:03"
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
spec_clarification_evidence: docs/evidence/implement_v3_intake_graph/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_v3_intake_graph/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_v3_intake_graph/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_v3_intake_graph/context-pack.md
working_memory_path: docs/evidence/implement_v3_intake_graph/working-memory.md
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
    evidence: "docs/evidence/implement_v3_intake_graph/plan-check.md"
completed_at: "2026-07-11 16:06"
---

# Execution Plan: Implement v3 intake ownership and task acceptance graph

## Update History

Updated: 2026-06-04 16:40

## Goal

Create one immutable intake record that owns requirements, binds to an exact
locked specification, and publishes a minimal task/acceptance-criterion graph
with precise AC-to-task-to-check traceability.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_v3_intake_graph/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_v3_intake_graph/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_v3_intake_graph/approval-snapshot.md

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

Requirements, task plans, and checks are currently independent artifacts with
no authoritative intake boundary or fail-closed impact calculation.

### Scope

Add intake creation and verification for canonical requirements, locked spec
hash, task graph, blocking ACs, dependency edges, and check producers. Reject
unknown references, missing mappings, mutable latest references, and incomplete
impact boundaries.

### Out of Scope

Interactive clarification UI, role capabilities, external attestations, and
full implementation scheduling remain later slices.

### Success Criteria

Valid intake graphs verify deterministically; changed ACs return direct tasks,
transitive dependents, and affected checks; incomplete traceability returns
`invalidates_all=true`; tampering or unknown references fail closed.

### Dependencies

The intake binds to a previously verified immutable specification lock and
uses content hashes rather than mutable names for artifacts.

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
