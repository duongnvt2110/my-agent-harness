---
task_id: align_actor_function_fields
title: "Align actor and function field terminology in governance TOC"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: tiny
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 1
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-15 15:39"
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
  - my_docs/agent-harness-research-review-toc.md
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
spec_clarification_evidence: docs/evidence/align_actor_function_fields/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/align_actor_function_fields/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/align_actor_function_fields/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/align_actor_function_fields/context-pack.md
working_memory_path: docs/evidence/align_actor_function_fields/working-memory.md
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
    evidence: "docs/evidence/align_actor_function_fields/plan-check.md"
completed_at: "2026-07-15 15:40"
---

# Execution Plan: Align actor and function field terminology in governance TOC

## Update History

Updated: 2026-06-04 16:40

## Goal

Replace remaining `Role requirements` and `Active role` wording with actor and
function terminology in the governance TOC.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/align_actor_function_fields/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/align_actor_function_fields/behavior-baseline.md
  approval_snapshot_path: docs/evidence/align_actor_function_fields/approval-snapshot.md

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

The lifecycle and state sections still imply a multi-role authority model.

### Scope

Update only the active terminology and related examples in the approved TOC.

### Out of Scope

No lifecycle, schema, capability, or authority behavior changes are in scope.

### Success Criteria

- Active terminology uses actor/function requirements.
- Examples identify actor and harness function without new roles.
- Only the approved TOC file is changed.

### Dependencies

The existing v3 state authority model remains authoritative.

## Epic / Story / Task Breakdown

### Epic 1: Align actor/function fields

Dependencies:

- Existing lifecycle and state authority sections.

Acceptance Criteria:

- No active `Role requirements` or `Active role` wording remains.

Stories:

- Clarify actor and function fields without changing behavior.

Tasks:

- Edit and verify the approved TOC.


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

- Use `active_actor` and `active_function`; transition guards use authority and
  function conditions rather than separate roles.

## Scope

### In Scope

- The single approved TOC file.

### Out of Scope

- Implementation changes and all files outside the approved TOC.

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
