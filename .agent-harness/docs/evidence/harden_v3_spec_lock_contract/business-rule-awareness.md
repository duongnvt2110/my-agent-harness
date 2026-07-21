# Business Rule Awareness

task_id: harden_v3_spec_lock_contract
result: pass
recorded_at: 2026-07-15 17:20:28 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
