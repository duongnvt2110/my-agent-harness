# Test Report

task_id: 2_add_adversarial_regression_suite
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-16 19:27:06 +0700

## Checks

- id: task-benchmark
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/2_add_adversarial_regression_suite/benchmark.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
