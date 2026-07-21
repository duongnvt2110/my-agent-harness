# Test Report

task_id: remove_v3_verifier_adapter_authority
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 19:39:29 +0700

## Checks

- id: role-authority-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/remove_v3_verifier_adapter_authority/role-authority-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
