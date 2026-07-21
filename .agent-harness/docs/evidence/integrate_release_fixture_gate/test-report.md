# Test Report

task_id: integrate_release_fixture_gate
result: pass
required_checks_count: 2
blocking_checks_passed: 2
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-11 20:14:57 +0700

## Checks

- id: plan-check
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/integrate_release_fixture_gate/plan-check.md
- id: focused-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/integrate_release_fixture_gate/focused-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
