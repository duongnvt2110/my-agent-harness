# Business Rule Awareness

task_id: reconcile_stale_task_plan_projections
result: pass
recorded_at: 2026-07-13 10:06:10 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
