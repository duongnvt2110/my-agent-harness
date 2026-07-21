---
task_id: v3_core_canonical_artifact_kernel
title: "Build v3 canonical artifact, schema, time, and retention kernel"
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
approved_at: "2026-07-10 23:13"
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
  - scripts/bootstrap-runner.sh
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
spec_clarification_evidence: docs/evidence/v3_core_canonical_artifact_kernel/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/v3_core_canonical_artifact_kernel/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/v3_core_canonical_artifact_kernel/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/v3_core_canonical_artifact_kernel/context-pack.md
working_memory_path: docs/evidence/v3_core_canonical_artifact_kernel/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001: The bootstrap runner enforces a detached worktree, no-network sandbox, capability-limited container, and canonical-checkout write protection.
  - AC-002: The trusted prior v2 baseline remains green at 35/35, and the current suite passes inside that runner with fresh 36/36 evidence.
  - AC-003: The V3 canonical artifact kernel contract identifies every required schema, canonicalization, retention, and trusted-time boundary.
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: bootstrap-health
    type: automated
    command: "rtk ./scripts/bootstrap-runner.sh check"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-002
      - AC-003
    evidence: "docs/evidence/v3_core_canonical_artifact_kernel/bootstrap-health.md"
  - id: bootstrap-prior-suite
    type: automated
    command: "rtk ./scripts/bootstrap-runner.sh prior-suite"
    blocking: true
    timeout_seconds: 900
    covers:
      - AC-001
      - AC-002
    evidence: "docs/evidence/v3_core_canonical_artifact_kernel/bootstrap-prior-suite.md"
completed_at: "2026-07-11 10:35"
---

# Execution Plan: Build v3 canonical artifact, schema, time, and retention kernel

## Update History

Updated: 2026-07-10 23:34
Updated: 2026-07-10 23:11
Updated: 2026-07-10 22:52
Updated: 2026-06-04 16:40

## Goal

Provision and validate a technically enforced bootstrap runner, then use its
protected prior-release evidence as the prerequisite for V3C-01 implementation.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: null # git | snapshot
  behavior_tracking: null # existing_tests | characterization | approval_snapshot | none

  git_ref: null
  snapshot_path: docs/evidence/v3_core_canonical_artifact_kernel/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/v3_core_canonical_artifact_kernel/behavior-baseline.md
  approval_snapshot_path: docs/evidence/v3_core_canonical_artifact_kernel/approval-snapshot.md

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

V3 core needs a common kernel for immutable canonical artifacts, schema and
canonicalization compatibility, trusted time, atomic writes, and minimized
evidence retention. The approved design classifies this as a mandatory
high-risk control-plane change. A disposable Docker/sandbox runner now provides
the required isolation and deny-by-default network boundary while the trusted
prior v2 suite validates the candidate.

### Scope

Implement the bootstrap runner, its health/prior-suite checks, and the exact
V3C-01 kernel contract. Kernel mutation remains inside the runner until the
runner and prior-release evidence pass.

### Out of Scope

No canonical-checkout mutation, unrestricted network action, integration,
rollback, or finalization may occur outside the runner. The runner must not
mount credentials or the canonical checkout as writable.

### Success Criteria

The runner must pass health and prior-suite checks. The plan must map V3C-01 to
deterministic tests for canonical bytes and hashes, schema-version rejection,
safe atomic writes, trusted-time failure, retention classification, and
sensitive-field rejection.

### Dependencies

Depends on finalized V3C-00 and decisions D-015, D-030, D-039, and D-040. V3C-01
is mandatory high-risk and runs only through the bootstrap runner.

## Epic / Story / Task Breakdown

### Epic 1: V3-core authority foundation

Dependencies:

- V3C-00 is finalized.
- The bootstrap runner must technically enforce isolation, deny-by-default
  network behavior, and protected prior-release validation.

Acceptance Criteria:

- Canonical artifacts are deterministic, schema-versioned, and integrity-bound.
- Time and retention decisions fail closed when they cannot be trusted.
- No high-risk v3 mutation executes without the required controls.

Stories:

- Establish the artifact kernel contract and its execution preconditions.

Tasks:

- V3C-01: implement the kernel only after the bootstrap gate is satisfied.


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

- D-015 defines evidence minimization and retention classes.
- D-030 denies high-risk v3 mutations when mandatory technical controls are
  missing; human approval cannot override this.
- D-039 requires explicit schema and canonicalization versions and fail-closed
  compatibility handling.
- D-040 requires trusted control-plane time for authority-consuming actions.

## Scope

### In Scope

- `scripts/bootstrap-runner.sh` and its health/prior-suite checks.
- `tests/harness/test_bootstrap_runner.sh`.
- Planning the `v3/` canonical artifact library and its schema registry.
- Planning deterministic JSON canonicalization, SHA-256 identities, and
  no-follow atomic-write requirements.
- Planning trusted-time abstractions with monotonic sequencing and UTC expiry
  validation.
- Planning evidence sanitization and retention-class validation.

### Out of Scope

- Any implementation mutation of the v3 control plane outside the bootstrap
  runner worktree.
- Claims that local timestamps, agent clocks, raw repository content, or
  generated summaries grant authority.
- Worktree integration, role switching, checkpoints, finalization, migration,
  or package activation outside the runner.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [x] Phase A: Verify Docker/sandbox availability and pinned image identity.
- [ ] Phase B: Implement and validate the persistent bootstrap runner.
- [ ] Phase C: Implement V3C-01 kernel and deterministic tests inside the runner.

## Verification

The later implementation must add deterministic tests for:

- canonical bytes and stable SHA-256 identities;
- unknown schema/canonicalization versions failing closed;
- atomic-write interruption and symlink-target rejection;
- trusted-time unavailable, rollback, and skew cases denying authority;
- every retention class, unknown classification, and required evidence expiry;
- credential, token, raw-environment, and unsanitized-content rejection.

```bash
rtk ./scripts/verify.sh
```

## Review

Independent, role-separated review is required. The eventual mutation task also
requires protected external CI or a trusted prior release as validator. A
same-provider verifier must disclose that it is not model-independent.

## Risks

| Risk | Mitigation |
|---|---|
| Missing technical controls permit unsafe high-risk mutation | Keep implementation inside the isolated runner and require prior-suite evidence. |
| Human approval is treated as a substitute for prevention | Require enforceable isolation and validation before reopening the task. |
| Artifact kernel overclaims trust | Treat repository, generated, and tool content as untrusted until schema and integrity checks pass. |
