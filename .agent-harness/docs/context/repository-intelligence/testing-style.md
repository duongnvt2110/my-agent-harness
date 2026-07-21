# Testing Style

- Prefer focused harness regression tests.
- Keep template/export checks separate from execution checks.
- Verify the narrowest impacted command first.
- Escalate to `scripts/verify.sh` and `scripts/finalize-task.sh` only after slices pass.
