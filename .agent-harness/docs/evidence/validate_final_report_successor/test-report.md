# Test Report

task_id: validate_final_report_successor
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-12 16:12:51 +0700

## Checks

- id: task-benchmark
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/validate_final_report/benchmark.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
