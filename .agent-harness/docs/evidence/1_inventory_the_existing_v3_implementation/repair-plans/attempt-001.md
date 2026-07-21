# Repair Plan

task_id: 1_inventory_the_existing_v3_implementation
result: planned
attempt: 1
patch_type: scope_remediation
targeted_retest_command: rtk ./scripts/check-file-map.sh
full_verify_command: rtk ./scripts/verify.sh
requires_human_review: false
planned_at: 2026-07-15 21:10:13 +0700
source: docs/evidence/1_inventory_the_existing_v3_implementation/failure-diagnosis.md

## Approved Scope

Approved scopes:
- harness_core
- harness_docs
- app_tests

Approved file exceptions:

## Target Files

- docs/exec-plans/active/current.md

## Repair Steps

1. Keep the active plan aligned to the preserved workspace state.
2. Run the targeted retest command from this repair plan.
3. Run the full verification command after the targeted retest passes.
