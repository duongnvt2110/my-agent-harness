# Working Memory

task_id: harness_enhancement_full

## Stable Decisions

- Use the active plan as the implementation contract.
- Keep runner portability fixes minimal and test-backed.
- Auto-close story and epic only after the task is marked done.

## Important Context

- `run_all.sh` must work on macOS Bash.
- Benchmark and report docs must match the live benchmark flow.
- Snapshot file-map enforcement must apply to `my_docs`.

## Repeated Constraints

- Do not weaken the harness gates.
- Do not edit outside approved harness files.
- Preserve current task and epic lifecycle semantics.

## Do Not Forget

- Re-run verify after evidence files exist.
- Finalize only after verify passes.
