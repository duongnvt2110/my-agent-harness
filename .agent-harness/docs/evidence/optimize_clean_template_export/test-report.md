# Test Report

task_id: optimize_clean_template_export
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 20:11:30 +0700

## Checks

- id: template-export-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/optimize_clean_template_export/template-export-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
