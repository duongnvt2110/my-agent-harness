# Scratch Harness

Updated: 2026-05-26 20:56

This repository is a minimal scratch harness for local coding agents.

The harness turns a human request into one active plan, bounded source changes,
required checks, evidence, review, and script-owned finalization.

This template starts clean: no active task, no completed task history, no task
evidence, no concrete reviews, and no example fixtures.

## Mental Model

```text
Human request
  -> active plan contract
  -> scripts/harness.sh next
  -> bounded Codex work
  -> scripts/verify.sh
  -> evidence and review
  -> scripts/finalize-task.sh
```

The Worker Agent owns implementation inside the approved scope. The harness owns
lifecycle transitions, gates, evidence, and completion.

## Core Files

| File | Purpose |
|---|---|
| `AGENTS.md` | Short agent entrypoint. |
| `CONTEXT.md` | Canonical harness glossary. |
| `WORKFLOW.md` | Global state machine and policy. |
| `docs/adr/` | Accepted architecture and terminology decisions. |
| `docs/PLANS.md` | Active plan schema and lane rules. |
| `docs/TEST_MATRIX.md` | Generic harness acceptance mapping. |
| `docs/exec-plans/active/current.md` | The single current task contract. |
| `scripts/harness.sh` | Prints the current task packet and routes commands. |
| `scripts/verify.sh` | Runs the hard verification gate. |
| `scripts/finalize-task.sh` | Completes and archives the active plan. |

## Start

```bash
rtk ./scripts/harness.sh next
```

If no active plan exists, create one from `docs/exec-plans/TEMPLATE.md`.

## Verify

```bash
rtk ./scripts/verify.sh
```

Verification requires an active plan and checks the plan contract, file map,
required checks, evidence, review, and test-matrix references.

## Finalize

```bash
rtk ./scripts/finalize-task.sh
```

Finalization runs fresh verification, writes completion metadata, and moves the
plan from `docs/exec-plans/active/current.md` to
`docs/exec-plans/completed/YYYY_MM_DD_<task_id>.md`.
