# Failure Diagnosis Correction

task_id: v3_core_bootstrap_contract_and_baseline
result: corrected
corrected_at: 2026-07-10 14:30

## Original Classification

The legacy diagnosis helper classified the required-check failure as stale
file-map state. Its immutable attempt record remains under `diagnoses/`.

## Confirmed Root Cause

`run-required-checks.sh` executes with the active harness path variables
exported. `tests/harness/run_all.sh` passed those variables into each fixture.
The finalization fixture's temporary harness therefore resolved scripts from
the active repository instead of its isolated fixture tree. A direct suite run
without those inherited variables passed, while the task-owned run failed.

## Repair

The suite runner now removes `HARNESS_*`, `HARNESS_STATE_DIR`, and `PLAN_PATH`
from each test process. A contaminated-environment targeted run of
`test_finalize_updates_epic_progress.sh` passes after the change.
