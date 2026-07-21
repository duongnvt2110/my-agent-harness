# v3 Core Verification

## Result

The existing v3 core was verified without source rewrites. The focused checks
covered authority exclusivity, legacy rejection, role-authority removal,
finalization transactions, remediation trace, failure history, checkpoint
contracts, and projection replay.

All focused checks passed, including the two non-executable test files run
explicitly through `bash`.

## Verified invariants

- `state.json` remains the lifecycle authority.
- Lifecycle transitions and event integrity remain harness-controlled.
- Generated projections cannot become authority.
- Agent verification submissions remain non-authoritative.
- Finalization requires harness verification and approval evidence.
- Failure history can resolve to `RETHINK_REQUIRED`.
- Remediation and recovery evidence remain durable.
- No v2 fallback, sandbox, network, external identity, signed-release, or
  agent-specific authority was introduced.

## Scope result

No implementation change was required for this task. The next feature task is
the missing one-file intake/specification-lock control plane.
