# Business Rule Awareness

task_id: 1_repair_automatic_remediation_epochs_only_if_needed
result: pass
recorded_at: 2026-07-16 17:08:03 +0700

## Rules

- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
