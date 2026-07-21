# Business Rule Awareness

task_id: stabilize_legacy_plan_exception_snapshots
result: pass
recorded_at: 2026-07-13 10:31:57 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
