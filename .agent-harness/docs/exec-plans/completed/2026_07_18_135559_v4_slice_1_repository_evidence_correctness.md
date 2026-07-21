---
task_id: v4_slice_1_repository_evidence_correctness
title: "Implement v4-core Slice 1 repository evidence correctness"
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
approved_at: "2026-07-18 13:50"
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
  - .agent-harness/scripts/repository-intelligence.sh
  - .agent-harness/tests/harness/test_v4_slice_1_repository_evidence.sh
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
spec_clarification_evidence: docs/evidence/v4_slice_1_repository_evidence_correctness/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/v4_slice_1_repository_evidence_correctness/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/v4_slice_1_repository_evidence_correctness/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/v4_slice_1_repository_evidence_correctness/context-pack.md
working_memory_path: docs/evidence/v4_slice_1_repository_evidence_correctness/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - Repository intelligence defaults to the declared repository root, not the harness directory.
  - Repository inventory evidence records relative paths, hashes, sizes, types, and scan-root binding.
  - Generated repository evidence is marked generated and cannot claim verification success.
  - A focused regression proves root binding and generated-evidence status.
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: slice-1-repository-evidence-test
    type: automated
    command: ./tests/harness/test_v4_slice_1_repository_evidence.sh
    allow_raw_command: true
    raw_command_reason: "The executable fixture is run from the harness root through run-in-env; nested rtk path resolution is not reliable."
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: "docs/evidence/v4_slice_1_repository_evidence_correctness/plan-check.md"
completed_at: "2026-07-18 13:55"
---

# Execution Plan: Implement v4-core Slice 1 repository evidence correctness

## Update History

Updated: 2026-06-04 16:40

## Goal

Implement the foundational v4-core repository evidence contract.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/v4_slice_1_repository_evidence_correctness/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/v4_slice_1_repository_evidence_correctness/behavior-baseline.md
  approval_snapshot_path: docs/evidence/v4_slice_1_repository_evidence_correctness/approval-snapshot.md

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

Repository intelligence currently defaults its scan root to the harness
directory and emits generated evidence with pass-like status without a root or
source integrity binding.

### Scope

Correct root resolution, add a deterministic repository inventory artifact, and
change generated evidence status to generated. Add focused regression coverage.

### Out of Scope

Do not add ecosystem parsers, tokenization, sandboxing, network policy, agent
adapters, or changes to lifecycle authority or the original TOC.

### Success Criteria

The focused fixture proves the scanner uses the target root, inventory hashes
are reproducible, and every generated report says generated rather than pass.

### Dependencies

This slice must remain additive and preserve existing repository-intelligence
commands and context-pack consumers.

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

- 

### Out of Scope

- 

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
