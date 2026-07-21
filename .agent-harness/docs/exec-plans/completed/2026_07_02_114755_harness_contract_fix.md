---
task_id: harness_contract_fix
title: "Fix harness contract consistency"
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
approved_at: "2026-07-02 11:15"
baseline_ref: ed416bc84d9ffe998d140243772ecc6e120186c1
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
  - .gitignore
  - my_docs/README.md
  - benchmarks/**
  - docs/**
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
spec_clarification_evidence: docs/evidence/harness_contract_fix/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/harness_contract_fix/work-alignment.md
adr_check_required: false
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/harness_contract_fix/adr-review.md
context_pack_required: false
context_pack_path: docs/evidence/harness_contract_fix/context-pack.md
working_memory_path: docs/evidence/harness_contract_fix/working-memory.md
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
    evidence: "docs/evidence/harness_contract_fix/plan-check.md"
completed_at: "2026-07-02 11:47"
---

# Execution Plan: Fix harness contract consistency

## Update History

Updated: 2026-07-02 11:50
Updated: 2026-07-02 11:42
Updated: 2026-07-02 11:15
Updated: 2026-06-04 16:40

## Goal

Make the harness contract consistent with the live workflow:

- remove the unconditional `my_docs/` file-map bypass
- make `verification_mode=none` internally consistent
- align review requirements with lane policy
- preserve the current tiny-lane execution flow

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/harness_contract_fix/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/harness_contract_fix/behavior-baseline.md
  approval_snapshot_path: docs/evidence/harness_contract_fix/approval-snapshot.md

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

The current harness lets `my_docs/` bypass file-map enforcement, accepts a
`verification_mode=none` plan shape that still requires `required_checks`, and
leaves lane review policy split between validators.

### Scope

- Enforce approved scopes or approved files for `my_docs/` changes.
- Make `check-active-plan-contract.sh` treat `verification_mode=none`
  consistently.
- Ensure lane policy and review policy agree for `normal` and `high_risk`
  plans.
- Keep the current tiny-lane verification path working.

### Out of Scope

- Changing the benchmark report format.
- Reworking the full-context or work-alignment evidence model.
- Broad harness redesign beyond the contract inconsistencies above.

### Success Criteria

- `check-file-map.sh` rejects `my_docs/` changes unless explicitly approved.
- `check-active-plan-contract.sh` passes for the active plan and rejects the
  inconsistent `verification_mode=none` shape.
- Review enforcement matches the lane policy.
- The harness verification command still completes for the active plan.

### Dependencies

- Existing harness scripts and plan frontmatter helpers.
- The active plan baseline at `ed416bc84d9ffe998d140243772ecc6e120186c1`.

## Epic / Story / Task Breakdown

### Epic 1: <name>

Dependencies:

- Active harness contract helpers

Acceptance Criteria:

- Contract validators agree on file-map, verification mode, and review policy.

Stories:

- Update the file-map gate.
- Update the active-plan contract gate.
- Verify the harness still passes for the active plan.

Tasks:

- Remove the `my_docs/` bypass from file-map enforcement.
- Fix `verification_mode=none` handling in the plan contract.
- Align review requirement checks with lane policy.

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

- Use the current tiny-lane task as the implementation vehicle.
- Keep the fix limited to harness contract validation and verification flow.

## Scope

### In Scope

- File-map validation for `my_docs/`.
- Active-plan contract validation.
- Review policy consistency.

### Out of Scope

- New benchmark behaviors.
- Large verification pipeline redesign.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [x] Phase A: contract alignment
- [ ] Phase B: verification and finalize

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

Review is not required for the tiny lane.

## Risks

| Risk | Mitigation |
|---|---|
| Hidden plan assumptions in the current tiny task | Keep the code change narrow and verify the live harness gates. |
