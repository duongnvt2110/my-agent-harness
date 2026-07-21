# Test Report

task_id: update_stale_adr_test_fixtures
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 20:25:19 +0700

## Checks

- id: adr-fixture-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/update_stale_adr_test_fixtures/adr-fixture-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
