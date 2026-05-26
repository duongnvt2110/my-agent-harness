---
task_id: example_task
title: Example task
status: DRAFT
lifecycle_phase: PLAN
lane: tiny
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 1
implementation_allowed: false
clarification_status: CLEAR
blocking_questions: []
approved_by: null
approved_at: null
baseline_ref: null
file_map_approved: false
review_required: false
evidence_required: true
requires_rollback_plan: false
requires_human_approval: false
test_matrix_refs: []
approved_scopes:
  - harness_core
approved_files: []
approved_deletions: []
required_checks:
  - id: plan-check
    type: automated
    command: "rtk ./scripts/harness.sh next"
    blocking: true
    evidence: "docs/evidence/example_task/plan-check.md"
---

# Execution Plan: Example Task

Updated: YYYY-MM-DD HH:MM

## Goal

Describe the exact outcome.

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

## Phases

- [ ] Phase A:
- [ ] Phase B:

## Verification

```bash
rtk ./scripts/verify.sh
```

## Review

State whether review is required for this lane.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
