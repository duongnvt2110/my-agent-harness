# Test Report

task_id: v3_core_canonical_artifact_kernel
result: pass
environment: local
generated_at: 2026-07-11 10:35:10 +0700

## Checks

- id: bootstrap-health
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/v3_core_canonical_artifact_kernel/bootstrap-health.md
- id: bootstrap-prior-suite
  type: automated
  blocking: true
  timeout_seconds: 900
  result: pass
  evidence: docs/evidence/v3_core_canonical_artifact_kernel/bootstrap-prior-suite.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
