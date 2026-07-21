# Convention Awareness

task_id: harden_release_bootstrap_audit
result: pass
recorded_at: 2026-07-12 17:18:13 +0700

## Conventions

- Keep shell scripts in strict mode.
- Use `rtk` for harness commands.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.
