# Business Rule Awareness

task_id: remove_stale_v2_release_identity_sandbox_network_and_role_author
result: pass
recorded_at: 2026-07-16 16:15:24 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
