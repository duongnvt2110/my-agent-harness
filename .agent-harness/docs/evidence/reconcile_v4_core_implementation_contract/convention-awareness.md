# Convention Awareness

task_id: reconcile_v4_core_implementation_contract
result: pass
recorded_at: 2026-07-18 13:30:55 +0700

## Conventions

- Keep shell scripts in strict mode.
- Use the public harness driver; prefer `rtk` when installed and fall back to `bash`.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.
