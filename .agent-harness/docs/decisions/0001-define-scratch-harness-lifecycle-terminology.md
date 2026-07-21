# 0001: Define Scratch Harness Lifecycle Terminology

Date: 2026-05-26

## Status

Accepted

## Context

The optimization report uses several overlapping terms: PEV, worker, controller,
evaluator, active plan, verification, review, and finalizer. During review, we
resolved that PEV should not describe the whole harness lifecycle because the
report itself says PEV is necessary but not sufficient. Review and finalization
are separate lifecycle concerns.

Without a precise vocabulary, future scripts and docs can drift. For example,
`PEV` can accidentally be used to describe finalization, and `review` can be
collapsed into `verify.sh`.

## Decision

Use the following canonical terms:

- `Scratch Harness Lifecycle`: the full task lifecycle: `PLAN`, `EXECUTE`,
  `VERIFY`, `SCOPE_REMEDIATION`, `DIAGNOSE`, `REPAIR_PLAN`, `PATCH`, `REVIEW`,
  `FINALIZE`, `BLOCKED`, and `COMPLETED`.
- `PEV Loop`: the inner `PLAN -> EXECUTE -> VERIFY` loop only.
- `Harness Driver`: the lifecycle entrypoint that prints task packets and
  routes lifecycle commands.
- `Gate Scripts`: scripts that enforce lifecycle gates.
- `Worker Agent`: the agent performing bounded task work; Codex is the current
  worker agent.
- `Task Contract`: the role played by the active plan.
- `Active Plan`: the current file instance of the task contract.
- `Check Contract`: the verification obligations encoded by `required_checks`.
- `Verification`: script-owned gate execution.
- `Review`: semantic assessment separate from verification.
- `Finalization`: the process of completing and archiving a task.
- `Finalizer Script`: the script that performs finalization.

Avoid using `controller` as a formal domain term. Prefer `Harness Driver` and
`Gate Scripts`.

## Consequences

- Future docs should say the active plan is the current task contract.
- Future schema changes should prefer `lifecycle_phase` over a generic `phase`.
- The lifecycle driver should be named `scripts/harness.sh` because it routes
  more than the PEV Loop. The old `scripts/pev.sh` compatibility wrapper has
  been removed to keep the public command surface small.
- Review artifacts must remain distinct from verification output.
- Remediation phases should remain first-class lifecycle states rather than
  being collapsed back into verify/finalize.
