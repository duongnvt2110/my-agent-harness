# v4-core Slice Handoff

task_id: v4_slice_2_deterministic_context_compiler
slice_id: slice-2-deterministic-context-compiler
status: verified

## Decision Summary

Context compilation now produces a deterministic manifest alongside the
existing context pack. Source hashes normalize generation timestamps, so
recompilation is reproducible while source freshness remains visible.

## Changed Behavior

- `context.sh pack` writes `context-manifest.json`.
- The manifest records compiler version, budget, conservative token estimate,
  critical requirements, selected source hashes, selection reasons, and
  omission reasons.
- Context and budget gates require the manifest, generated status, source
  presence, and hard-budget compliance.
- Existing v3 context-pack sections and public commands remain intact.

## Verification

- `rtk bash .agent-harness/tests/harness/test_v4_slice_2_context_compiler.sh`
  — passed; two compilations produced identical manifests.
- `rtk .agent-harness/harness.sh verify` — passed, including required checks.

Evidence:

- `context-manifest.json`
- `test-report.md`
- `context-pack.md`
- `full-context.md`
- `adr-review.md`

## Open Issues

- The legacy context pack remains intentionally verbose for v3 compatibility;
  the manifest’s conservative estimate enforces the hard budget without
  changing existing section consumers.
- Historical finalization journals without canonical task rows remain the
  Slice 0 audit warning.

## Next Action

Proceed to Slice 3: controlled tool interface.
