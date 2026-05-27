# Plan Phase

Updated: 2026-05-26 23:43

Use this reference when `scripts/harness.sh next` reports
`lifecycle_phase: PLAN`.

Create `docs/exec-plans/active/current.md` through the guarded command:

```bash
rtk ./scripts/create-active-plan.sh <task_id> "<title>"
```

The command refuses to create a plan if `current.md` already exists. Keep the
plan task-specific and machine checkable. Do not implement until the plan
allows implementation.

If `docs/exec-plans/active/current.md` already exists, update that file in
place. Do not create docs/exec-plans/active/current.md manually, create a
second active plan, or work around the existing one.

Keep generated task artifacts under `docs/` by default. If the human explicitly
allows output under `my_docs/`, list the selected paths in `approved_files` and
record the decision in the active plan.
