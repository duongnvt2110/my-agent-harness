---
task_id: rename_completion_gate
title: "Rename completion judge to completion gate in governance TOC"
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
approved_at: "2026-07-15 15:27"
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
spec_clarification_evidence: docs/evidence/rename_completion_gate/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/rename_completion_gate/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/rename_completion_gate/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/rename_completion_gate/context-pack.md
working_memory_path: docs/evidence/rename_completion_gate/working-memory.md
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
    evidence: "docs/evidence/rename_completion_gate/plan-check.md"
completed_at: "2026-07-15 15:27"
---

# Execution Plan: Rename completion judge to completion gate in governance TOC

## Update History

Updated: 2026-06-04 16:40

## Goal

Rename `Completion Judge` to `Completion Gate` and clarify its deterministic
contract checks in the governance TOC.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/rename_completion_gate/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/rename_completion_gate/behavior-baseline.md
  approval_snapshot_path: docs/evidence/rename_completion_gate/approval-snapshot.md

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

The term judge implies an independent decision-maker, while completion must be
controlled by locked requirements and harness evidence.

### Scope

Update only the completion section and TOC history in the approved file.

### Out of Scope

Do not add a separate judge agent, model, or human approval shortcut.

### Success Criteria

- The TOC uses `Completion Gate`.
- The gate checks locked criteria and evidence but cannot change requirements.
- Only the approved TOC file is changed.

### Dependencies

The existing v3 authority and finalization model remains authoritative.

## Epic / Story / Task Breakdown

### Epic 1: Clarify completion authority

Dependencies:

- Existing v3 completion and finalization model.

Acceptance Criteria:

- Completion is a deterministic gate before human final review.

Stories:

- Replace judge language without adding a decision-making agent.

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

- Completion Gate evaluates locked acceptance criteria, evidence, scope, and
  snapshot integrity; it cannot change requirements or approve finalization.

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
