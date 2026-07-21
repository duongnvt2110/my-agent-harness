# Business Rule Awareness

task_id: validate_adr_impact
result: pass
recorded_at: 2026-07-12 14:20:15 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
