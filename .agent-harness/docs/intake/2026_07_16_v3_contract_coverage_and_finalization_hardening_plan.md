# V3 Contract Coverage and Finalization Hardening Plan

## Update History

Updated: 2026-07-16 00:00

## Purpose

Prevent forgotten v3 requirements and missing authority paths from reaching
implementation completion. This plan adds an executable contract-coverage
layer and closes the remaining finalization authority gaps without modifying
the original research TOC or adding excluded features.

## Scope

Included:

- Final human-approval validation.
- One canonical task-completion path.
- v3 provenance enforcement on every finalization entry point.
- Machine-readable mapping from authority rules to implementation paths,
  denial tests, and recovery tests.
- State-transition invariant tests.
- Alternate-entry-point and adversarial regression coverage.
- Context-pack reporting of uncovered contract rules.

Excluded:

- v2 fallback or compatibility behavior.
- Sandboxing, network restriction, external identity, signed releases,
  deployment control, and agent-specific adapters.
- Changes to `my_docs/agent-harness-research-review-toc.md`.
- Human approval inside remediation or recovery.

## Success Criteria

The harness must fail verification when:

1. A normative v3 rule has no implementation entry point.
2. An entry point has no denial or tamper test.
3. A required state transition lacks an invariant test.
4. Finalization can occur without complete human approval evidence.
5. A direct task-projection command can mark work complete.
6. Any finalization path skips v3 provenance validation.
7. A recovery behavior has no executable recovery regression.

The harness must pass verification when all contract rules have complete
implementation, denial, transition, and recovery coverage.

## Contract Model

Create a new machine-readable contract registry under the v3 harness policy
scope. Each rule will contain:

- Stable rule ID.
- Authority owner.
- Normative invariant.
- Implementation entry points.
- Required validators.
- Forbidden direct paths.
- Positive tests.
- Negative/adversarial tests.
- Recovery tests.

The registry is an implementation companion to the original TOC. It does not
replace or rewrite the TOC.

## Sprint 1: Finalization Authority Boundary

**Goal**: Make finalization the only path that can complete a task.

### Task 1.1: Define finalization contract rules

- **Location**: `.agent-harness/policies/v3-contract.json`
- **Description**: Add rules for final approval, task projection, finalization
  journal ordering, snapshot freshness, and v3 provenance.
- **Dependencies**: None.
- **Acceptance Criteria**:
  - Rules have stable IDs and list every finalization entry point.
  - Each rule identifies positive, negative, and recovery tests.
  - The registry contains no excluded v2 or infrastructure features.
- **Validation**: JSON validation and contract-registry schema test.

### Task 1.2: Harden final human approval validation

- **Location**: `.agent-harness/scripts/finalize-v3-run`,
  `.agent-harness/scripts/check-finalization-authority.sh`
- **Description**: Require approval identity, timestamp, task/run binding,
  specification/evidence/snapshot hashes, reason, expiry or single-use state,
  and valid repository-local protected provenance.
- **Dependencies**: Task 1.1.
- **Acceptance Criteria**:
  - Incomplete, expired, mismatched, reused, or unproven approval is denied.
  - Rejection returns the run to the appropriate non-terminal state.
  - Remediation remains independent of final approval.
- **Validation**: Approval tamper, expiry, mismatch, reuse, and rejection tests.

### Task 1.3: Remove the direct completion bypass

- **Location**: `.agent-harness/scripts/task.sh`,
  `.agent-harness/scripts/finalize-task.sh`,
  `.agent-harness/scripts/finalize-v3-run`
- **Description**: Prevent direct `task.sh mark-done` use and permit task
  projection updates only from the validated finalization transaction.
- **Dependencies**: Task 1.2.
- **Acceptance Criteria**:
  - Direct task completion is denied.
  - Finalization updates the projection only after all checks pass.
  - A crash before projection leaves a recoverable journal state.
- **Validation**: Direct-call denial and interrupted-finalization recovery tests.

## Sprint 2: Entry-Point Parity and Contract Coverage

**Goal**: Ensure every public and low-level path uses the same v3 validators.

### Task 2.1: Add the contract-coverage checker

- **Location**: `.agent-harness/scripts/check-v3-contract-coverage.sh`
- **Description**: Verify that every registry rule maps to existing entry
  points, validators, positive tests, negative tests, and recovery tests.
- **Dependencies**: Sprint 1.
- **Acceptance Criteria**:
  - Missing mappings fail with rule IDs and actionable paths.
  - Orphan public commands are reported.
  - Coverage output is deterministic and suitable for evidence.
- **Validation**: Deliberately remove each mapping and assert failure.

### Task 2.2: Unify finalization entry points

- **Location**: `.agent-harness/scripts/harness.sh`,
  `.agent-harness/scripts/workflow-dispatch.sh`,
  `.agent-harness/scripts/finalize-v3-run`
- **Description**: Ensure every v3 finalization invocation sets v3 context and
  calls the same authority validator before mutation.
- **Dependencies**: Task 1.2.
- **Acceptance Criteria**:
  - Direct and dispatched finalization have identical validation behavior.
  - Protected evidence and verifier provenance cannot be skipped.
  - Unsupported or mixed artifacts fail closed.
- **Validation**: Entry-point parity test matrix.

### Task 2.3: Add state-transition invariants

- **Location**: `.agent-harness/scripts/check-v3-contract-coverage.sh`,
  `.agent-harness/tests/harness/`
- **Description**: Test that only the authorized harness function can write
  terminal state, remediation does not require human approval, locked packages
  cannot change, and recovery cannot silently finalize.
- **Dependencies**: Task 2.1.
- **Acceptance Criteria**:
  - Every listed invariant has a failing negative test.
  - Transition tests cover normal, rejected, recovery, and repeated-failure
    paths.
- **Validation**: Full transition and authority regression suite.

## Sprint 3: Context and Adversarial Coverage

**Goal**: Make missing contract coverage visible before implementation starts.

### Task 3.1: Add coverage to generated context

- **Location**: `.agent-harness/scripts/create-full-context.sh`,
  `.agent-harness/scripts/check-full-context.sh`
- **Description**: Include contract rules, covered entry points, missing tests,
  and uncovered risks in the task context pack.
- **Dependencies**: Sprint 2.
- **Acceptance Criteria**:
  - An active task receives the current coverage report.
  - Uncovered blocking rules prevent approval or verification.
  - The report distinguishes accepted scope limitations from missing work.
- **Validation**: Context-pack contract tests with intentionally incomplete
  coverage.

### Task 3.2: Add adversarial regression suite

- **Location**: `.agent-harness/tests/harness/`
- **Description**: Attempt forged approval, direct completion, skipped
  verification, altered evidence, altered snapshots, reset failure history,
  alternate finalization, and incomplete recovery.
- **Dependencies**: Tasks 1.2, 1.3, 2.2, and 2.3.
- **Acceptance Criteria**:
  - Every attack is denied or enters explicit recovery.
  - No test requires sandboxing or external identity.
  - The suite records evidence for each contract rule.
- **Validation**: Focused adversarial suite and full benchmark.

### Task 3.3: Add final coverage gate to verification

- **Location**: `.agent-harness/scripts/verify.sh`,
  `.agent-harness/scripts/check-v3-contract-coverage.sh`
- **Description**: Run contract coverage as a blocking verification gate and
  include its report in task evidence and final reports.
- **Dependencies**: Tasks 2.1 and 3.1.
- **Acceptance Criteria**:
  - Verification fails for uncovered blocking rules.
  - Finalization cannot proceed without a passing coverage report.
  - Existing v3 benchmark remains green.
- **Validation**: Verification failure injection, then full verification.

## Testing Strategy

Run in this order:

1. Contract registry schema and coverage tests.
2. Final approval and direct-completion denial tests.
3. Finalization entry-point parity tests.
4. State-transition and recovery tests.
5. Full harness benchmark.
6. `rtk .agent-harness/harness.sh verify`.
7. `rtk .agent-harness/harness.sh finalize`.

Required success target:

```text
Benchmark: 140/140 or higher if new benchmark cases are added
Contract coverage: 100% for blocking v3 rules
Uncovered blocking rules: 0
```

## Risks and Mitigations

- **Overengineering**: Keep the registry limited to authority and completion
  rules; do not turn it into a second TOC.
- **False coverage**: Require executable negative and recovery tests, not only
  filenames in metadata.
- **Same-user tampering**: Report repository-local assurance honestly; this
  improves governance and detection, not OS-level prevention.
- **Legacy drift**: Keep v2 fixtures only as rejection tests and fail if a v2
  path becomes selectable.
- **Existing task backlog confusion**: Create one new approved task for this
  plan and do not activate unrelated READY tasks.

## Rollback Plan

If the coverage gate causes unrelated regressions, disable only the new gate
through a harness-controlled feature flag in the active task while preserving
the registry and tests. Do not restore direct completion or weaken final
approval validation. Re-enable the gate after the failing contract mapping is
corrected.

## Definition of Done

- Contract registry exists and is validated.
- All blocking v3 authority rules have implementation, denial, and recovery
  coverage.
- Final human approval is validated completely.
- Direct task completion is denied.
- All finalization entry points have equivalent v3 enforcement.
- Context reports uncovered rules before implementation.
- Benchmark, verification, and harness finalization pass.
- Original TOC remains unchanged.
