---
task_id: implement_isolated_worktree_adapter
title: "Implement isolated worktree creation and canonical revalidation"
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
approved_at: "2026-07-11 16:57"
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
spec_clarification_evidence: docs/evidence/implement_isolated_worktree_adapter/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/implement_isolated_worktree_adapter/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/implement_isolated_worktree_adapter/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/implement_isolated_worktree_adapter/context-pack.md
working_memory_path: docs/evidence/implement_isolated_worktree_adapter/working-memory.md
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
    evidence: "docs/evidence/implement_isolated_worktree_adapter/plan-check.md"
completed_at: "2026-07-11 17:05"
---

# Execution Plan: Implement isolated worktree creation and canonical revalidation

## Update History

Updated: 2026-06-04 16:40

## Goal

Add a control-plane-owned isolated Git worktree lifecycle that records the
exact base commit, task/specification/policy/run identities, and snapshot
manifest, then revalidates those identities before any integration result is
accepted. Unsupported or ambiguous worktree conditions fail closed to
AUDIT_ONLY/read-only behavior.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/implement_isolated_worktree_adapter/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/implement_isolated_worktree_adapter/behavior-baseline.md
  approval_snapshot_path: docs/evidence/implement_isolated_worktree_adapter/approval-snapshot.md

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

The existing workspace guard detects one writer but does not create an
isolated implementation worktree or prove that a verified result still
matches the canonical checkout before integration. This permits a stale or
rewritten worktree verdict to be mistaken for current authority.

### Scope

Implement public harness commands for creating and cleaning isolated Git
worktrees and for validating a worktree verdict against exact task, run,
specification, policy, base-commit, patch, and verifier identities. Record
immutable manifests and use idempotent journal steps for cleanup/revalidation.
Add negative and positive fixtures covering concurrent writers, base drift,
patch drift, stale verifier identity, and successful canonical revalidation.

### Out of Scope

Platform sandbox profiles, network interception, merge conflict resolution,
automatic production integration, and external signing are later slices.

### Success Criteria

- A worktree is detached at an exact recorded base commit and cannot be
  accepted without an exact identity manifest.
- A second writer for the same checkout/task is denied and stale leases cannot
  mutate or integrate.
- Any base, patch, task, run, specification, policy, or verifier mismatch
  invalidates the verdict and blocks integration.
- Cleanup is idempotent and preserves the immutable manifest and evidence.
- Focused fixtures, the benchmark, full harness verification, and release
  gates pass.

### Dependencies

Use the existing `workspace-guard`, `writer-lease`, `run-events`, capability,
and enforcement-gate contracts. Git is required for the enforced worktree
path; non-Git or unsupported runtimes remain AUDIT_ONLY and cannot authorize
high-risk mutation or integration.

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

- Worktree verdicts are scoped to the exact verified snapshot and require
  canonical revalidation before integration.
- Isolation is technical prevention, not a post-edit detection claim.
- AUDIT_ONLY never authorizes high-risk mutation or integration.

## Scope

### In Scope

- `.agent-harness/scripts/create-worktree`
- `.agent-harness/scripts/cleanup-worktree`
- `.agent-harness/scripts/revalidate-worktree`
- `.agent-harness/scripts/harness.sh` public routing
- `.agent-harness/tests/harness/test_worktree_integration.sh`
- related task-local evidence and schemas

### Out of Scope

- sandbox and network adapter implementation
- automatic merge or deployment

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: implement immutable worktree manifest, writer ownership, and
  idempotent cleanup.
- [ ] Phase B: implement canonical revalidation and negative-security tests.

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

Review is required: the task is high-risk and changes authority around
workspace isolation and integration acceptance.

## Risks

| Risk | Mitigation |
|---|---|
|  |  |
