# v4-core Slice Handoff

task_id: v4_slice_3_controlled_tool_interface
slice_id: slice-3-controlled-tool-interface
status: verified

## Decision Summary

The agent interface exposes structured tools and keeps all returned results
observation-only or proposal-only. Check execution is selected from the
locked required-check contract, while v3 boolean fixtures remain compatible.

## Changed Behavior

- Added a machine-readable `tools` catalog with a versioned policy.
- Added `run-approved-check <check_id>` for contract-bound checks.
- Restricted legacy `run-check` to locked checks plus `true`/`false`
  compatibility fixtures.
- Existing artifact reads remain repository-bound and reject symlink escapes.
- No agent submission can assert pass authority.

## Verification

- `rtk bash tests/harness/test_v4_slice_3_tool_interface.sh` from the harness
  root — passed.
- `rtk .agent-harness/harness.sh verify` — passed, including required checks.

Evidence:

- `test-report.md`
- `context-pack.md`
- `full-context.md`
- `adr-review.md`

## Open Issues

- Structured search/diff/patch operations remain future hardening within this
  v4-core area; this slice establishes the dispatch and authority boundary.
- Historical task projection drift remains the Slice 0 audit warning.

## Next Action

Proceed to Slice 4: independent verification.
