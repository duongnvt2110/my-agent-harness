---
task_id: implement_deterministic_budget_routing
title: "Implement deterministic risk and run-budget routing"
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
approved_at: "2026-07-11 19:08"
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
spec_clarification_evidence: docs/evidence/implement_deterministic_budget_routing/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_deterministic_budget_routing/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_deterministic_budget_routing/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_deterministic_budget_routing/context-pack.md
working_memory_path: docs/evidence/implement_deterministic_budget_routing/working-memory.md
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
    evidence: "docs/evidence/implement_deterministic_budget_routing/plan-check.md"
completed_at: "2026-07-11 19:17"
---

# Execution Plan: Implement deterministic risk and run-budget routing

## Update History

Updated: 2026-06-04 16:40

## Goal

Derive deterministic risk routing and immutable per-run budgets from
observable evidence, preserving mandatory controls and sticky high-risk
classification.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_deterministic_budget_routing/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_deterministic_budget_routing/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_deterministic_budget_routing/approval-snapshot.md

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

The current guard evaluates supplied thresholds but does not calculate them
from risk evidence or persist routing metadata. Agents could otherwise choose
weak lanes or silently change behavior after budget exhaustion.

### Scope

Add a versioned budget policy and `calculate-run-budget` that invokes the
deterministic classifier, maps tiny/normal/high-risk to bounded metrics,
preserves high-risk stickiness, records immutable run-manifest metadata, and
explicitly denies model changes, verification weakening, scope expansion, and
failure-history resets at exhaustion. Add public routing and fixtures.

### Out of Scope

Dynamic model selection, human reclassification UX, and external billing
integration are separate controls.

### Success Criteria

- Clear low-risk evidence routes tiny; missing/ambiguous routes normal; any
  mandatory signal routes sticky high-risk.
- Budgets are deterministic, bounded, and immutable per run.
- Exhaustion produces PAUSE/DENY semantics without weakening controls.
- Focused fixtures, benchmark, full verification, review, and finalization
  pass.

### Dependencies

Use `classify-risk`, `risk-classification-v1.json`, `budget-guard`, policy
binding, and run identity contracts.

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

- Risk is computed from observable evidence; agent-requested risk is ignored.
- High-risk classification remains sticky until human reclassification.
- Budget exhaustion pauses/denies and never grants authority or changes gates.

## Scope

### In Scope

- `.agent-harness/policies/run-budget-v1.json`
- `.agent-harness/scripts/calculate-run-budget`
- `.agent-harness/scripts/harness.sh`
- `.agent-harness/tests/harness/test_budget_routing.sh`
- task-local evidence and schemas

### Out of Scope

- model/provider routing and billing

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: immutable policy and classification-to-budget mapping.
- [ ] Phase B: exhaustion invariants and sticky-risk fixtures.

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

Review is required: risk and budget routing affect authority and safety gates.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
