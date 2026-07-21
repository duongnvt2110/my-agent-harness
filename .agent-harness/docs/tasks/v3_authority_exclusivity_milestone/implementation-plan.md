---
task_id: v3_authority_exclusivity_milestone
title: "v3_authority_exclusivity_milestone"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: high_risk
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 1
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-13 13:10"
baseline_ref: null
file_map_approved: true
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
  - .agent-harness/scripts/**
  - .agent-harness/tests/harness/**
  - .agent-harness/docs/**
  - .agent-harness/policies/**
  - README.md
  - WORKFLOW.md
review_required: true
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
spec_clarification_evidence: docs/evidence/v3_authority_exclusivity_milestone/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/v3_authority_exclusivity_milestone/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/v3_authority_exclusivity_milestone/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/v3_authority_exclusivity_milestone/context-pack.md
working_memory_path: docs/evidence/v3_authority_exclusivity_milestone/working-memory.md
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
    evidence: "docs/evidence/v3_authority_exclusivity_milestone/plan-check.md"
completed_at: "2026-07-13 13:37"
---

# Execution Plan: v3_authority_exclusivity_milestone

## Update History

Updated: 2026-07-13 11:00
Updated: 2026-06-04 16:40

## Goal

Implement and prove the first v3 authority-exclusivity milestone. Exactly one
canonical lifecycle/event path, protected provenance, strict v2/v3 dispatch,
fail-closed high-risk mutation denial, legacy compatibility, and the required
negative-security/corruption/recovery tests must be real and documented.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/v3_authority_exclusivity_milestone/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/v3_authority_exclusivity_milestone/behavior-baseline.md
  approval_snapshot_path: docs/evidence/v3_authority_exclusivity_milestone/approval-snapshot.md

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

The re-audit found competing lifecycle/event writers, self-asserted authority,
caller-controlled risk/mode, non-strict dispatch, and unsafe high-risk paths.

### Scope

1. One canonical v3 lifecycle transition and event append implementation.
2. Protected provenance for approvals, roles, verifier evidence, risk,
   enforcement, and AC evidence; caller JSON/flags are never authoritative.
3. Explicit metadata dispatch to v2 or v3 with no fallback or reinterpretation.
4. Fail-closed denial when mandatory technical controls are unavailable.
5. Compatibility, corruption, crash-recovery, dispatcher, and bypass tests.
6. Documentation describing the implemented authority model and limitations.

### Out of Scope

Agent-specific adapters, concurrent worktrees, full sandboxing, request-scoped
network enforcement, recipes, model/budget routing, external release bootstrap,
and all sibling/successor remediation tasks.

### Success Criteria

- Every v3 transition and append routes through one implementation.
- Forged approvals, roles, verifier verdicts, risk, enforcement, or evidence
  are rejected or remain non-authoritative.
- Public commands select exactly v2 or v3 from authoritative metadata.
- Ambiguous/mixed/missing artifacts fail closed without mutation.
- High-risk mutation is denied without mandatory enforcement adapters.
- v2 remains compatible and explicitly labelled legacy.
- Required negative, corruption, crash-recovery, and compatibility tests pass.
- Documentation and release evidence identify the actual assurance mode.

### Dependencies

The reviewed re-audit plan and existing v3 authority-model ADRs are source
context. No later roadmap phase may be activated by this task.

## Epic / Story / Task Breakdown

### Epic 1: V3 authority exclusivity

Dependencies:

- Existing state/event, dispatcher, policy, provenance, and test fixtures.

Acceptance Criteria:

- AC-001: canonical lifecycle/event path.
- AC-002: protected provenance and fail-closed authority.
- AC-003: strict v2/v3 dispatch and compatibility.
- AC-004: high-risk mutation denial without mandatory controls.
- AC-005: negative-security, corruption, crash-recovery, and documentation proof.

Stories:

- Canonical authority path and provenance enforcement.
- Strict dispatch, fail-closed mutation, and regression proof.

Tasks:

- Implement only this milestone and its evidence.

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

- state.json/transition-state and one event store are the v3 authority path.
- v2 remains a separate legacy implementation; no silent migration/fallback.
- hashes identify content; protected MAC/signature/adapter provenance establishes authority.
- unavailable mandatory controls deny high-risk mutation; AUDIT_ONLY is explicit.

## Scope

### In Scope

- `.agent-harness/scripts/**`, `.agent-harness/tests/harness/**`,
  `.agent-harness/docs/**`, `.agent-harness/policies/**`, `README.md`, `WORKFLOW.md`.

### Out of Scope

- All later phases listed in the user authorization.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: authority implementation and focused negative tests
- [ ] Phase B: full compatibility/corruption/recovery/release proof

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

Independent review is required. High-risk authority changes cannot self-approve.

## Risks

| Risk | Mitigation |
|---|---|
| Authority regression | Preserve v2 path and require negative compatibility fixtures before finalization. |
| Partial transition change | Journal before mutation; restore the last verified checkpoint and enter RECOVERY_REQUIRED on mismatch. |

## Rollback Plan

Before each authority mutation, retain the verified checkpoint and event-chain
head. If any focused or full gate fails, restore only private staging artifacts,
leave committed lifecycle history immutable, and return the run to remediation
or RECOVERY_REQUIRED. A successor run is required for any materially new
execution attempt.
