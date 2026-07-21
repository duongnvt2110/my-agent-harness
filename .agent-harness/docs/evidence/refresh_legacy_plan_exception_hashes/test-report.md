# Test Report

task_id: refresh_legacy_plan_exception_hashes
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-13 10:22:04 +0700

## Checks

- id: plan-check
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/refresh_legacy_plan_exception_hashes/plan-check.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
