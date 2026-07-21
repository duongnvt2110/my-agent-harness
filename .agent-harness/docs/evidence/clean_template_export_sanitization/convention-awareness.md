# Convention Awareness

task_id: clean_template_export_sanitization
result: generated
recorded_at: 2026-07-21 11:00:35 +0700

## Conventions

- Keep shell scripts in strict mode.
- Use the public harness driver; prefer `rtk` when installed and fall back to `bash`.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.
