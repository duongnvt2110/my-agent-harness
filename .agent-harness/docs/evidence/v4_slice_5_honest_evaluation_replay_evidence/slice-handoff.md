# v4-core Slice Handoff

task_id: v4_slice_5_honest_evaluation_replay_evidence
slice_id: slice-5-honest-evaluation-replay-evidence
status: verified

## Decision Summary

Replay reports now separate harness conformance, agent capability, and verifier
outcome. Known solutions explicitly make agent capability `NOT_MEASURED`.
Reports redact secret-like values and bind the report to the input artifact
and verifier/context hashes.

## Changed Behavior

- Added `replay-report.sh` for deterministic report construction.
- Conformance is sourced from harness checks, not agent claims.
- Known-solution runs cannot be counted as agent capability success.
- Replay output records verifier identity, artifact hashes, redaction version,
  and reconstruction fields.

## Verification

- `rtk bash tests/harness/test_v4_slice_5_replay_evidence.sh` — passed.
- `rtk .agent-harness/harness.sh verify` — passed, including required checks.

Evidence:

- `test-report.md`
- `context-pack.md`
- `full-context.md`
- `adr-review.md`

## Open Issues

- External-agent task benchmarks remain an explicit input contract; this slice
  does not invent a provider adapter or claim agent capability without one.
- Historical task projection drift remains the Slice 0 audit warning.

## Next Action

Run the final v4-core regression, standalone audit, benchmark/evaluation checks,
rollup projection, and completion audit.
