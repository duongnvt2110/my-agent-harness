# Business Rule Awareness

task_id: remove_v3_verifier_adapter_authority
result: pass
recorded_at: 2026-07-15 19:39:17 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
