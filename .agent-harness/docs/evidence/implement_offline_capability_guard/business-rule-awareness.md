# Business Rule Awareness

task_id: implement_offline_capability_guard
result: pass
recorded_at: 2026-07-11 20:22:40 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
