# Evidence

Task evidence lives under:

```text
docs/evidence/<task_id>/
```

Automated required checks write evidence files automatically.

When a task is finalized and you need a reusable template-only repo state, use
`harness.sh export --output /path/to/clean-template` to export the clean template
into a separate folder or `--zip` to package it without modifying the source
repository.

Special files:

| File | Meaning |
|---|---|
| `failure-packet.md` | Latest blocking verification failure. |
| `verification-pass.md` | Latest successful verification pass. |
| `test-report.md` | Human-readable check summary. |
| `autonomous-run-report.md` | Final autonomous execution summary. |
