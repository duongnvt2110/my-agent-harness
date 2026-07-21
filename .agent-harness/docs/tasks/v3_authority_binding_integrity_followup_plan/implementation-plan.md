---
task_id: v3_authority_binding_integrity_followup_plan
title: "v3_authority_binding_integrity_followup_plan"
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
approved_at: "2026-07-15 22:15"
baseline_ref: null
file_map_approved: true
review_required: false
evidence_required: true
requires_rollback_plan: false
requires_human_approval: false
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: false
task_backward_compatibility_required: true
approved_scopes:
  - harness_docs
approved_files:
  - my_docs/2026_07_16_v3_authority_integrity_followup_fix_plan.md
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
spec_clarification_evidence: docs/evidence/v3_authority_binding_integrity_followup_plan/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/v3_authority_binding_integrity_followup_plan/work-alignment.md
adr_check_required: true
adr_index: .agent-harness/docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/v3_authority_binding_integrity_followup_plan/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/v3_authority_binding_integrity_followup_plan/context-pack.md
working_memory_path: docs/evidence/v3_authority_binding_integrity_followup_plan/working-memory.md
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
    evidence: "docs/evidence/v3_authority_binding_integrity_followup_plan/plan-check.md"
completed_at: "2026-07-15 22:15"
---

# Execution Plan: v3_authority_binding_integrity_followup_plan

## Update History

Updated: 2026-07-16 00:40
Updated: 2026-07-16 00:35

## Goal

Create and grill a separate v3 authority-integrity follow-up fix plan for the six
remaining gaps found in the repository audit. This task is planning-only: it
must not implement source changes and must not edit the original TOC or prior
fix plans.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/v3_authority_binding_integrity_followup_plan/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/v3_authority_binding_integrity_followup_plan/behavior-baseline.md
  approval_snapshot_path: docs/evidence/v3_authority_binding_integrity_followup_plan/approval-snapshot.md

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

The current v3 implementation still has six integrity gaps that could permit
parallel authority paths, unverifiable package bindings, incomplete source
snapshots, weak traceability, or non-atomic intake artifacts.

### Scope

- Create/update only `my_docs/2026_07_16_v3_authority_integrity_followup_fix_plan.md`.
- Record the six audit findings and the decisions reached through one-question-at-a-time grilling.
- Use repository evidence to refine implementation phases and acceptance criteria.

### Out of Scope

- No source implementation in `.agent-harness/scripts/` or tests.
- No changes to `my_docs/agent-harness-research-review-toc.md`.
- No changes to previous reconciliation/fix-plan documents.
- No sandboxing, network restriction, external identity, signed release, deployment-control, v2 compatibility, or agent-adapter work.

### Success Criteria

- The new fix plan names and explains all six remaining gaps.
- Each decision has an explicit user-approved outcome and implementation boundary.
- The plan defines fail-closed verification and autonomous execution behavior.
- The plan is approved only after grilling is complete.

### Dependencies

- Existing v3 Change Package, state, event-chain, intake, and snapshot behavior.
- The current repository is authoritative for implementation details.
- Human approval is required for this planning artifact, not for routine runtime remediation.

## Epic / Story / Task Breakdown

### Epic 1: Authority-integrity follow-up planning

Dependencies:

- Existing v3 authority-binding implementation and the six-gap audit.

Acceptance Criteria:

- All six gaps are covered by decisions and implementation acceptance criteria.

Stories:

- Grill and record boundary, binding, snapshot, retrieval, traceability, and atomicity decisions.

Tasks:

- Produce the separate dated fix plan; do not implement it in this task.

The breakdown above is concrete and repository-grounded.

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

- This task is documentation-only.
- The original TOC and previous fix plans are immutable for this task.
- Six audit findings are the starting set; add more only with repository evidence.
- Retire direct authority creation in both helper scripts.
- Implementation entry verifies package identity and all state bindings.
- Verification fails on missing or changed snapshots.
- URL/MCP capture freezes provenance; uncaptured authoritative sources block.
- Normative traceability validates IDs, coverage, and acceptance-criterion reachability.
- Snapshots stage atomically; failures clean up staging data.
- Integrity failures recover autonomously but cannot bypass verification.

## Scope

### In Scope

- Direct-script authority boundary.
- Package-to-state hash and package existence validation at implementation entry.
- Supporting snapshot existence and content-hash verification.
- URL/MCP capture and frozen provenance behavior.
- Normative traceability referential integrity and coverage.
- Atomic source snapshot creation and failure cleanup.

### Out of Scope

- Any implementation or test changes.
- Any change to settled v3 exclusions or autonomous human-interaction policy.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: Grill and record decisions for all remaining gaps.
- [ ] Phase B: Convert approved decisions into a separate implementation plan.
- [ ] Phase C: Obtain approval; implementation belongs to a later task.

## Planning Result

The six audit gaps and one cross-cutting autonomy decision have been grilled
and recorded in the separate `my_docs/2026_07_16_v3_authority_integrity_followup_fix_plan.md`.
This planning task must be finalized before any implementation task is created.

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
