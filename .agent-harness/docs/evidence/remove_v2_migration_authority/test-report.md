# Test Report

task_id: remove_v2_migration_authority
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 17:17:25 +0700

## Checks

- id: legacy-rejection-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/remove_v2_migration_authority/legacy-rejection-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
