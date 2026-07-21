# Test Report

task_id: implement_offline_capability_guard
result: pass
required_checks_count: 2
blocking_checks_passed: 2
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-11 20:23:08 +0700

## Checks

- id: plan-check
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/implement_offline_capability_guard/plan-check.md
- id: focused-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/implement_offline_capability_guard/focused-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
