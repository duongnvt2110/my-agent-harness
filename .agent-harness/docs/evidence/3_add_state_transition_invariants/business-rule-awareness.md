# Business Rule Awareness

task_id: 3_add_state_transition_invariants
result: pass
recorded_at: 2026-07-16 17:41:11 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
