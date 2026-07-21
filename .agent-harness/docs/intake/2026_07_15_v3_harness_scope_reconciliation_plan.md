# Plan: v3 Harness Scope Reconciliation and Completion

**Generated**: 2026-07-15
**Estimated Complexity**: High

## Update History

Updated: 2026-07-15 21:02

## Overview

Implement the settled v3-only harness contract and reconcile the repository
with the decisions recorded during the architecture discussion. The work is
split into two boundaries:

1. Reconcile and verify the v3 core that already exists in the repository.
2. Implement the missing one-file intake and specification-lock control plane.

The harness must let the coding agent work autonomously while keeping
specification lock, lifecycle state, evidence, verification, and finalization
under harness control.

This plan is a new planning artifact. It does not modify
`my_docs/agent-harness-research-review-toc.md` during planning.

## Binding Decisions

- Human defines and approves the implementation contract first.
- The repository is v3-only; there is no v2 authority, migration path, or
  fallback.
- `state.json` is the sole lifecycle authority and the transition script is the
  sole lifecycle writer.
- `current.md` and task-store views are derived projections.
- The agent remains autonomous during implementation, verification, recovery,
  remediation, rethink, and budget-epoch renewal.
- Human involvement is limited to contract lock, explicit material authority
  decisions, cancellation or waiver where applicable, and final approval.
- Remediation has no fixed task-level attempt limit. A looping strategy enters
  `RETHINK_REQUIRED` and continues with a new diagnosis and strategy.
- The harness is agent-neutral and repository-local.
- Sandboxing, network restriction, external identity, signed releases,
  deployment control, and agent-specific adapters are out of scope.
- Review uses one simple canonical package/file; approval produces the locked
  result without requiring a separate draft-file workflow.
- Verification and finalization are harness-controlled functions, not
  agent-authority roles such as `Verifier` or `Finalizer`.

## Scope

### In scope

- Remove stale v2, release, identity, sandbox, network, and role-authority
  requirements from active implementation and documentation paths.
- Align the lifecycle and recovery state model with v3-only behavior.
- Implement or complete the one-file intake, understanding, design/business
  rule review, acceptance mapping, approval, and specification-lock flow.
- Preserve client inputs including text, files, images, diagrams, and MCP or
  external-reference results as traceable source evidence.
- Enforce autonomous execution and remediation through harness state,
  evidence, budget epochs, and rethink transitions.
- Add focused tests for stale-artifact rejection, lifecycle transitions,
  autonomous remediation, approval/finalization, projections, and recovery.
- Update the TOC only in a later implementation/documentation step after the
  behavior and scope are verified.

### Phase boundary

- Phase 1 must inventory existing behavior before changing it.
- Existing v3 authority, event, projection, recovery, remediation, and
  finalization behavior must be preserved unless a focused check proves a gap.
- Phase 1 must not rewrite already-working v3 core behavior merely to match the
  plan wording.
- Phase 2 starts only after Phase 1 verification identifies the missing intake
  control-plane behavior and its exact files are approved.

### Out of scope

- OS/container sandboxing or network confinement.
- External identity providers, signed artifacts, release trust chains, or
  deployment orchestration.
- Agent-specific adapters or agent capability implementations.
- A v2 compatibility layer or migration runtime.
- Broad rollback as an agent-selected completion or remediation strategy.
- Adding additional human approval checkpoints during autonomous execution.

## Prerequisites and Authority

- Read `AGENTS.md`, `.agent-harness/docs/PLANS.md`, `WORKFLOW.md`, ADR-0004,
  and the current harness task packet.
- Treat the current v3 authority model and settled discussion decisions as the
  source of truth over older vNext intake wording.
- Before implementation, create exactly one guarded active plan through the
  harness workflow and approve its file map.
- Keep the TOC unchanged until this plan reaches the documentation
  reconciliation step.

## Sprint 1: Establish the v3-only baseline

**Goal**: Make the current repository behavior and intended v3 contract
explicit before changing implementation files.

**Demo/Validation**:

- `rtk .agent-harness/harness.sh next` reports the expected v3 task packet.
- A baseline report identifies every active reference to v2, `STUCK`,
  `ROLLED_BACK`, external identity, sandbox/network controls, release trust,
  and removed authority roles.
- Existing focused and full harness checks are recorded before changes.

### Task 1.1: Create the guarded implementation task

- **Location**: `.agent-harness/docs/exec-plans/active/current.md`
- **Description**: Classify this plan, decompose it if required, activate one
  task, and approve the task through the public harness workflow.
- **Dependencies**: None.
- **Acceptance Criteria**:
  - Exactly one active plan exists.
  - The approved file map explicitly permits only required harness files,
    tests, and the later TOC update.
  - No implementation begins before the plan is approved.
- **Validation**: `rtk .agent-harness/harness.sh next` and the task approval
  command succeed.

### Task 1.2: Record the current behavior baseline

- **Location**: `.agent-harness/docs/evidence/` and existing harness tests.
- **Description**: Run the narrowest available v3 checks and capture current
  lifecycle states, public commands, projections, evidence, and remediation
  behavior before edits.
- **Dependencies**: Task 1.1.
- **Acceptance Criteria**:
  - Baseline evidence is reproducible and contains no secrets.
  - Existing passing behavior is protected from unrelated changes.
- **Validation**: Existing repository test and verification commands.

## Sprint 2: Phase 1 — Reconcile and verify the existing v3 core

**Goal**: Ensure the existing state, transition, projection, recovery,
verification, and remediation implementation matches the settled v3 contract
without unnecessary rewrites.

**Demo/Validation**:

- Legacy/v2 authority artifacts fail closed.
- Valid v3 transitions update state atomically and append evidence.
- Derived projections cannot become lifecycle authorities.
- Recovery and rethink transitions remain harness-controlled.

### Task 2.1: Inventory the existing v3 implementation

- **Location**: `.agent-harness/scripts/`, runtime artifacts, policies, and
  related tests.
- **Description**: Map each requirement to existing implementation, existing
  test coverage, partial behavior, or a confirmed gap before editing.
- **Dependencies**: Sprint 1.
- **Acceptance Criteria**:
  - The inventory identifies files and tests for every Phase 1 requirement.
  - Already-working v3 behavior is marked preserve, not rewrite.
  - Missing intake behavior is isolated for Phase 2.
- **Validation**: Repository inspection, focused existing tests, and a
  requirement-to-code matrix.

### Task 2.2: Remove stale active authority references

- **Location**: `.agent-harness/scripts/`, active harness documentation, and
  focused tests.
- **Description**: Remove or reject stale v2 authority, fallback, role,
  release-trust, identity, and excluded isolation behavior while preserving
  historical records as non-authoritative evidence.
- **Dependencies**: Task 2.1.
- **Acceptance Criteria**:
  - No excluded capability controls an active v3 run.
  - No v2 fallback or migration runtime exists.
  - Active terminology does not assign authority to `Verifier` or `Finalizer`
    agents.
- **Validation**: Stale-reference scans, dispatcher tests, authority tests,
  and focused documentation checks.

### Task 2.3: Verify lifecycle, remediation, recovery, and finalization

- **Location**: Existing lifecycle, remediation, recovery, projection,
  verification, and finalization scripts/tests.
- **Description**: Run focused checks and make only minimal fixes for proven
  gaps. Confirm `RETHINK_REQUIRED`, automatic budget epochs, recovery, and
  harness-owned completion behave as agreed.
- **Dependencies**: Task 2.2.
- **Acceptance Criteria**:
  - Agent output cannot declare completion by itself.
  - Finalization requires the harness gate and human final approval.
  - Remediation does not require routine human approval.
  - `current.md` remains generated and read-only.
- **Validation**: Lifecycle, forged-completion, projection-write,
  evidence-binding, remediation, recovery, and finalization tests.

## Sprint 3: Phase 2 — Implement the missing intake control plane

**Goal**: Convert broad human requests into a reviewable, sufficiently clear
contract without introducing excessive approval flow.

**Demo/Validation**:

- One canonical package/file contains understanding, design review,
  business rules, scope, acceptance criteria, and source references.
- Human approval produces a locked specification.
- Clarification is used only when required and does not create a second
  authority source.

### Task 3.1: Define the canonical contract package

- **Location**: Intake/spec-lock scripts, schemas, templates, and tests.
- **Description**: Implement stable headings and machine-readable metadata for
  request interpretation, architecture/design review, business rules,
  acceptance mapping, scope/non-goals, and approval/lock status.
- **Dependencies**: Sprint 2.
- **Acceptance Criteria**:
  - The workflow uses one canonical package/file.
  - The package distinguishes proposed content from human-approved content.
  - Locking is explicit and cannot be performed by the agent alone.
- **Validation**: Valid-package, incomplete-package, clarification, and
  spec-lock tests.

### Task 3.2: Preserve multimodal and external source provenance

- **Location**: Intake/source-bundle implementation and provenance tests.
- **Description**: Accept client-provided text, files, images, diagrams, MCP
  results, and external references while recording source type, location,
  capture metadata, authority classification, and hashes where available.
- **Dependencies**: Task 3.1.
- **Acceptance Criteria**:
  - Source material is traceable to the contract sections it informs.
  - Source changes require an explicit impact assessment.
  - Casual agent reasoning cannot silently change the locked contract.
- **Validation**: Source ingestion, hash/change, authority-classification, and
  traceability tests.

### Task 3.3: Keep human interaction at contract boundaries

- **Location**: Intake, approval, clarification, and lifecycle transition
  scripts/tests.
- **Description**: Permit human input for clarification and contract lock,
  then let implementation, verification, remediation, rethink, and recovery
  proceed autonomously until final review.
- **Dependencies**: Task 3.2.
- **Acceptance Criteria**:
  - No routine human pause or approval is required during execution.
  - Material contract changes invalidate or supersede the prior lock.
  - Final approval is the only required human completion decision.
- **Validation**: End-to-end autonomous-run and approval-boundary tests.

## Sprint 4: Phase 1 follow-up — Repair only verified autonomous gaps

**Goal**: Repair only autonomous verification or remediation gaps identified by
Phase 1, without reimplementing existing working behavior.

**Demo/Validation**:

- Verification failures enter remediation automatically.
- Budget exhaustion creates a new budget epoch automatically.
- Repeated ineffective remediation triggers rethink and continues.
- The harness never accepts success without current evidence.

### Task 4.1: Repair automatic remediation epochs only if needed

- **Location**: Remediation/budget scripts, state schema, and tests.
- **Description**: If the Phase 1 inventory proves a gap, remove fixed
  task-level attempt limits and create a new budget epoch when the current
  epoch is exhausted, preserving history and evidence. Otherwise record the
  existing implementation as verified and make no source change.
- **Dependencies**: Sprint 2.
- **Acceptance Criteria**:
  - No human approval is required to renew a remediation epoch.
  - Each epoch has bounded operational accounting and immutable history.
  - Budget renewal cannot bypass verification or scope rules.
- **Validation**: Exhaustion, renewal, persistence, and scope-enforcement tests.

### Task 4.2: Repair automatic rethink detection only if needed

- **Location**: Remediation diagnosis/strategy scripts and tests.
- **Description**: If the Phase 1 inventory proves a gap, detect repeated
  ineffective strategies, enter `RETHINK_REQUIRED`, generate a new diagnosis,
  and continue autonomously. Otherwise record the existing implementation as
  verified and make no source change.
- **Dependencies**: Task 4.1.
- **Acceptance Criteria**:
  - The system does not pause solely because a strategy loops.
  - Rethink records why the previous strategy was ineffective.
  - A new strategy is still subject to the locked contract and evidence gates.
- **Validation**: Synthetic loop, rethink, and successful-follow-up tests.

## Sprint 5: Documentation and compatibility reconciliation

**Goal**: Make the TOC and repository documentation reflect only the verified
v3 contract.

**Demo/Validation**:

- The TOC no longer presents excluded features or superseded v2/role-based
  behavior as active requirements.
- The TOC remains a complete implementation contract for the verified scope.

### Task 5.1: Update active TOC sections after behavior is verified

- **Location**: `my_docs/agent-harness-research-review-toc.md`
- **Description**: Remove stale active references to v2 migration, external
  identity, sandbox/network controls, signed releases, release trust,
  role-based authority, `STUCK`, and unsupported rollback semantics. Simplify
  the one-file contract lifecycle.
- **Dependencies**: Sprints 2–4 and human review of the implementation result.
- **Acceptance Criteria**:
  - The TOC contains only v3 repository-local requirements.
  - Excluded sections remain excluded without being reintroduced as active
    requirements.
  - Every active TOC requirement maps to an implementation or test.
- **Validation**: TOC-to-code traceability review, stale-term scan, and full
  harness verification.

### Task 5.2: Reconcile supporting documentation and decision records

- **Location**: `.agent-harness/docs/`, ADR index, operator documentation.
- **Description**: Update only documentation that contradicts the verified
  v3 contract; retain historical decisions as history without presenting them
  as current behavior.
- **Dependencies**: Task 5.1.
- **Acceptance Criteria**:
  - ADR-0004 and supporting docs agree with implementation.
  - Historical vNext wording is clearly non-authoritative where retained.
  - No excluded release, identity, sandbox, or adapter feature is presented
    as required for v3.
- **Validation**: Documentation consistency review and repository-wide stale
  reference scan.

## Testing Strategy

- Run focused tests after each lifecycle, intake, remediation, and projection
  change.
- Run the repository harness verification command before completion:
  `rtk .agent-harness/harness.sh verify`.
- Exercise the full lifecycle from intake through finalization, including
  clarification, approval, implementation, failed verification, autonomous
  remediation, budget renewal, rethink, recovery, and final approval.
- Run stale-reference scans for v2, `STUCK`, external identity, sandbox,
  network restriction, signed release, trusted release, and removed role names.
- Complete through the public harness command:
  `rtk .agent-harness/harness.sh finalize`.

## Potential Risks and Gotchas

- Older intake plans and historical ADRs contain superseded v2, role, release,
  and isolation concepts. Do not delete history; prevent it from acting as
  current contract.
- The term `rollback` may describe technical recovery in existing scripts.
  Preserve only behavior required for safe recovery and do not expose it as a
  broad agent-selected workflow state without an explicit v3 definition.
- A source bundle can become a hidden second specification authority. Keep the
  locked contract authoritative and treat source material as traceable input.
- Unlimited remediation at the task level still requires bounded per-epoch
  accounting, durable evidence, and loop detection.
- The current harness reports `AUDIT_ONLY`; verification must not be described
  as OS-level isolation or external security enforcement.
- Do not expand the implementation to sandboxing, identity, signed releases,
  deployment, or agent adapters while resolving TOC drift.

## Rollback Plan

- Preserve the pre-change baseline and evidence for every implementation slice.
- Revert only the implementation slice that fails its focused contract tests;
  do not restore v2 authority or excluded features as a fallback.
- If a documentation change is wrong, restore the previous documented wording
  while keeping the verified v3 implementation authoritative, then revise the
  mapping.

## Definition of Done

- The v3-only authority and lifecycle behavior is implemented and tested.
- The simple human contract workflow is implemented and tested.
- Autonomous remediation, budget renewal, rethink, and recovery are verified.
- The TOC is updated only after implementation verification and maps to the
  resulting behavior.
- `harness.sh verify` and `harness.sh finalize` succeed.
