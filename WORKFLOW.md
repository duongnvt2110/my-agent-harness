# Workflow

This document defines the Scratch Harness Lifecycle. Task-specific state belongs
in the active plan, which is the current Task Contract.

For repo-local glossary and selected memory notes, see
`.agent-harness/docs/context/README.md`.

The governance execution model is:

`Human-Approved Change Package -> Run -> Session -> Execution Log`

Tasks and implementation plans are derived working context. They are not
authoritative requirements.

## Ownership

| Owner | Responsibility |
|---|---|
| Human | Approval, scope decisions, risk acceptance. |
| Change Package | Locked requirements, business rules, acceptance criteria, and source provenance. |
| Run | Immutable execution identity bound to one locked package version. |
| Execution Log | Append-only implementation, verification, remediation, and decision history. |
| Active Plan | Current file instance of the Task Contract. |
| Harness Driver | Prints task packets and routes lifecycle commands. |
| Gate Scripts | Check lifecycle gates and reject violations when invoked. |
| Worker Agent | Performs bounded edits and fixes inside approved scope. |

## Discussion Intake

Discussion Intake is the conversation-only state before an active plan is
needed. It is for planning, grilling, clarifying, and summarizing decisions
while requirements are still moving.

Rules:

- Do not create one active plan per discussion question.
- Do not edit files or implement during Discussion Intake.
- Before implementation, create one active plan and capture the agreed state as
  a summary/report or plan update.
- Once a repo edit is needed, the active plan again becomes the task contract.

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
| `COMPLETED` | Archived completed state written by the finalizer. |

## Governance states

The run lifecycle is separate from active-plan metadata:

`IMPLEMENTING -> VERIFYING -> HUMAN_FINAL_REVIEW -> FINALIZED`

Additional machine-controlled states include:

- `CONFLICT_REVIEW_REQUIRED` — independent work may continue, but conflicting
  authority changes require a successor package.
- `RETHINK_REQUIRED` — repeated remediation strategy triggered a new diagnosis;
  no human intervention is required.
- `POST_APPROVAL_CHANGE_DETECTED` — the repository changed after final review;
  verification and review must run again.

The agent may request completion but cannot declare success or finalize a run
through the public driver. The current v3-core implementation is `AUDIT_ONLY`:
these guarantees are repository-local workflow guarantees, not an OS security
boundary. A process that bypasses the driver is outside the harness assurance
model.

## Epic / Story / Task

| Layer | Meaning |
|---|---|
| `Full Context` | Repo-grounded pre-breakdown context that must exist before decomposition. |
| `Epic` | Feature and spec intake for larger work. |
| `Story` | A bounded deliverable slice inside an epic. |
| `Task` | The executable unit for the worker agent. |
| `current.md` | The single active execution contract for one task. |

## Lanes

| Lane | Required artifacts |
|---|---|
| `tiny` | Active plan, approved file map, required checks, evidence. |
| `normal` | Tiny requirements plus review. |
| `high_risk` | Normal requirements plus product contract, design, rollback, and explicit human approval. |

Product specs, contracts, and design docs are lane-triggered. They are not
global prerequisites for every task.

## Runtime Flow

1. If requirements are still changing, use Discussion Intake without repo
   edits.
2. Compile the human request and source bundle into a Change Package with an
   understanding brief, design review, business rules, acceptance criteria,
   traceability, and behavior baseline when needed.
3. Human approval locks one canonical package version and creates one immutable
   run. Material changes create a successor package and new run.
4. Before implementation or persistent doc updates, create one active plan and
   capture the agreed state as a summary/report or plan update.
5. `.agent-harness/harness.sh next` prints the current task packet.
6. The Worker Agent works autonomously inside the locked contract and approved
   scope. It may revise its implementation plan, but not the specification.
7. Gate Scripts run active-plan, file-map, test-contract, required-check,
   evidence, and contract gates.
8. Verification failures enter autonomous remediation. Budget epochs renew
   automatically; repeated ineffective strategies trigger `RETHINK_REQUIRED`
   and require a materially different diagnosis and strategy.
9. Successful verification produces a focused human final-review packet.
10. Human final review checks the final diff, acceptance evidence, manual checks,
    scope expansion, and exact repository snapshot.
11. `.agent-harness/harness.sh finalize` runs fresh verification, rechecks the
    approved snapshot, enforces required review, and moves the active plan into
    `.agent-harness/docs/exec-plans/completed/`.
12. If you need a reusable template snapshot, run
   `.agent-harness/harness.sh export --output /path/to/package`
   to export the harness package mirror into a specific folder. A clean export
   includes the public driver, scripts, tests, reusable docs, runtime metadata,
   policies, recipes, and benchmarks. It resets runtime state and policy
   exceptions, removes prior plans, evidence, reviews, recovery data, generated
   reports, benchmark history, caches, and platform metadata, and can create a
   zip archive with `--zip`. It does not modify source repository history.
13. Repository-intelligence artifacts under
   `.agent-harness/docs/context/repository-intelligence/` classify the repo and
   task mode, then flow into the task context pack as selected knowledge for
   execution and verification. The full-context artifact sits above that pack
   as the pre-breakdown summary used to gate epic/story/task slicing.

## Required Checks

Required checks are stack-agnostic and live in the active plan.

| Type | Command | Evidence |
|---|---|---|
| `setup` | Required and always blocking; use `rtk` when available or document why a raw command is required. | Written by the runner. |
| `automated` | Required; use `rtk` when available or declare `allow_raw_command` with a reason. | Written by the runner. |

All declared checks require evidence. Non-blocking automated checks still run;
failures are recorded as warnings in verification evidence.

## Export Cleanup

`.agent-harness/harness.sh export` is the explicit export step that merges the
harness package mirror into a caller-provided output directory or the default
`harness-proof/<repo>/clean-template` location. It resets generated harness
state in the export output, copies the root template files plus
`.agent-harness/harness.sh`, `.agent-harness/scripts/`, `.agent-harness/tests/`,
and `.agent-harness/docs/` verbatim, and can optionally create a zip archive
with `--zip`. The export path defaults from `my_docs/` when available and does
not mutate the source repository.

Repository intelligence lives under
`.agent-harness/docs/context/repository-intelligence/`.
It classifies the current repo mode, selects the relevant knowledge files for
the task, and feeds those selections into the context pack and evidence trail.

<!-- BEGIN AGENT-HARNESS -->
## Agent Harness

The harness controller lives at `.agent-harness/harness.sh`.
Public commands should go through that entrypoint instead of invoking internal
scripts directly.
<!-- END AGENT-HARNESS -->

## Benchmark Gate

Use the benchmark gate when you need a higher-confidence harness verification than the normal regression suite. It checks deterministic test execution, project-build fixtures, install integrity, result schema shape, agent-task success signals, context/control quality, repair-loop metrics, and history comparison.

```bash
bash .agent-harness/harness.sh benchmark --no-history
```

Use the default command without `--no-history` when you want to record a historical benchmark sample.
## V3 Authority Exclusivity

V3 uses one canonical lifecycle/event path and strict metadata dispatch. The
authorities are:

- `run.json` for immutable run configuration and package binding.
- `state.json` as the sole current-state authority.
- `transition-state` as the sole lifecycle writer.
- `events.jsonl` as the append-only hash-chained event journal.
- `current.md` as a generated read-only projection.
- The locked Change Package as requirements authority.
- The human final-review record as completion authority.

See
`.agent-harness/docs/authority-model-v3.md` for the implemented assurance
limits and explicitly out-of-scope later phases.
