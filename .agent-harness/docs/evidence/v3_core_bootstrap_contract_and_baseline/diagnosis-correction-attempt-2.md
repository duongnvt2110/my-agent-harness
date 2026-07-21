# Failure Diagnosis Correction: Attempt 2

task_id: v3_core_bootstrap_contract_and_baseline
result: corrected
corrected_at: 2026-07-10 14:53

## Generated Classification

The legacy diagnosis helper classified the required-check failure as a generic
scope mismatch. Its immutable attempt record remains under `diagnoses/`.

## Confirmed Root Cause

The default macOS Bash runtime treats expansion of an empty array as an unbound
variable under `set -u`. Snapshot-mode `check-file-map.sh` expanded the empty
`approved_deletions` array directly while constructing Python arguments, so the
dirty-Git baseline regression exited before comparison began.

## Repair

Construct one non-empty argument vector and append allowed or deletion patterns
only when their arrays contain entries. This preserves snapshot deletion
semantics while remaining compatible with Bash 3.
