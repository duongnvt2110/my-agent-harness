# Business Rule Awareness

task_id: add_focused_tests_for_stale_artifact_rejection_lifecycle_transit
result: pass
recorded_at: 2026-07-16 16:34:57 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
