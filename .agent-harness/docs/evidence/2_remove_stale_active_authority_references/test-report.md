# Test Report

task_id: 2_remove_stale_active_authority_references
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 21:15:02 +0700

## Checks

- id: task-benchmark
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/2_remove_stale_active_authority_references/benchmark.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
