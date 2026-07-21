# Test Report

task_id: record_vnext_governance_contract
result: pass
environment: local
generated_at: 2026-07-10 14:16:52 +0700

## Checks

- id: approved-design-contract
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/record_vnext_governance_contract/approved-design-contract.md
- id: source-plan-binding
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/record_vnext_governance_contract/source-plan-binding.md
- id: architecture-decision-record
  type: automated
  blocking: true
  timeout_seconds: 180
  result: pass
  evidence: docs/evidence/record_vnext_governance_contract/architecture-decision-record.md

## Reproducibility

Run rtk ./scripts/verify.sh from the repository root.
