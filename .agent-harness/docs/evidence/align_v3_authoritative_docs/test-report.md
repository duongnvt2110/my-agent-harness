# Test Report

task_id: align_v3_authoritative_docs
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 20:18:29 +0700

## Checks

- id: authoritative-docs-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/align_v3_authoritative_docs/authoritative-docs-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
