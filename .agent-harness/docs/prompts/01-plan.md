# Plan Phase

Updated: 2026-05-27 12:10

Use this reference when `scripts/harness.sh next` reports
`lifecycle_phase: PLAN`.

If requirements are still moving and no files need editing, stay in
Discussion Intake and keep the conversation in chat. Once you need a
persistent summary/report, a doc update, or implementation, create
`docs/exec-plans/active/current.md` through the guarded command:

```bash
rtk ./scripts/create-active-plan.sh <task_id> "<title>"
```

The command refuses to create a plan if `current.md` already exists. Keep the
plan task-specific and machine checkable. Do not implement until the plan
allows implementation. Do not create one active plan per discussion question.

If `docs/exec-plans/active/current.md` already exists, update that file in
place. Do not create docs/exec-plans/active/current.md manually, create a
second active plan, or work around the existing one.

Keep generated task artifacts under `docs/` by default. If the human explicitly
allows output under `my_docs/`, list the selected paths in `approved_files` and
record the decision in the active plan.

Do not decide required checks manually; they come from the active plan.
