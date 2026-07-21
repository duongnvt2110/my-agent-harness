# Agent Harness vNext Baseline

## Update History

Updated: 2026-07-10 14:41
Updated: 2026-07-10 14:28
Updated: 2026-07-10 14:17

## Baseline Identity

- workflow_version: legacy v2-compatible lifecycle; the template currently
  emits `1` while task-store activation emits `2`
- implementation_version: unversioned current `.agent-harness` tree
- enforcement_mode: `AUDIT_ONLY` plus post-edit snapshot/file-map detection
- source_commit: `ed416bc84d9ffe998d140243772ecc6e120186c1`
- dirty_state: the in-progress `.agent-harness` namespace migration is
  preserved by task-local snapshot evidence

This report describes the observed pre-v3 contract. It is not a claim that v3
authority or enforcement already exists.

## Public CLI

public_cli:

```text
status
next
verify
finalize
score
benchmark
release-check
test
install
export
```

`next` is the public agent entry point. The dispatcher does not yet select a
versioned implementation from authoritative metadata and does not report an
implementation package hash, enforcement mode, or assurance limitations.

## Lifecycle and Authority

- `current.md` is the v2 task authority.
- Approval, targeted verification, full verification, and finalization write
  lifecycle fields directly.
- Task, story, and epic registries are independently mutated projections.
- Finalization invokes verification first but then marks completion before
  every later ADR/review/report/rollup action succeeds.
- There is no v3 `state.json`, transition writer, event chain, or recovery
  journal.

## Test Surface

- harness_tests: 35 shell regression files after adding dirty Git detection and
  public activation/attribution regressions in V3C-00
- runner: deterministic filename ordering with per-test timeout
- benchmark_families: project-build and brownfield fixtures
- baseline_modes: Git ref for clean repositories; snapshot for non-Git and,
  after V3C-00, dirty Git repositories
- verification_default: active-plan gates plus plan-owned required checks

The complete suite and release check are required evidence for V3C-00 and their
results are stored under the task evidence directory.

Observed V3C-00 bootstrap result:

- selected: 35
- passed: 35
- failed: 0
- timed_out: 0
- benchmark_result: pass (`140/140`)
- installed_release_check: pass

## Package Shape

package_shape:

```text
AGENTS.md
README.md
WORKFLOW.md
CONTEXT.md
.gitignore
.agent-harness/harness.sh
.agent-harness/scripts/**
.agent-harness/docs/**
.agent-harness/tests/**
.agent-harness/benchmarks/**
manifest.json
```

The manifest currently records repository name, source commit, export time,
export root, mode, pre-export Git status, template paths, and placeholder paths.
It does not contain canonical per-file hashes, a package hash, CLI/schema/policy
identities, or fixed-fixture identities. Installation overlays the target tree
rather than installing an immutable version and atomically changing a pointer.

## Release Behavior

- release_smoke_tests: baseline contract and three repository classifiers
- quality_score: currently written as literal `100`
- release_threshold: defaults to `90`
- release_decision: aggregate-score threshold
- full_suite_in_release_check: false
- benchmark_in_release_check: false
- negative_security_matrix: absent
- deterministic_replay_matrix: absent

release_invariants are defined in `docs/TEST_MATRIX.md`. From v3-core onward,
each invariant is independently blocking; aggregate or performance scores
cannot compensate for an invariant failure.

## Known Gaps

known_gaps:

1. No sole v3 state writer, generated projection, event chain, journal, or
   deterministic recovery surface exists.
2. Finalization mutates completion before every later gate and has no durable
   transaction journal.
3. Required-check execution runs repository commands without isolation and can
   persist raw output.
4. Evidence checks do not bind producer, evaluator, freshness, retention, or
   complete AC coverage.
5. Failure packets are convenience files rather than immutable failure history.
6. Version dispatch and explicit v2-to-v3 migration are absent.
7. Export/install checks validate shape but not canonical package identity or
   immutable activation.
8. Release scoring is compensable and covers only four installed smoke tests.
9. `my_docs/` is an external symlink and is not technically covered by the Git
   or harness-root snapshot file map.
10. Legacy human approval is a local assertion without v3 identity assurance.

## Baseline Commands

```bash
rtk ./tests/harness/test_dirty_git_baseline_snapshot.sh
rtk ./tests/harness/test_create_baseline_snapshot.sh
rtk ./tests/harness/test_check_file_map_snapshot.sh
rtk ./tests/harness/run_all.sh
rtk ./scripts/harness.sh release-check
```

Run these from the `.agent-harness` directory or through the public root
dispatcher where applicable.
