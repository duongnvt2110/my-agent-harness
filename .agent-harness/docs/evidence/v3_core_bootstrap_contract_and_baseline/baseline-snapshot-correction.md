# Baseline Snapshot Correction

task_id: v3_core_bootstrap_contract_and_baseline
corrected_at: 2026-07-10 14:17
result: corrected

The pre-task snapshot omitted the existing
`tests/fixtures/repo-modes/brownfield/.github/workflows/ci.yml` because the
legacy generator excludes directory names beginning with `.git`. The exact
pre-existing identity was added without authorizing or changing the fixture:

- sha256: `a50fa4267ee2d0b154eb373894e539acc529cc0250e53f12c1ac3061bfd603a7`
- size: `21`

Fixing this omission with regression coverage is part of AC-002.
