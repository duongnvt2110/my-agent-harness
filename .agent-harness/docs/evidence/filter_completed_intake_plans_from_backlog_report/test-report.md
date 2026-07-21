# Test Report

task_id: filter_completed_intake_plans_from_backlog_report
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-16 22:11:53 +0700

## Checks

- id: intake-backlog-report-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/filter_completed_intake_plans_from_backlog_report/plan-check.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
