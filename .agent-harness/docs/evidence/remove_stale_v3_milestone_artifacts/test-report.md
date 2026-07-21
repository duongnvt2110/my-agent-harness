# Test Report

task_id: remove_stale_v3_milestone_artifacts
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 20:20:12 +0700

## Checks

- id: stale-artifact-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/remove_stale_v3_milestone_artifacts/stale-artifact-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
