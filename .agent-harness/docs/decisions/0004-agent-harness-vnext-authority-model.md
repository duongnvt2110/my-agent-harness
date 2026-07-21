# ADR-0004: Adopt the Agent Harness v3 Authority Model

## Metadata

- Status: `accepted`
- Date: 2026-07-10
- Deciders: Human repository owner
- Linked RFC: No RFC; the decision was approved through the recorded vNext architecture grilling session and approved design ledger.
- Supersedes: None
- Superseded-By: None

## Context

The harness must let a coding agent work autonomously without allowing the
agent to choose its own authority or completion result. A recoverable workflow
cannot treat a mutable Markdown file, task registry, and aggregate rollups as
concurrent authorities. It needs one machine-owned state source, one transition
boundary, an immutable audit trail, and deterministic projections.

## Decision

The repository-local harness is v3-only:

- `runs/<run-id>/state.json` is the sole lifecycle authority.
- `.agent-harness/scripts/transition-state` is the sole lifecycle writer.
- Each accepted transition validates the current version and transition guard,
  appends a hash-chained event, commits state atomically, and regenerates
  projections.
- `current.md` is a generated read-only execution projection, not an authority.
- Task-store, story, and epic statuses are derived projections.
- Projection and finalization changes use durable idempotent journals with
  forward recovery.
- Direct edits to v3 lifecycle or projection fields are invalid and must be
  detected or overwritten from authoritative state.
- There is no v2 authority, migration path, or legacy fallback in the current
  repository contract. Legacy artifacts are rejected or retained only as
  non-authoritative historical evidence.
- Human approval is required to lock the contract and to finalize the outcome;
  implementation, verification, remediation, rethink, and recovery continue
  autonomously under harness control.
- The harness remains agent-neutral and repository-local. Sandboxing, network
  restriction, external identity, signed releases, deployment control, and
  agent-specific adapters are outside this kernel.

## Alternatives Considered

- Keep `current.md` authoritative and use `state.json` as an audit cache. This
  preserves direct writers and cannot prevent split-brain lifecycle state.
- Allow both files to be authoritative with reconciliation. This creates an
  ambiguous conflict policy and violates fail-closed recovery.
- Keep a v2 migration runtime. This creates a second authority model and
  conflicts with the v3-only contract.

## Consequences

### Positive

- Lifecycle transitions have one enforceable mutation boundary.
- Recovery and deterministic replay can use explicit state versions and events.
- Read-only projections remain available without granting Markdown authority.
- Aggregate task progress can be rebuilt and validated.

### Negative

- Existing direct state writers must be routed through the transition API.
- Projection generation and finalization require journal/recovery machinery.
- Legacy artifacts may remain in historical reports, but they cannot be read or
  written as current authority.

## References

- `WORKFLOW.md`
- `docs/PLANS.md`
