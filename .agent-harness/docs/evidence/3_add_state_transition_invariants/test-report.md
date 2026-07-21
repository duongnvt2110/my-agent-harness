# Test Report

task_id: 3_add_state_transition_invariants
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-16 19:21:42 +0700

## Checks

- id: task-benchmark
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/3_add_state_transition_invariants/benchmark.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
