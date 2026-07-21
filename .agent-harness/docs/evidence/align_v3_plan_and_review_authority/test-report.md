# Test Report

task_id: align_v3_plan_and_review_authority
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 20:07:23 +0700

## Checks

- id: plan-review-authority-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/align_v3_plan_and_review_authority/plan-review-authority-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
