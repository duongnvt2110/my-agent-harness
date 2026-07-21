# Business Rule Awareness

task_id: reconcile_stale_task_projections
result: pass
recorded_at: 2026-07-16 21:38:32 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
