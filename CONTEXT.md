# Context Glossary

## Scratch Harness Lifecycle

The full task lifecycle controlled by the scratch harness: `PLAN`, `EXECUTE`,
`VERIFY`, `REVIEW`, `FINALIZE`, and `BLOCKED`.

## PEV Loop

The inner `PLAN -> EXECUTE -> VERIFY` loop. PEV does not include review or
finalization.

## Task Packet

The bounded instruction packet printed by `scripts/harness.sh next` for the current
task state.

## Active Plan

The single machine-readable task contract for current work.

## Task Contract

The role played by the active plan: it defines the approved scope, lifecycle
state, required checks, evidence requirements, and completion gates for one task.

## Check Contract

The required verification obligations for a task, including commands, blocking
behavior, evidence paths, and result semantics. In the task contract this is
encoded by the `required_checks` field.

## Evidence

Durable proof that a lifecycle gate was satisfied or failed. Evidence can
include automated check output, verification pass records, failure packets,
manual test notes, review references, or human approval records.

## Failure Packet

Evidence of the latest blocking failure, shaped as a repair instruction for the
next worker turn.

## Verification

Script-owned gate execution against the task contract, check contract, file
map, evidence, review requirements, and test matrix.

## Review

A semantic assessment of the task against the task contract, changed files,
evidence, and remaining risks. Review is distinct from verification.

## Worker Agent

The agent that performs bounded task work inside the approved task contract.
Codex is the current worker agent.

## Harness Driver

The lifecycle entrypoint that prints task packets and routes lifecycle commands.
It controls the Scratch Harness Lifecycle, not only the PEV Loop.

## Gate Scripts

Scripts that enforce specific lifecycle gates, such as task-contract validation,
file-map checks, check-contract validation, evidence validation, and review
validation.

## Lifecycle Phase

The current machine-readable state inside the Scratch Harness Lifecycle, such as
`PLAN`, `EXECUTE`, `VERIFY`, `REVIEW`, `FINALIZE`, or `BLOCKED`.

## Finalization

The process of completing and archiving a task after required gates pass.

## Finalizer Script

The script that performs finalization. It is not a separate agent role.
