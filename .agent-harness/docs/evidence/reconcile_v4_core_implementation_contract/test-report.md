# Test Report

task_id: reconcile_v4_core_implementation_contract
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-18 13:31:26 +0700

## Checks

- id: plan-contract-check
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/reconcile_v4_core_implementation_contract/plan-check.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
