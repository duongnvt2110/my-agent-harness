---
task_id: reconcile_stale_task_plan_projections
title: "reconcile_stale_task_plan_projections"
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
approved_at: "2026-07-13 10:06"
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
  - .agent-harness/scripts/check-task-plan-consistency.sh
  - .agent-harness/scripts/check-script-interface.sh
  - .agent-harness/scripts/harness.sh
  - .agent-harness/tests/harness/test_task_plan_consistency.sh
  - .agent-harness/policies/task-plan-exceptions.json
  - .agent-harness/docs/tasks/*/implementation-plan.md
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
spec_clarification_evidence: docs/evidence/reconcile_stale_task_plan_projections/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/reconcile_stale_task_plan_projections/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/reconcile_stale_task_plan_projections/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/reconcile_stale_task_plan_projections/context-pack.md
working_memory_path: docs/evidence/reconcile_stale_task_plan_projections/working-memory.md
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
    evidence: "docs/evidence/reconcile_stale_task_plan_projections/plan-check.md"
completed_at: "2026-07-13 10:10"
---

# Execution Plan: reconcile_stale_task_plan_projections

## Update History

Updated: 2026-07-13 10:30
Updated: 2026-06-04 16:40

## Goal

Make task-plan front matter and the authoritative JSONL task ledger agree.
Plans for terminal ledger tasks must be terminal, and nonterminal plans must
have a matching nonterminal ledger record. Add a deterministic read-only
checker and public CLI route so this invariant is enforced in release tests.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/reconcile_stale_task_plan_projections/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/reconcile_stale_task_plan_projections/behavior-baseline.md
  approval_snapshot_path: docs/evidence/reconcile_stale_task_plan_projections/approval-snapshot.md

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

Seven plan artifacts remain APPROVED or VERIFIED while their authoritative
task records are DONE. This permits stale plan metadata to misrepresent
lifecycle authority and undermines resume/finalization audits.

### Scope

- Add a checker that compares every task plan front matter with tasks.jsonl.
- Require terminal plan state for DONE/CANCELLED/ROLLED_BACK ledger records.
- Require a matching nonterminal ledger record for nonterminal plans.
- Expose the checker through the stable harness CLI and script interface.
- Reconcile the seven stale plans to COMPLETED with an audit note.
- Add positive and negative regression coverage.

### Out of Scope

- Changing lifecycle authority or rewriting historical evidence.
- Reclassifying task outcomes or deleting task plans.
- Broad changes to task-store schema beyond consistency validation.

### Success Criteria

- `check-task-plan-consistency.sh` passes on the repository state.
- A tampered plan status and an orphan plan both fail closed.
- The public CLI and script interface expose the checker.
- Full harness and benchmark suites remain green.
- All seven previously stale plans have terminal metadata and an audit note.

### Dependencies

- Authoritative `.agent-harness/docs/tasks/tasks.jsonl`.
- Existing plan front-matter schema and harness path resolver.

## Epic / Story / Task Breakdown

### Epic 1: Task-plan authority consistency

Dependencies:

- tasks.jsonl remains the sole task lifecycle projection authority.

Acceptance Criteria:

- AC-001: plan and ledger statuses agree for every task artifact.
- AC-002: mismatch and orphan fixtures are rejected deterministically.

Stories:

- Add consistency checker and regression fixtures.

Tasks:

- Implement checker, CLI route, reconciliation note, and tests.

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

- `.agent-harness/scripts/check-task-plan-consistency.sh`
- CLI/interface registration and focused tests
- Seven stale plan front-matter reconciliations

### Out of Scope

- Any change to `state.json`, transition journaling, or event bytes.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: checker, interface route, fixtures, and plan reconciliation
- [ ] Phase B: focused/full/benchmark/review/finalization gates

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

Review is required because this closes a lifecycle-authority consistency gap.

## Risks

| Risk | Mitigation |
|---|---|
| Historical plan metadata may be ambiguous | Fail closed and preserve an explicit audit note. |
| Checker could become a second authority | Read-only comparison; tasks.jsonl remains authoritative. |
