# Business Rule Awareness

task_id: add_a_migration_adr
result: pass
recorded_at: 2026-07-12 12:34:12 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
