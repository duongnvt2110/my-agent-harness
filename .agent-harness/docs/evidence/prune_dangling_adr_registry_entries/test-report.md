# Test Report

task_id: prune_dangling_adr_registry_entries
result: pass
required_checks_count: 1
blocking_checks_passed: 1
report_schema_version: 1
canonicalization_version: 1
environment: local
generated_at: 2026-07-15 20:21:27 +0700

## Checks

- id: adr-registry-test
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/prune_dangling_adr_registry_entries/adr-registry-test.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
