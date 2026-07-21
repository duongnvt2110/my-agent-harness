---
task_id: record_vnext_governance_contract
title: "Record vNext governance contract and safe task graph"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: high_risk
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 2
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-10 14:06"
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
  - harness_docs
approved_files:
  - my_docs/agent-harness-vnext-full-implementation-plan.md
  - my_docs/2026_07_10_agent_harness_vnext_approved_design.md
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
spec_clarification_evidence: docs/evidence/record_vnext_governance_contract/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/record_vnext_governance_contract/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/record_vnext_governance_contract/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/record_vnext_governance_contract/context-pack.md
working_memory_path: docs/evidence/record_vnext_governance_contract/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - AC-001
  - AC-002
  - AC-003
  - AC-004
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: approved-design-contract
    type: automated
    command: "rtk rg -n 'state.json.*sole.*authority|transition-state.*only.*writer|v3-core' ../my_docs/2026_07_10_agent_harness_vnext_approved_design.md"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-002
    evidence: "docs/evidence/record_vnext_governance_contract/approved-design-contract.md"
  - id: source-plan-binding
    type: automated
    command: "rtk rg -n 'Approved Design Authority|2026_07_10_agent_harness_vnext_approved_design.md|v3-core' ../my_docs/agent-harness-vnext-full-implementation-plan.md"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
      - AC-004
    evidence: "docs/evidence/record_vnext_governance_contract/source-plan-binding.md"
  - id: architecture-decision-record
    type: automated
    command: "rtk rg -n 'Status: `accepted`|state.json|transition-state|current.md' docs/decisions/0004-agent-harness-vnext-authority-model.md docs/decisions/adr-index.json"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-003
    evidence: "docs/evidence/record_vnext_governance_contract/architecture-decision-record.md"
completed_at: "2026-07-10 14:16"
---

# Execution Plan: Record vNext governance contract and safe task graph

## Update History

Updated: 2026-07-10 14:04
Updated: 2026-06-04 16:40

## Goal

Persist the approved vNext governance design, bind the source implementation
plan to that design, and record the lifecycle authority decision before any
v3 implementation task is decomposed.

## Baseline Contract

Use the reduced public baseline model:

```yaml
baseline:
  change_tracking: snapshot
  behavior_tracking: existing_tests

  git_ref: null
  snapshot_path: docs/evidence/record_vnext_governance_contract/baseline-snapshot.json
  behavior_baseline_path: docs/evidence/record_vnext_governance_contract/behavior-baseline.md
  approval_snapshot_path: docs/evidence/record_vnext_governance_contract/approval-snapshot.md

  created_before_execution: true

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

The human-approved grilling decisions are not persisted in the source plan.
The current raw-plan decomposer consequently produces generic tasks, generic
acceptance criteria, and no meaningful dependency graph. Approving that output
would lose the binding vNext authority, trust, recovery, and verification
decisions before implementation begins.

### Scope

Create one approved-design ledger under `my_docs/`, update the existing vNext
source plan to make that ledger authoritative, and add an umbrella ADR for the
v3 lifecycle authority and projection model. Include a traceable v3-core
release outline that can become the next safe decomposition input.

### Out of Scope

Do not modify executable harness code, public CLI behavior, tests, policies,
runtime state formats, or release packages. Do not run or approve the current
generic raw-plan decomposition. Do not begin a v3 implementation slice.

### Success Criteria

- The approved-design ledger records every normative decision from the grilling
  discussion and identifies v3-core as the first release boundary.
- The source implementation plan names the ledger as binding authority and
  reconciles conflicting earlier language.
- ADR 0004 records `state.json` authority, sole-writer transitions, generated
  projections, compatibility consequences, and rejected alternatives.
- The design defines behavior-based v3-core task slices, dependencies, and
  release-blocking verification without approving implementation yet.

### Dependencies

Requires the existing vNext implementation plan, the approved grilling
decisions, the current dirty-worktree snapshot, ADR 0003, and the legacy v2
harness planning gates. The current decomposer is evidence of the problem and
must not be treated as the desired task graph.

## Epic / Story / Task Breakdown

### Epic 1: Record the vNext governance contract

Dependencies:

- Requires the human-approved vNext design decisions and current harness
  baseline before implementation decomposition.

Acceptance Criteria:

- The persisted design and source plan define one consistent, traceable vNext
  architecture and first-release boundary.
- The lifecycle authority choice is recorded as an accepted ADR.
- No executable behavior changes in this task.

Stories:

- Persist approved architecture and prepare safe decomposition authority.

Tasks:

- Document the approved vNext governance contract and v3-core task outline.

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

- The entire grilling decision ledger is normative for vNext implementation.
- `state.json` is the sole v3 lifecycle authority.
- `transition-state` is the only v3 lifecycle writer.
- `current.md` and aggregate statuses are generated projections.
- v3-core ships correctness and recovery before advanced enforcement releases.
- Missing mandatory technical controls block affected high-risk actions.

## Scope

### In Scope

- `my_docs/2026_07_10_agent_harness_vnext_approved_design.md`
- `my_docs/agent-harness-vnext-full-implementation-plan.md`
- `docs/decisions/0004-agent-harness-vnext-authority-model.md`
- `docs/decisions/adr-index.json`

### Out of Scope

- Executable scripts, tests, policies, runtime directories, and packages.
- Activation of any v3 implementation task.
- Changes to existing ADR meaning.

## Scope Notes

Use `approved_scopes` for the common contract and `approved_files` only for
exceptions. This keeps application tasks short without weakening the gate.

Create `full-context.md` before epic, story, or task breakdown so the harness
has a repo-grounded decomposition source of truth.

## Phases

- [ ] Phase A: persist the complete approved-design ledger.
- [ ] Phase B: bind and reconcile the source implementation plan.
- [ ] Phase C: record ADR 0004 and validate the documentation contract.

## Verification

Run the three documentation contract checks declared in frontmatter. Final
harness verification must also pass the active-plan, snapshot file-map,
baseline, evidence, context, and review gates.

```bash
rtk ./scripts/verify.sh
```

## Review

Independent review is required because this task records control-plane
authority and high-risk policy decisions.

## Rollback Plan

Before finalization, restore only the four task-owned documentation artifacts
from the task snapshot or remove newly created artifacts. Do not touch the
pre-existing dirty migration. If the source plan and ledger cannot be
reconciled without ambiguity, stop in the planning phase instead of publishing
partial authority.

## Risks

| Risk | Mitigation |
|---|---|
| Discussion decisions are omitted or weakened | Map every decision into the approved-design ledger and review it against the transcript. |
| Existing plan conflicts with approved authority | Mark the approved ledger as higher-precedence task authority and identify superseded wording explicitly. |
| Generic decomposition is accidentally approved | Keep decomposition and implementation out of scope until the safe task graph is reviewed. |
| Dirty migration is misattributed to this task | Use the pre-edit task snapshot and do not modify unrelated existing changes. |
