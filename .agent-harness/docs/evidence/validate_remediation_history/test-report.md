# Test Report

task_id: validate_remediation_history
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-12 15:56:03 +0700

## Checks

- id: task-benchmark
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/validate_remediation_history/benchmark.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
