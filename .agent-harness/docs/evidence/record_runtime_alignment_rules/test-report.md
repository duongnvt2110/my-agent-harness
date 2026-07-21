# Test Report

task_id: record_runtime_alignment_rules
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 15:53:21 +0700

## Checks

- id: plan-check
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/record_runtime_alignment_rules/plan-check.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
