# Active Authority Reconciliation

## Scope

This task reconciles active harness documentation and authority wording with
the accepted v3-only contract. Historical ADRs are retained; the human-owned
research-review TOC is intentionally not changed in this task.

## Change

Updated `docs/decisions/authority-model-v3.md` to state that:

- v3 metadata is the only active dispatch authority;
- v2 artifacts are rejected or historical evidence only;
- there is no v2 migration runtime or fallback;
- verification and finalization are harness-controlled functions;
- sandboxing, network restriction, external identity, signed releases,
  deployment control, and agent-specific adapters are outside the kernel;
- the assurance boundary is repository-local governance.

## Preserved behavior

- `state.json` remains the lifecycle authority.
- `transition-state` remains the lifecycle writer.
- Event chains, projections, recovery, remediation, rethink, verification, and
  finalization implementations were not rewritten.
- Historical ADR terminology was not deleted.

## Verification target

The next verification must confirm the updated active document, ADR integrity,
stale-reference behavior, and the existing v3 core tests without requiring any
excluded capability.
