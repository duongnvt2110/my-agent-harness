# Test Report

task_id: v4_slice_0_contract_and_standalone_audit
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-18 13:48:45 +0700

## Checks

- id: slice-0-audit-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/v4_slice_0_contract_and_standalone_audit/plan-check.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
