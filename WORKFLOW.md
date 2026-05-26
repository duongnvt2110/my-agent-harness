# Workflow

Updated: 2026-05-26 20:56

This document defines the Scratch Harness Lifecycle. Task-specific state belongs
in the active plan, which is the current Task Contract.

For canonical terminology, see `CONTEXT.md`.

## Ownership

| Owner | Responsibility |
|---|---|
| Human | Approval, scope decisions, risk acceptance. |
| Active Plan | Current file instance of the Task Contract. |
| Harness Driver | Prints task packets and routes lifecycle commands. |
| Gate Scripts | Enforce lifecycle gates. |
| Worker Agent | Performs bounded edits and fixes inside approved scope. |

## Statuses

| Status | Meaning |
|---|---|
| `DRAFT` | Plan exists but is not approved. |
| `BLOCKED` | Human input or approval is required. |
| `APPROVED` | Plan is approved but work has not started. |
| `IN_PROGRESS` | Work is underway. |
| `VERIFICATION_FAILED` | A blocking gate failed. |
| `VERIFIED` | Verification passed and the task is ready to finalize. |
| `COMPLETED` | Finalizer archived the task. |

## Phases

| Phase | Meaning |
|---|---|
| `PLAN` | Create or update the active plan. |
| `EXECUTE` | Make bounded changes inside `approved_files`. |
| `VERIFY` | Run required checks and gate scripts. |
| `REVIEW` | Create or evaluate the review artifact. |
| `FINALIZE` | Run finalizer and archive the active plan. |
| `BLOCKED` | Stop and ask the human. |

## Lanes

| Lane | Required artifacts |
|---|---|
| `tiny` | Active plan, approved file map, required checks, evidence. |
| `normal` | Tiny requirements plus review. |
| `high_risk` | Normal requirements plus product contract, design, rollback, and explicit human approval. |

Product specs, contracts, and design docs are lane-triggered. They are not
global prerequisites for every task.

## Runtime Flow

1. `scripts/harness.sh next` prints the current task packet.
2. The Worker Agent performs only the next bounded action.
3. Gate Scripts run active-plan, file-map, test-contract, evidence, review, and
   test-matrix gates.
4. Blocking verification failures write
   `docs/evidence/<task_id>/failure-packet.md`.
5. Successful verification writes
   `docs/evidence/<task_id>/verification-pass.md`.
6. `scripts/finalize-task.sh` runs fresh verification and moves the active plan
   into `docs/exec-plans/completed/`.
