# v4-core Slice Handoff

task_id: v4_slice_4_independent_verification
slice_id: slice-4-independent-verification
status: verified

## Decision Summary

The harness now verifies proposals independently. It computes the locked plan
hash and repository workspace hash, runs only the required checks declared by
the plan, ignores the agent’s claimed success, and emits a distinct
`HARNESS_VERIFICATION` verdict.

## Changed Behavior

- Added `verify-proposal.sh` with hash-bound plan/workspace checks.
- Required-check results are captured in the verifier output.
- Stale plans and failed checks produce `FAILED` and cannot authorize
  finalization.
- Passing output is explicitly harness-owned and proposal-independent.

## Verification

- `rtk bash tests/harness/test_v4_slice_4_independent_verification.sh` from the
  harness root — passed.
- `rtk .agent-harness/harness.sh verify` — passed, including required checks.

Evidence:

- `test-report.md`
- `context-pack.md`
- `full-context.md`
- `adr-review.md`

## Open Issues

- Workspace hashing uses the repository’s Git index listing; a later replay
  slice can add richer artifact snapshots without changing this authority
  boundary.
- Historical task projection drift remains the Slice 0 audit warning.

## Next Action

Proceed to Slice 5: honest evaluation and replay evidence.
