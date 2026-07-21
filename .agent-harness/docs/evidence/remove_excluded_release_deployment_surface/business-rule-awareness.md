# Business Rule Awareness

task_id: remove_excluded_release_deployment_surface
result: pass
recorded_at: 2026-07-15 19:52:55 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
