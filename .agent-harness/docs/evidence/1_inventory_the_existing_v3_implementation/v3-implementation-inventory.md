# v3 Implementation Inventory

## Scope

This inventory supports Phase 1 of
`2026_07_15_v3_harness_scope_reconciliation_plan.md`. It records existing
behavior before implementation changes. The research-review TOC was not
modified.

## Existing and verified-looking v3 core

| Contract area | Repository evidence | Initial disposition |
| --- | --- | --- |
| v3 dispatch | `scripts/workflow-dispatch.sh`, `runtime/v3-workflow.json` | Preserve; run focused tests |
| Sole lifecycle authority | `runtime/state.json`, `scripts/validate-current-state.sh` | Preserve; verify stale-source rejection |
| Sole transition writer | `scripts/transition-state` | Preserve; verify atomic/event behavior |
| Event chain | `scripts/event_store.py`, `scripts/run-events.sh`, `runtime/events.jsonl` | Preserve; verify replay/integrity |
| Read-only projection | `runtime/current.md`, `scripts/check-v3-projections` | Preserve; verify projection cannot become authority |
| Specification lock | `scripts/spec-lock.sh` | Preserve as existing primitive; assess intake integration |
| Verification/finalization | `scripts/verify.sh`, `scripts/finalize-v3-run`, `scripts/finalize-task.sh` | Preserve; verify harness ownership |
| Failure/remediation | `scripts/record-failure.sh`, `scripts/remediate.sh`, `scripts/diagnose-failure.sh` | Preserve; verify autonomous path |
| Rethink | `record-failure.sh` emits `RETHINK_REQUIRED` | Preserve; do not reintroduce `STUCK` |
| Recovery | `scripts/create-checkpoint.sh`, `restore-checkpoint.sh`, recovery journals | Preserve; verify focused crash paths |
| Agent interface | `scripts/agent-interface.sh` | Preserve; proposals remain non-authoritative |

## Confirmed gaps or mismatches

### 1. Intake control plane is incomplete

The public commands `intake`, `understand`, `clarify`, `answer`, `pause`,
`resume`, and `rollback` are registered but currently denied because their
control-plane implementation is unavailable. Existing primitives such as
`intake-graph.sh` and `spec-lock.sh` do not yet provide the complete one-file
human contract workflow described in the plan.

Disposition: Phase 2 implementation. Do not expand Phase 1 into the intake
feature.

### 2. Active documentation contains superseded concepts

The research-review TOC still contains active references to v2 cutover,
external identity, release trust, sandbox/network controls, role-based
`Verifier`, `STUCK`, and broad `ROLLED_BACK` behavior.

Disposition: Phase 1 documentation reconciliation after behavior checks. The
TOC remains unchanged during this inventory task.

### 3. Existing runtime uses some rollback terminology

Several scripts and projection checks still recognize `ROLLED_BACK`. The
settled contract excludes broad rollback as an agent-selected remediation or
completion strategy, but technical recovery terminology must be reviewed
before removing any state or compatibility branch.

Disposition: Do not delete immediately. Add a focused decision/test task after
the state transition matrix is verified.

### 4. Harness assurance boundary is audit-only

The public harness reports `enforcement_mode: AUDIT_ONLY` and explicitly limits
assurance to repository-local governance. The implementation must not claim
OS-level isolation, network enforcement, or signed-release security.

Disposition: Preserve the limitation and remove only contradictory active
requirements from documentation.

## Required focused checks for the next task

- v3 dispatch and legacy/mixed-artifact rejection.
- State authority and transition-chain validation.
- Projection replay and projection-write rejection.
- Failure history, remediation, budget, and `RETHINK_REQUIRED` behavior.
- Checkpoint restore and finalization ownership.
- Stale active-reference scan across the TOC and active harness docs.

## Phase boundary result

Phase 1 should begin with stale-reference reconciliation and focused behavior
verification. Phase 2 should implement the missing one-file intake/spec-lock
control plane only after its schemas, commands, and approved files are defined
in a separate active task.
