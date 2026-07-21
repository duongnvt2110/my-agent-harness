# Business Rule Awareness

task_id: 1_enforce_v3_only_artifact_selection
result: pass
recorded_at: 2026-07-16 15:52:26 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
