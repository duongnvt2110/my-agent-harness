# v4-core Slice Handoff

task_id: v4_slice_1_repository_evidence_correctness
slice_id: slice-1-repository-evidence-correctness
status: verified

## Decision Summary

Repository intelligence is bound to the declared repository root. A scan root
outside that repository is rejected. Inventory artifacts are deterministic,
source-bound generated evidence and do not claim verification success.

## Scope

Allowed:

- `.agent-harness/scripts/repository-intelligence.sh`
- `.agent-harness/tests/harness/test_v4_slice_1_repository_evidence.sh`
- task-local evidence under this directory

Forbidden and unchanged:

- lifecycle authority and v3 state machine
- sandboxing, network policy, external identity, signed releases
- agent adapters, ecosystem parsers, and original TOC

## Baseline

- Existing repository-intelligence commands remain available.
- Existing context-pack consumers remain compatible with generated Markdown
  artifacts.
- Full harness verification passed before finalization.

## Changed Behavior

- Default scan root is `HARNESS_REPO_ROOT`, normalized to an absolute path.
- `REPO_SCAN_ROOT` must remain within the declared repository root.
- `repo-profile.yml` records `repo.scan_root`.
- `repository-inventory.json` records schema version, generated status, scan
  root binding, relative paths, file types, sizes, executable bits, hashes,
  symlink targets, and available git status.
- Generated context evidence uses `result: generated`.

## Verification

- `rtk bash .agent-harness/tests/harness/test_v4_slice_1_repository_evidence.sh`
  — passed.
- `rtk .agent-harness/harness.sh verify` — passed, including required checks.

Evidence:

- `test-report.md`
- `context-pack.md`
- `full-context.md`
- `adr-review.md`

## Open Issues

- Historical finalization journals exist without corresponding canonical task
  rows; Slice 0 records this as a warning. It is not changed by this slice.
- Inventory currently records file content hashes but not a whole-tree content
  digest; later evaluation can decide whether that stronger aggregate is
  needed.

## Next Action

Proceed to Slice 2: deterministic context compilation, preserving this root
and generated-evidence contract.
