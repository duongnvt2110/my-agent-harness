# Test Report

task_id: remove_excluded_toc_references
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 14:53:41 +0700

## Checks

- id: plan-check
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/remove_excluded_toc_references/plan-check.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
