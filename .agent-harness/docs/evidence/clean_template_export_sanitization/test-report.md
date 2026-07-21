# Test Report

task_id: clean_template_export_sanitization
result: pass
required_checks_count: 2
blocking_checks_passed: 2
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-21 11:03:51 +0700

## Checks

- id: plan-check
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/clean_template_export_sanitization/plan-check.md
- id: export-regression
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/clean_template_export_sanitization/export-regression.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
