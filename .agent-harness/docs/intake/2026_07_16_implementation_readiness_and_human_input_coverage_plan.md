# Implementation Readiness and Human Input Coverage Plan

## Update History

Updated: 2026-07-16 13:19

## Purpose

Extend the v3 harness so implementation cannot begin when the human request is
incomplete, misunderstood, internally contradictory, stale, or not connected
to executable verification. The control must cover the complete human input
package—not only the research TOC—including large files, images, diagrams,
archives, repository context, URLs, and captured MCP results.

The agent remains autonomous during analysis and remediation. The harness
blocks unsafe transitions and finalization, while the agent investigates,
revises, and re-runs the readiness checks. Human authority remains the source
of normative decisions and final specification approval.

## Current Repo Findings

The repository already provides a useful partial foundation:

- `.agent-harness/scripts/intake-control.sh` creates immutable Change Packages,
  captures source snapshots, hashes source bytes, tracks blocking unknowns,
  validates stable requirement/rule/acceptance IDs, and supports specification
  approval.
- Existing intake validation requires source-to-requirement and
  requirement-to-verification traceability, but it does not inventory coverage
  units inside each source.
- `agent-interface.sh read-artifact` only accepts UTF-8 regular files and does
  not provide a complete path for binary, image, archive, or chunked inputs.
- `understand` currently reduces readiness primarily to an empty
  `blocking_unknowns` list; it does not independently validate extraction
  coverage, interpretation evidence, adversarial review, or positive/negative
  readiness tests.
- The current v3 contract checker verifies that registry paths exist, but does
  not prove that validators are invoked or that tests fail when a control is
  removed.
- Remediation records diagnosis and decisions, but repeated-failure
  fingerprints, automatic rethink transitions, and readiness rechecks after
  every remediation epoch are not yet one enforced contract.
- Existing immutable package snapshots do not yet provide a complete
  source-unit impact map that invalidates dependent readiness and evidence when
  an input changes.

## Scope

Included:

- A single per-task `implementation-readiness.md` projection backed by
  harness-controlled structured state.
- A complete input manifest and source-unit coverage ledger.
- Support contracts for text, large files, PDFs, archives, images, diagrams,
  repository context, URLs, and captured MCP results.
- Terminal classification for every source and source unit:
  `used`, `irrelevant` with a reason, or `blocked` with a reason.
- Extraction evidence, source locations, interpretation records, authority
  classification, contradictions, assumptions, derived requirements, and
  deferred proposals.
- Completeness and correctness gates before readiness and specification lock.
- Positive and negative readiness tests.
- Requirement-to-plan-to-code-to-test traceability and reverse code-change
  traceability for meaningful changes.
- Input hash drift detection, impact analysis, stale-evidence invalidation,
  immutable readiness versions, and autonomous remediation epochs.
- Repeated-failure detection that requires a different remediation strategy
  without imposing a fixed retry limit.
- Enforcement at the authoritative lifecycle transition and all public or
  low-level implementation/finalization entry points.
- Adversarial and removal tests proving that each gate actually blocks.

Excluded:

- Changes to `my_docs/agent-harness-research-review-toc.md`.
- v2 behavior, v2 fallback, or compatibility selection.
- Sandboxing, network restriction, external identity, signed releases,
  deployment control, and agent-specific adapters.
- OS-level isolation or claims that repository-local provenance prevents a
  privileged operator from editing the repository.
- Requiring the harness to classify every unrelated repository file.
- Human approval inside autonomous remediation or recovery.

## Design Contract

### 1. One readiness record, structured authority

Each task has one human-readable `implementation-readiness.md` projection. A
machine-readable block or companion state managed by the harness is the
authority for IDs, hashes, statuses, links, and transitions. The agent may
propose content but cannot rewrite accepted evidence or a locked version.

Readiness lifecycle:

`COLLECTING → ANALYZING → REMEDIATING → READY → LOCKED`

An input change creates a new readiness version and invalidates dependent
readiness, plan, implementation, and verification evidence.

### 2. Complete input coverage

Every human-provided artifact is registered with:

- Stable artifact ID, kind, location, authority role, and content hash.
- Capture metadata, timestamps, and source-specific metadata.
- Immutable snapshot reference.
- Processing units: chunks/pages for files, contained files for archives,
  semantic regions/elements for images and diagrams, and result items for MCP
  responses.
- A terminal classification for every artifact and processing unit:
  `used`, `irrelevant`, or `blocked`.

The harness must reject readiness for missing units, truncated extraction,
unsupported media, unresolved retrieval errors, or unclassified content.
Large inputs are processed incrementally; completeness is proved by discovered
versus processed unit counts and hashes, not by requiring the whole input in
the model context.

### 3. Correct interpretation and authority

Each important extracted fact or requirement records its source unit,
supporting excerpt or region, interpretation, and uncertainty. Source roles
are explicit: `normative`, `informative`, `constraint`, `reference`, or
`unknown`. Agent-inferred authority is only `proposed`; it cannot silently
become normative.

Conflicting normative inputs, unsupported assumptions affecting behavior, and
unresolved important interpretation conflicts block readiness. Derived
technical requirements link to a human requirement and are never independent
authority. Scope expansions are recorded as deferred proposals and cannot be
implemented as if approved.

### 4. Bidirectional, testable traceability

The required chain is:

`input unit → human requirement → business rule → acceptance criterion → plan item → code change → test → evidence`

Every important requirement has a positive and negative test. The verifier
checks observable behavior, not merely planned file edits. Meaningful code
changes must link to an in-scope requirement, derived constraint, defect, or
explicit implementation rationale.

### 5. Autonomous remediation without silent guessing

Readiness failures enter autonomous remediation. Each epoch records the failed
rule, diagnosis, attempted change, affected IDs, retest result, and next
strategy. A repeated failure fingerprint requires a different analysis or
strategy; it does not impose a fixed retry budget or human pause.

Implementation and finalization remain blocked until the latest complete
readiness version passes. If available evidence cannot resolve a requirement,
the task remains non-finalizable with the exact blocker recorded.

## Success Criteria

The implementation is complete when:

1. Every supported human input kind has a capture, snapshot, processing-unit,
   and coverage contract.
2. Every artifact and processing unit has exactly one terminal classification.
3. Readiness fails for skipped, truncated, unsupported, stale, conflicting,
   or incorrectly bound input evidence.
4. Important interpretations retain source evidence and cannot be accepted
   solely from agent confidence.
5. Every normative requirement has acceptance criteria, positive and negative
   tests, implementation mapping, and verification evidence.
6. Every meaningful implementation change has a reverse requirement or
   rationale link; unrequested behavior is reported as a deferred proposal.
7. Input hash changes produce a deterministic impact report and invalidate
   affected evidence.
8. Every remediation epoch re-runs the complete readiness gate.
9. Repeated identical remediation attempts enter `RETHINK_REQUIRED` and do
   not loop through the same strategy indefinitely.
10. Implementation cannot begin through public or low-level alternate paths
    unless the authoritative readiness gate passes.
11. Locked readiness and specification records are immutable and versioned.
12. Removal, corruption, stale-input, contradiction, and bypass tests fail
    when the corresponding control is removed.
13. Existing v3 benchmark, verification, and finalization remain green, and
    the original TOC is unchanged.

## Sprint 1: Canonical Readiness and Input Manifest

**Goal**: Establish one authoritative readiness artifact and complete source
inventory without changing the existing TOC.

### Task 1.1: Define readiness schemas and state transitions

- **Locations**: `.agent-harness/policies/`, `.agent-harness/scripts/`,
  `.agent-harness/runtime/`
- **Description**: Add schemas for readiness records, input artifacts,
  processing units, authority roles, classifications, remediation epochs,
  and readiness version/hash binding. Add transitions for collecting,
  analyzing, remediating, ready, locked, and rethink-required states.
- **Dependencies**: None.
- **Acceptance Criteria**:
  - Stable IDs, allowed statuses, immutable version fields, and hashes are
    validated.
  - Invalid transitions and mutation of locked records are rejected.
  - No v2 or excluded feature enters the schema.
- **Validation**: Schema tests, transition tests, lock mutation tests.

### Task 1.2: Extend Change Package source manifest

- **Locations**: `.agent-harness/scripts/intake-control.sh`,
  `.agent-harness/scripts/agent-interface.sh`, new focused helper/tests.
- **Description**: Extend source capture beyond UTF-8 files to preserve opaque
  bytes and structured metadata for binary files, images, archives, URLs, and
  MCP responses. Add explicit authority role, capture metadata, source hash,
  and source-unit inventory.
- **Dependencies**: Task 1.1.
- **Acceptance Criteria**:
  - Original bytes or captured responses are snapshotted immutably.
  - MCP records include server/tool, request/query, retrieval time, response
    hash, and retrieval error state.
  - Archives and large inputs expose deterministic processing units.
  - No unsupported or unavailable source can be silently accepted.
- **Validation**: Fixture tests for text, binary, image, archive, large file,
  URL, MCP response, retrieval failure, and hash mismatch.

### Task 1.3: Add terminal source-unit classification

- **Locations**: `.agent-harness/scripts/intake-control.sh`, readiness
  validators, intake tests.
- **Description**: Require every artifact and processing unit to be marked
  `used`, `irrelevant` with a reason, or `blocked` with a reason. Distinguish
  human inputs from selected repository context and unrelated repository
  files.
- **Dependencies**: Tasks 1.1 and 1.2.
- **Acceptance Criteria**:
  - Missing, duplicate, or unclassified units fail readiness.
  - `irrelevant` and `blocked` classifications require explanations.
  - Repository context selection is recorded without requiring an inventory
    of unrelated repository files.
- **Validation**: Remove-one-unit, duplicate-unit, unsupported-unit, and
  unrelated-repo-context tests.

## Sprint 2: Understanding and Readiness Verification

**Goal**: Prove that the agent’s interpretation is complete, correct, clear,
  and testable before implementation.

### Task 2.1: Add extraction and interpretation evidence

- **Locations**: readiness schema/validator and context-generation scripts.
- **Description**: Require source locations, supporting excerpts or visual
  regions, interpretations, uncertainty, contradictions, assumptions, and
  authority status for important extracted facts and requirements.
- **Dependencies**: Sprint 1.
- **Acceptance Criteria**:
  - Important requirements cannot pass with only an agent summary.
  - Low-confidence, contradictory, or unsupported interpretations become
    remediation blockers.
  - Agent-proposed authority remains non-normative until explicitly resolved.
- **Validation**: Wrong-image-interpretation, missing-excerpt,
  authority-promotion, and contradiction tests.

### Task 2.2: Add adversarial understanding review

- **Locations**: readiness record, verifier scripts, harness tests.
- **Description**: Require a plain-language restatement, alternative
  interpretations, edge cases, scope/non-scope, assumptions, and one positive
  and negative example for each blocking requirement.
- **Dependencies**: Task 2.1.
- **Acceptance Criteria**:
  - Vague requirements, unresolved ambiguity, and missing examples fail.
  - The verifier checks the review against source evidence and intent, not
    merely whether sections exist.
- **Validation**: Shallow-summary, missing-edge-case, contradictory-rule, and
  removal tests.

### Task 2.3: Enforce the implementation-readiness gate

- **Locations**: `.agent-harness/scripts/transition-state`,
  `.agent-harness/scripts/workflow-dispatch.sh`, public harness commands, and
  all implementation entry points.
- **Description**: Require a passing, current readiness record before any
  transition into implementation. Ensure direct low-level paths receive the
  same rejection as public commands.
- **Dependencies**: Tasks 2.1 and 2.2.
- **Acceptance Criteria**:
  - Implementation is denied for incomplete, stale, contradictory, or
    untestable readiness.
  - Remediation can continue without human approval.
  - Alternate entry points cannot bypass the gate.
- **Validation**: Public/low-level parity matrix and direct-bypass tests.

## Sprint 3: Traceability, Change Impact, and Scope Control

**Goal**: Keep implementation aligned with the exact approved intent as work
  and inputs evolve.

### Task 3.1: Complete bidirectional requirement traceability

- **Locations**: intake graph, readiness validator, task-plan checks,
  implementation evidence, tests.
- **Description**: Add stable links from input units through requirements,
  rules, acceptance criteria, plan items, meaningful code changes, tests, and
  evidence. Mark derived requirements and deferred proposals explicitly.
- **Dependencies**: Sprint 2.
- **Acceptance Criteria**:
  - Forward and reverse coverage are both required.
  - Derived requirements require a parent and rationale.
  - Unrequested meaningful changes fail finalization unless explicitly
    classified as deferred and excluded.
- **Validation**: Missing-forward-link, orphan-code-change, derived-without-
  parent, and scope-expansion tests.

### Task 3.2: Add source drift and impact analysis

- **Locations**: source snapshot/manifest validators, intake graph impact
  command, evidence invalidation logic.
- **Description**: Compare current inputs to captured hashes, identify changed
  units and dependent requirements/tasks/tests, and invalidate stale readiness
  and verification evidence.
- **Dependencies**: Task 3.1.
- **Acceptance Criteria**:
  - Any changed input is detected deterministically.
  - Impact reports identify direct and dependent work.
  - Finalization with stale dependent evidence is denied.
- **Validation**: Changed-file, changed-image, changed-MCP-response, and
  unaffected-requirement impact tests.

### Task 3.3: Add autonomous remediation epochs and rethink detection

- **Locations**: `.agent-harness/scripts/remediate.sh`, failure history and
  decision-trace scripts, transition-state, runtime evidence.
- **Description**: Re-run the complete readiness gate after every remediation
  epoch. Fingerprint failed rule plus attempted strategy and result; repeated
  fingerprints transition to `RETHINK_REQUIRED` and require a different
  strategy without a fixed retry ceiling.
- **Dependencies**: Tasks 2.3 and 3.2.
- **Acceptance Criteria**:
  - In-scope incomplete work cannot finalize.
  - Remediation remains autonomous and has no human-in-the-loop pause.
  - Identical unsuccessful strategies cannot repeat silently.
  - Recovery history is append-only and task-bound.
- **Validation**: Remediation epoch, repeated-failure, alternate-strategy,
  stale-readiness, and recovery tests.

## Sprint 4: Coverage Enforcement and Evidence Integration

**Goal**: Prove that readiness controls themselves are executable and cannot
  be weakened by metadata-only coverage.

### Task 4.1: Expand the v3 contract registry

- **Locations**: `.agent-harness/policies/v3-contract.json`,
  `.agent-harness/scripts/check-v3-contract-coverage.sh`.
- **Description**: Register input coverage, interpretation correctness,
  readiness gates, traceability, drift invalidation, remediation rethink, and
  alternate-entry enforcement as blocking v3 rules.
- **Dependencies**: Sprints 1–3.
- **Acceptance Criteria**:
  - Every rule maps to actual validators and executable tests.
  - Registry path presence alone cannot report coverage success.
  - Missing invocation or removed-control tests fail coverage.
- **Validation**: Registry mutation, validator bypass, and test-removal tests.

### Task 4.2: Integrate readiness into context, verification, and finalization

- **Locations**: context generation/checking, `verify.sh`, finalization
  scripts, reports and evidence generators.
- **Description**: Include the current readiness summary, input coverage,
  unresolved blockers, stale evidence, impact report, and contract coverage in
  task context and final evidence. Bind finalization to the latest readiness
  and locked specification hashes.
- **Dependencies**: Task 4.1.
- **Acceptance Criteria**:
  - Missing readiness evidence blocks verification and finalization.
  - Final evidence proves the chain from input snapshot to verification.
  - The existing final human approval contract remains the only finalization
    approval path.
- **Validation**: Context omission, stale-evidence, finalization mismatch,
  and alternate-entry tests.

### Task 4.3: Run full regression and benchmark coverage

- **Locations**: `.agent-harness/tests/harness/`, benchmark fixtures, reports.
- **Description**: Add deterministic fixtures for every supported input kind,
  all negative gates, recovery behavior, and removal tests. Preserve existing
  v3 benchmark behavior and exclusions.
- **Dependencies**: Tasks 4.1 and 4.2.
- **Acceptance Criteria**:
  - New focused tests pass.
  - Existing benchmark remains 140/140 or improves with documented cases.
  - `harness.sh verify` and `harness.sh finalize` pass.
  - Original TOC remains unchanged.
- **Validation**:
  - `rtk .agent-harness/harness.sh benchmark --no-history --timeout 60`
  - `rtk .agent-harness/harness.sh verify`
  - `rtk .agent-harness/harness.sh finalize`

## Testing Strategy

Run focused tests after each sprint, then run the full suite. The critical
negative matrix must include:

- Unclassified artifact or processing unit.
- Truncated large file or skipped archive member.
- Unsupported image or failed MCP retrieval.
- Incorrect interpretation without source evidence.
- Conflicting normative inputs.
- Unknown authority promoted by the agent.
- Missing acceptance criterion or missing positive/negative test.
- Orphan implementation change or unapproved scope expansion.
- Changed input hash with stale evidence.
- Remediation epoch that does not re-run readiness.
- Repeated identical failed remediation strategy.
- Direct implementation or finalization bypass.
- Removed validator or test that the registry still claims to cover.

## Risks and Mitigations

- **Overengineering input formats**: keep the core contract format-neutral;
  adapters only produce deterministic processing-unit records.
- **Large-input storage growth**: snapshot bytes once, reference them by hash,
  and store only unit metadata and evidence excerpts in readiness.
- **False semantic confidence**: require source locations and verifier checks;
  never treat model confidence as proof.
- **Repository-wide scanning cost**: classify human inputs completely and
  record only selected repository context.
- **Autonomous remediation loop**: use failure fingerprints and rethink
  transitions, not an arbitrary retry ceiling.
- **Metadata-only coverage**: use removal and invocation tests, not only path
  existence checks.
- **Scope drift**: require explicit classification of derived requirements,
  defects, clarifications, and deferred scope expansions.
- **Existing dirty worktree**: preserve unrelated changes and use the active
  task's approved file map for implementation.

## Rollback Plan

If a new readiness gate causes unrelated regressions, isolate the failing rule
through the harness-controlled active task and repair the validator or fixture.
Do not restore direct implementation/finalization bypasses, remove input
coverage requirements, or mutate locked historical records. Existing v3
authority and finalization protections remain enabled during repair.

## Definition of Done

- A single readiness record provides complete, versioned context for each task.
- All human input types in scope have deterministic capture and coverage.
- Completeness and interpretation correctness are separate blocking gates.
- Requirements, derived decisions, code changes, tests, and evidence are
  bidirectionally traceable.
- Input changes invalidate dependent work and evidence.
- Remediation is autonomous, append-only, and rethink-aware.
- Implementation and finalization cannot bypass readiness or v3 authority.
- Contract coverage is proven by executable positive, negative, removal, and
  recovery tests.
- Benchmark, verification, and finalization pass.
- The original research TOC is unchanged.
