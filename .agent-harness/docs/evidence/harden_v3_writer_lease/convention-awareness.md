# Convention Awareness

task_id: harden_v3_writer_lease
result: pass
recorded_at: 2026-07-15 17:24:10 +0700

## Conventions

- Keep shell scripts in strict mode.
- Use `rtk` for harness commands.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.
