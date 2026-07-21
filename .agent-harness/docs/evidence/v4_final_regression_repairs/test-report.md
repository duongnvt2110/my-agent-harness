# Test Report

task_id: v4_final_regression_repairs
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-18 14:26:15 +0700

## Checks

- id: v4-final-regression-repair-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/v4_final_regression_repairs/plan-check.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
