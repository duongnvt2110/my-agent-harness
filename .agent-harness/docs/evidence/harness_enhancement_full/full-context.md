# Full Context

## Problem Statement

The harness still had a few gaps after the migration and review pass: runner portability, timeout normalization, snapshot file-map enforcement, closeout automation, and benchmark/report alignment.

## Goal

Ship the harness enhancements end-to-end and keep the existing lifecycle gates intact.

## Current Repo State

- The harness lives under `.agent-harness/`.
- Active work is driven by `docs/exec-plans/active/current.md`.
- Benchmark output is written to `docs/reports/benchmark/latest.*`.

## Relevant Docs

- `WORKFLOW.md`
- `.agent-harness/docs/PLANS.md`
- `.agent-harness/docs/reports/README.md`
- `.agent-harness/tests/harness/test_benchmark_suite.sh`

## Relevant ADRs

- `ADR-0001`
- `ADR-0002`
- `ADR-0003`

## Constraints

- Keep the change brownfield-safe.
- Use the existing scripts rather than inventing a new flow.
- Do not bypass file-map or verification gates.

## Risks

- Harness commands can inherit the live active-plan environment.
- Finalization order matters for task/story/epic closeout.
- Benchmark probes can report the wrong state if they reuse live env vars.

## Unknowns

- Whether the benchmark runner would need isolated workers for all rows.
- Whether additional evidence files are required by downstream gates.

## Assumptions

- The closeout scripts remain the canonical source for story and epic status.
- The benchmark suite should reflect the live harness behavior, not a stubbed shortcut.

## Implementation Boundaries

- Stay within the harness namespace and its evidence/docs files.
- Keep the task contract compatible with existing plan-driven automation.

## Recommended Breakdown

1. Fix runner portability and timeout handling.
2. Tighten file-map and report alignment.
3. Wire finalizer closeout after task completion.
4. Produce the required evidence pack.
5. Verify and finalize.

## Validation Notes

- Run targeted regressions first.
- Confirm benchmark pass before final verification.
- Do not finalize until evidence gates are satisfied.
