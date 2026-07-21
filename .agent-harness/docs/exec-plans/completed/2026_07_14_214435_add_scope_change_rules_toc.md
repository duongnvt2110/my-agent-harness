---
task_id: add_scope_change_rules_toc
title: "Document material and incidental scope changes"
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
approved_at: 2026-07-14 22:25
baseline_ref: ed416bc84d9ffe998d140243772ecc6e120186c1
file_map_approved: true
review_required: true
evidence_required: true
requires_rollback_plan: false
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
spec_clarification_evidence: docs/evidence/add_scope_change_rules_toc/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/add_scope_change_rules_toc/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/add_scope_change_rules_toc/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/add_scope_change_rules_toc/context-pack.md
working_memory_path: docs/evidence/add_scope_change_rules_toc/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001: TOC distinguishes incidental file additions from material scope expansion and defines their authority handling.
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
    evidence: "docs/evidence/add_scope_change_rules_toc/plan-check.md"
completed_at: "2026-07-14 21:44"
---

# Execution Plan: Document material and incidental scope changes

## Update History

Updated: 2026-07-14 22:25

## Goal

Document incidental versus material scope changes and their autonomous and
human-review boundaries.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/add_scope_change_rules_toc/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/add_scope_change_rules_toc/behavior-baseline.md
  approval_snapshot_path: docs/evidence/add_scope_change_rules_toc/approval-snapshot.md

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

Describe the user or system problem the task solves. Use concrete language,
not placeholder text.

### Scope

Describe what is in scope for this task with specific boundaries.

### Out of Scope

Describe what is explicitly out of scope. Do not leave this blank.

### Success Criteria

List the outcomes that prove the task is complete. Use measurable checks.

### Dependencies

Describe any relevant dependencies or constraints.

## Epic / Story / Task Breakdown

### Epic 1: Scope-change governance documentation

Dependencies:

- Existing scope, Change Package, final-review, and successor-run sections.

Acceptance Criteria:

- AC-001: The TOC defines material scope signals and incidental-file handling.

Stories:

- Document scope classification and review behavior.

Tasks:

- Update the approved TOC only.

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

- Incidental files may be added provisionally and reviewed at finalization.
- Material behavior changes require a successor package and human approval.
- The agent may propose classification; the harness flags uncertainty and scope signals.

## Scope

### In Scope

- Scope classification, material signals, and final-review handling.

### Out of Scope

- Runtime implementation, new commands, and unrelated documentation.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [x] Phase A: Add scope-change rules to the TOC.
- [ ] Phase B: Verify and finalize through the harness.

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

Review is required because this adds a scope-governance rule.

## Risks

| Risk | Mitigation |
|---|---|
| Agent misclassifies a material change as incidental | Harness flags API, data, security, architecture, acceptance, and other material signals for human review. |
