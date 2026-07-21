# Scope Remediation

task_id: v3_core_bootstrap_contract_and_baseline
result: corrected
corrected_at: 2026-07-10 14:51

## Observed Failure

The file-map gate reported `.DS_Store` as a post-baseline change.

## Root Cause

The task's preserved snapshot records `repo_root: .` relative to the harness
root. A compatibility change made `check-file-map.sh` default to the repository
root even when the authoritative baseline decision recorded a different root.
The checker therefore compared the repository-root `.DS_Store` to the
harness-root `.DS_Store` entry and misreported an out-of-scope change.

## Resolution

When `--root` is not explicitly supplied, `check-file-map.sh` now uses the
exact `repo_root` recorded in the baseline decision. The same task snapshot and
workspace pass the file-map check after this correction. No file was reverted,
deleted, or added to task scope because no unauthorized path change existed.
