# Test Report

task_id: v3_core_bootstrap_contract_and_baseline
result: pass
environment: local
generated_at: 2026-07-10 22:55:07 +0700

## Checks

- id: dirty-git-baseline
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/dirty-git-baseline.md
- id: baseline-regressions
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/baseline-regressions.md
- id: snapshot-file-map
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/snapshot-file-map.md
- id: baseline-report-contract
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/baseline-report-contract.md
- id: harness-regression-suite
  type: automated
  blocking: true
  timeout_seconds: 900
  result: pass
  evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/harness-regression-suite.md
- id: release-check
  type: automated
  blocking: true
  timeout_seconds: 900
  result: pass
  evidence: docs/evidence/v3_core_bootstrap_contract_and_baseline/release-check.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
