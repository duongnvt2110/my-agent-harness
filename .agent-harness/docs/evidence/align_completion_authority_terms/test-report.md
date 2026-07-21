# Test Report

task_id: align_completion_authority_terms
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 15:30:25 +0700

## Checks

- id: plan-check
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/align_completion_authority_terms/plan-check.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
