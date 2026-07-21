# Baseline Snapshot Correction

task_id: record_vnext_governance_contract
corrected_at: 2026-07-10 14:04
result: corrected

## Omitted Path

`tests/fixtures/repo-modes/brownfield/.github/workflows/ci.yml`

## Cause

The legacy snapshot generator excludes directories whose names start with
`.git`, which unintentionally excludes `.github`. The file existed in the
pre-task untracked `.agent-harness` migration and was not modified by this task.

## Recorded Identity

- sha256: `a50fa4267ee2d0b154eb373894e539acc529cc0250e53f12c1ac3061bfd603a7`
- size: `21`

The correction adds only this observed pre-existing identity. It does not
authorize edits to the fixture or broaden the task file map.
