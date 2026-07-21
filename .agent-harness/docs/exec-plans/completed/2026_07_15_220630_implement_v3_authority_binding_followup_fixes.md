---
task_id: implement_v3_authority_binding_followup_fixes
title: "implement_v3_authority_binding_followup_fixes"
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
approved_at: "2026-07-15 22:02"
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
spec_clarification_evidence: docs/evidence/implement_v3_authority_binding_followup_fixes/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_v3_authority_binding_followup_fixes/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_v3_authority_binding_followup_fixes/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_v3_authority_binding_followup_fixes/context-pack.md
working_memory_path: docs/evidence/implement_v3_authority_binding_followup_fixes/working-memory.md
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
    evidence: "docs/evidence/implement_v3_authority_binding_followup_fixes/plan-check.md"
completed_at: "2026-07-15 22:06"
---

# Execution Plan: implement_v3_authority_binding_followup_fixes

## Update History

Updated: 2026-07-15 23:59

## Goal

Implement the approved v3 authority-binding follow-up fix plan in sequential
phases without changing the original TOC or adding excluded runtime features.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_v3_authority_binding_followup_fixes/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_v3_authority_binding_followup_fixes/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_v3_authority_binding_followup_fixes/approval-snapshot.md

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

The current package binding works, but parallel specification artifacts,
weak implementation-entry checks, stale approval use, incomplete provenance,
and incomplete clarification/traceability validation remain.

### Scope

Implement the approved phases from
`my_docs/2026_07_15_v3_authority_binding_followup_fix_plan.md`: consolidate
public authority paths, enforce package/state gates, revalidate lock approval,
freeze and hash sources, and validate clarification/traceability links.

### Out of Scope

Do not modify the original research-review TOC in this task. Do not add v2
compatibility, sandboxing, network restriction, external identity providers,
signed releases, deployment control, or agent-specific runtime adapters.
Adapter-section cleanup is a separate future documentation task.

### Success Criteria

All five implementation phases have focused tests; standalone spec-lock paths
cannot become authority; implementation requires a valid package hash;
approval/provenance and source snapshots are immutable; traceability is
complete; existing v3 tests and benchmark remain green.

### Dependencies

Approved fix plan, existing v3 state/event authority, `transition-state`,
`event_store.py`, provenance helpers, and current intake-control tests.

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

- [ ] Phase A: consolidate authority paths and enforce lifecycle hash gates
- [ ] Phase B: enforce lock approval expiry/provenance semantics
- [ ] Phase C: implement immutable source snapshots and external captures
- [ ] Phase D: implement clarification and normative traceability validation

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

Review required after focused tests, full benchmark, and harness verification.

## Risks

| Risk | Mitigation |
|---|---|
| Scope grows into excluded controls | Keep the approved exclusions unchanged |
| Source payloads become too large | Use one authority package plus immutable supporting snapshots |
| Existing v3 regressions | Run focused tests after each phase and the full benchmark before finalization |
