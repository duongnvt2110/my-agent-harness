---
task_id: implement_v3_contract_coverage_finalization_hardening
title: "Implement v3 contract coverage and finalization hardening"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: normal
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 3
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-16 11:29"
baseline_ref: null
file_map_approved: true
review_required: true
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
  - .agent-harness/policies/v3-contract.json
  - .agent-harness/scripts/check-finalization-authority.sh
  - .agent-harness/scripts/check-v3-contract-coverage.sh
  - .agent-harness/scripts/finalize-v3-run
  - .agent-harness/scripts/finalize-task.sh
  - .agent-harness/scripts/task.sh
  - .agent-harness/scripts/harness.sh
  - .agent-harness/scripts/workflow-dispatch.sh
  - .agent-harness/scripts/create-full-context.sh
  - .agent-harness/scripts/check-full-context.sh
  - .agent-harness/scripts/verify.sh
  - .agent-harness/tests/harness/**
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
spec_clarification_evidence: docs/evidence/implement_v3_contract_coverage_finalization_hardening/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_v3_contract_coverage_finalization_hardening/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_v3_contract_coverage_finalization_hardening/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_v3_contract_coverage_finalization_hardening/context-pack.md
working_memory_path: docs/evidence/implement_v3_contract_coverage_finalization_hardening/working-memory.md
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
  - id: task-benchmark
    type: automated
    command: "rtk env PATH=/Users/exe-macbook/.local/bin:$PATH rtk ./scripts/harness.sh benchmark --no-history --timeout 60"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: "docs/evidence/implement_v3_contract_coverage_finalization_hardening/benchmark.md"
completed_at: "2026-07-16 11:56"
---

# Execution Plan: Implement v3 contract coverage and finalization hardening

## Update History

Updated: 2026-07-16 11:30

## Goal

Implement the approved v3 contract-coverage and finalization-hardening plan.
Every blocking authority rule must map to implementation, denial, and
recovery evidence. Final human approval must be complete and provenance-bound;
direct task completion must be denied; every finalization entry point must use
the same v3 validation; and uncovered blocking rules must block verification.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_v3_contract_coverage_finalization_hardening/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_v3_contract_coverage_finalization_hardening/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_v3_contract_coverage_finalization_hardening/approval-snapshot.md

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

The current harness has multiple finalization and task-projection entry points.
Some requirements are documented but are not mechanically linked to every
entry point, denial test, or recovery test. This allows forgotten features and
alternate paths to pass the happy-path benchmark.

### Scope

Add the v3 contract registry and blocking coverage checker. Harden final human
approval, remove direct `mark-done` completion, unify v3 finalization context,
add state invariants and adversarial tests, and report uncovered rules in the
generated context.

### Out of Scope

No original TOC edits, v2 fallback, sandboxing, network restriction, external
identity, signed releases, deployment control, agent adapters, or human
approval inside remediation/recovery.

### Success Criteria

- Contract coverage reports 100% of blocking v3 rules.
- Direct `task.sh mark-done` is denied.
- Incomplete, mismatched, expired, reused, or unproven final approval fails.
- Direct and dispatched finalization have equivalent v3 provenance checks.
- State, denial, adversarial, and recovery tests pass.
- Benchmark, verification, and harness finalization pass.

### Dependencies

- Approved source plan: `my_docs/2026_07_16_v3_contract_coverage_and_finalization_hardening_plan.md`.
- Existing v3 authority model and completed authority-integrity fixes.
- One active harness task and no unrelated READY task activation.

## Implementation Slices

This single active task is executed in three slices: finalization authority
boundary; entry-point parity and executable contract coverage; and context,
adversarial tests, and the blocking verification gate. Each slice must pass
focused checks before the next slice begins.

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

- [ ] Phase A: Finalization authority boundary.
- [ ] Phase B: Entry-point parity and contract coverage.
- [ ] Phase C: Context, adversarial tests, and blocking verification gate.

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

Review is required for this normal-risk brownfield harness change. Human
approval is required before implementation through the active-plan approval
gate; remediation and recovery remain autonomous after execution begins.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
