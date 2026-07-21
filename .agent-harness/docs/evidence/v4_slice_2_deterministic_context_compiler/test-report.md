# Test Report

task_id: v4_slice_2_deterministic_context_compiler
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-18 14:02:48 +0700

## Checks

- id: slice-2-context-compiler-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/v4_slice_2_deterministic_context_compiler/plan-check.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
