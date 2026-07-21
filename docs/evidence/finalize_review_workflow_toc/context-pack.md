# Context Pack

task_id: finalize_review_workflow_toc
purpose: Update the v3 research/review TOC with the agreed conflict and finalization workflow.

## Authoritative task context

- User-approved scope: update only `my_docs/agent-harness-research-review-toc.md`.
- Product purpose: let coding agents work autonomously while keeping authority, verification, and completion outside the agent's control.
- This task documents behavior; it does not implement harness runtime behavior.

## Relevant repository intelligence

- `AGENTS.md`
- `.agent-harness/harness.sh`
- `.agent-harness/docs/exec-plans/active/current.md`
- `my_docs/agent-harness-research-review-toc.md`

## Decisions to capture

- Material conflicts use `CONFLICT_REVIEW_REQUIRED` and a successor package/new run.
- Normal completion is `IMPLEMENTING -> VERIFYING -> HUMAN_FINAL_REVIEW -> FINALIZED`.
- Human approval is atomic and bound to an exact repository snapshot.
- Rejection returns to implementation with a structured reason.
