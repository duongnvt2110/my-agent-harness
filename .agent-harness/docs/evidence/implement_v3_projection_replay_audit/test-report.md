# Test Report

task_id: implement_v3_projection_replay_audit
result: pass
required_checks_count: 2
blocking_checks_passed: 2
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-11 19:27:47 +0700

## Checks

- id: plan-check
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/implement_v3_projection_replay_audit/plan-check.md
- id: focused-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/implement_v3_projection_replay_audit/focused-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
