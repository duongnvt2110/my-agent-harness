# v4-core Slice Handoff

task_id: v4_slice_0_contract_and_standalone_audit
slice_id: slice-0-contract-and-standalone-audit

## Decision Summary

- v4-core keeps the v3 lifecycle authority and remains repository-local `AUDIT_ONLY`.
- The audit is read-only and works without an active plan.
- Historical finalized journals without canonical task rows are warnings, not lifecycle authority changes.

## Scope

allowed_files:
  - .agent-harness/scripts/harness.sh
  - .agent-harness/scripts/audit.sh
  - .agent-harness/tests/harness/test_v4_slice_0_audit.sh
forbidden_features:
  - sandboxing
  - network restriction
  - external identity
  - provider-specific adapters
  - multi-agent orchestration

## Baseline

plan_sha256: recorded by the active-plan baseline evidence
repository_snapshot: recorded by the active-plan baseline evidence

## Implementation

changed_files:
  - .agent-harness/scripts/harness.sh
  - .agent-harness/scripts/audit.sh
  - .agent-harness/tests/harness/test_v4_slice_0_audit.sh
behavior_added:
  - public harness.sh audit command
  - task, intake, active-plan, and finalization-journal consistency checks
  - structured JSON audit output

## Verification

commands:
  - ./tests/harness/test_v4_slice_0_audit.sh
  - .agent-harness/harness.sh verify
results:
  - focused audit regression passed
  - full harness verification passed
evidence_files:
  - .agent-harness/docs/evidence/v4_slice_0_contract_and_standalone_audit/verification-pass.md
  - .agent-harness/docs/evidence/v4_slice_0_contract_and_standalone_audit/test-report.md

## Open Issues

- Current task registry contains only the current v4 contract/task rows while
  historical finalized journals remain. `harness.sh audit` reports these as a
  historical projection warning for a later reconciliation slice.

## Next Action

Finalize Slice 0, then create Slice 1 for repository evidence correctness.
