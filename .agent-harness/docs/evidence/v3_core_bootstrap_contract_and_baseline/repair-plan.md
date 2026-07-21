# Repair Plan

task_id: v3_core_bootstrap_contract_and_baseline
result: planned
attempt: 3
patch_type: legacy_baseline_attribution_compatibility
targeted_retest_command: rtk ./tests/harness/run_all.sh --filter test_consume_plan_and_rollup.sh
full_verify_command: rtk ./scripts/verify.sh
requires_human_review: false
planned_at: 2026-07-10 14:55:08 +0700
source: docs/evidence/v3_core_bootstrap_contract_and_baseline/failure-diagnosis.md

## Approved Scope

Approved scopes:
- harness_core
- harness_docs
- app_tests

Approved file exceptions:

## Target Files

- scripts/list-baseline-changes.sh

## Repair Steps

1. Prefer the authoritative baseline decision when it exists.
2. For legacy plans only, accept an exact valid Git `baseline_ref` from the plan.
3. Keep missing, null, ambiguous, and invalid baselines fail-closed.
4. Run the focused roll-up regression, then full verification.
