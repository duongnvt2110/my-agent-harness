# Repo Map

This repository is a scratch harness for agent-assisted development.

Major areas:

- `scripts/`: harness driver, gate scripts, verification, remediation, and finalization.
- `docs/`: workflow contract, context docs, plans, evidence, and release reports.
- `tests/harness/`: regression coverage for the harness lifecycle and template export.
- `my_docs/`: human-owned guardrail path and plan inputs.

The repo is brownfield from the harness point of view because the workflow,
gates, and evidence model already exist and must be preserved while extending
them.
