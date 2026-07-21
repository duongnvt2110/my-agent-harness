# Business Rule Awareness

task_id: implement_verifier_adapter_enforcement
result: pass
recorded_at: 2026-07-11 17:19:08 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
