# Test Report

task_id: enforce_v3_remediation_trace
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 17:35:52 +0700

## Checks

- id: remediation-trace-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/enforce_v3_remediation_trace/remediation-trace-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
