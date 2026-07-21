---
task_id: implement_declarative_workflow_recipes
title: "Implement declarative workflow recipes"
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
approved_at: "2026-07-11 19:04"
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
approved_files:
  - recipes/bugfix.yaml
  - recipes/feature.yaml
  - recipes/refactor.yaml
  - recipes/migration.yaml
  - recipes/review-only.yaml
  - recipes/harness-change.yaml
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
spec_clarification_evidence: docs/evidence/implement_declarative_workflow_recipes/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_declarative_workflow_recipes/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_declarative_workflow_recipes/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_declarative_workflow_recipes/context-pack.md
working_memory_path: docs/evidence/implement_declarative_workflow_recipes/working-memory.md
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
    evidence: "docs/evidence/implement_declarative_workflow_recipes/plan-check.md"
completed_at: "2026-07-11 19:05"
---

# Execution Plan: Implement declarative workflow recipes

## Update History

Updated: 2026-06-04 16:40

## Goal

Add immutable, versioned declarative workflow recipes and a fail-closed loader
that validates recipe states, roles, verification, checkpoint, approval, and
policy requirements without weakening global controls.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_declarative_workflow_recipes/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_declarative_workflow_recipes/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_declarative_workflow_recipes/approval-snapshot.md

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

The harness has workflow rules embedded across shell scripts but no reusable
recipe artifact. Untrusted or malformed workflow definitions could otherwise
expand scope, bypass lifecycle gates, or silently weaken verification.

### Scope

Add versioned recipes for bugfix, feature, refactor, migration, review-only,
and harness-change workflows plus `load-recipe`. Validate schema,
canonicalization, required states/roles, verification/checkpoint/approval
policies, immutable recipe hashes, and monotonic strengthening against global
requirements. Add public routing and negative/positive fixtures.

### Out of Scope

Dynamic scripting in recipe files, arbitrary command execution, model choice,
policy grants, and recipe mutation are out of scope.

### Success Criteria

- All six recipes load with exact hashes and declared schema versions.
- Unknown fields, missing required controls, invalid states, and weakening
  global policy are rejected.
- Recipe loading is read-only and safe to rerun.
- Focused fixtures, benchmark, full verification, review, and finalization
  pass.

### Dependencies

Use state transitions, risk classification, enforcement gate, checkpoint,
verifier, approval, and policy bundle contracts.

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

- Recipes are untrusted declarative data until schema and policy validated.
- A recipe may strengthen global policy but never weaken it.
- Recipe artifacts are immutable and hash-bound.

## Scope

### In Scope

- `.agent-harness/recipes/*.yaml`
- `.agent-harness/scripts/load-recipe`
- `.agent-harness/scripts/harness.sh`
- `.agent-harness/tests/harness/test_recipe_loader.sh`
- task-local evidence and schemas

### Out of Scope

- recipe-defined commands or policy grants

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: recipe artifacts and canonical loader.
- [ ] Phase B: policy-strengthening and negative-security fixtures.

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

Review is required: recipes influence lifecycle and control routing.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
