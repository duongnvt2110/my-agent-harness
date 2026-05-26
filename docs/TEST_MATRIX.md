# Test Matrix

Updated: 2026-05-26 20:56

This file contains generic harness acceptance criteria. Product-specific
criteria belong in task artifacts when a lane requires them.

| ID | Acceptance criterion | Check |
|---|---|---|
| AC-HARNESS-001 | The active plan is the single machine-readable task contract. | `rtk ./scripts/check-active-plan.sh` and `rtk ./scripts/check-active-plan-contract.sh` |
| AC-HARNESS-002 | Changed files stay inside approved scopes or `approved_files` exceptions, and deletions stay inside approved scopes or `approved_deletions`. | `rtk ./scripts/check-file-map.sh` |
| AC-HARNESS-003 | Required checks are plan-owned, RTK-wrapped, and produce evidence. | `rtk ./scripts/check-test-contract.sh` and `rtk ./scripts/run-required-checks.sh` |
| AC-HARNESS-004 | Completion requires evidence, review when required, and fresh verification. | `rtk ./scripts/check-evidence.sh`, `rtk ./scripts/check-reviews.sh`, and `rtk ./scripts/finalize-task.sh` |
