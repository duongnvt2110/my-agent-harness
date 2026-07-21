# Failure Diagnosis Correction: Attempt 3

task_id: v3_core_bootstrap_contract_and_baseline
result: corrected
corrected_at: 2026-07-10 14:55

## Generated Classification

The legacy diagnosis helper classified the suite failure as a generic scope
mismatch. Its immutable attempt record remains under `diagnoses/`.

## Confirmed Root Cause

`list-baseline-changes.sh` required a baseline-decision artifact for every task.
The v2 consume-and-roll-up fixture represents a valid legacy task that predates
that artifact and binds its baseline through the plan's exact Git
`baseline_ref`. This broke the declared v2 compatibility window.

## Repair

Continue to prefer baseline-decision authority. When it is absent, accept only
a non-null, Git-verified legacy `baseline_ref`; all ambiguous or invalid legacy
state remains blocked.
