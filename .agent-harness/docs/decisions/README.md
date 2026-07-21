# Decision Policy

## Update History

Updated: 2026-06-04 16:02
Updated: 2026-06-04 14:41

Decision records capture durable harness decisions that should outlive a
single task's evidence.

Create or update a decision record for:

- Architecture changes.
- Harness policy changes.
- Environment or testing strategy changes.
- Reusable patterns.
- Long-term maintenance impact.

Do not create a decision record for:

- Ordinary test failures.
- One-off implementation fixes.
- Auto-reverted wrong-file changes.
- Temporary environment failures.

Task-local facts belong in `docs/evidence/<task_id>/`. Semantic review findings
belong in `docs/reviews/<task_id>.md`.
