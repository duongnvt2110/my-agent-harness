# Test Matrix

## Update History

Updated: 2026-07-10 14:17

This file contains generic harness acceptance criteria. Product-specific
criteria belong in task artifacts when a lane requires them.

| ID | Acceptance criterion | Check |
|---|---|---|
| AC-HARNESS-001 | The active plan is the single machine-readable task contract. | `rtk .agent-harness/scripts/check-active-plan-contract.sh` |
| AC-HARNESS-002 | Changed files stay inside approved scopes or `approved_files` exceptions, and deletions stay inside approved scopes or `approved_deletions`. | `rtk .agent-harness/scripts/check-file-map.sh` |
| AC-HARNESS-003 | Required checks are plan-owned, RTK-wrapped, and produce evidence. | `rtk .agent-harness/scripts/check-test-contract.sh` and `rtk .agent-harness/scripts/run-required-checks.sh` |
| AC-HARNESS-004 | Completion requires evidence, review when required, and fresh verification. | `rtk .agent-harness/scripts/check-evidence.sh`, `rtk .agent-harness/scripts/check-reviews.sh`, and `rtk .agent-harness/scripts/finalize-task.sh` |
| AC-HARNESS-005 | Harness quality scoring and release gating are generated, measurable, and enforced. | `rtk .agent-harness/harness.sh score` and `rtk .agent-harness/harness.sh release-check` |
| AC-HARNESS-006 | Harness benchmarks include deterministic runner timeout, real project-build fixtures, result schema, install fixture validation, agent-task evaluation, context/control evaluation, repair-loop metrics, and history comparison. | `rtk .agent-harness/harness.sh benchmark --no-history` and `rtk .agent-harness/tests/harness/test_benchmark_suite.sh` |

## v3-Core Release Invariants

Every row below is independently release-blocking. `required_result` is
`pass`, and `failure_tolerance` is `zero` for every correctness or security
invariant. Aggregate quality scores and performance budgets cannot offset a
failure.

| ID | release_invariants | Required proof | Planned gate |
|---|---|---|---|
| V3-INV-001 | Only `transition-state` mutates authoritative v3 lifecycle state; projections cannot gain authority. | Sole-writer scan, legal/illegal transition fixtures, projection tamper replay | `test_v3_state_authority.sh` |
| V3-INV-002 | Event gaps, reordering, hash mismatch, stale leases, and stale fencing tokens fail closed. | Corruption and concurrent-writer fixtures | `test_v3_event_chain_and_leases.sh` |
| V3-INV-003 | Every journal step resumes deterministically after a crash and refuses unexpected before/after state. | Failpoint matrix and replay hashes | `test_v3_journal_recovery.sh` |
| V3-INV-004 | Active v2 work is never migrated implicitly; explicit migration is identity-bound and lossless. | v2 golden, mixed-artifact, migration, and lossy-rejection fixtures | `test_v3_migration_and_dispatch.sh` |
| V3-INV-005 | Every blocking AC independently passes trusted, fresh, matching evidence. | Coverage, freshness, producer/evaluator, and broad-suite-negative fixtures | `test_v3_ac_evidence.sh` |
| V3-INV-006 | Evidence is sanitized, retention-classified, and rejects forgery or untrusted authority. | Secret/PII vectors, retention matrix, forged evidence fixtures | `test_v3_evidence_safety.sh` |
| V3-INV-007 | Exact approval context, identity assurance, single use, expiry, and emergency revocation are enforced. | Replay, stale context, weak identity, and revoke fixtures | `test_v3_approval_authority.sh` |
| V3-INV-008 | Missing technical controls deny affected high-risk mutation even with human approval. | `AUDIT_ONLY` and missing-control negative fixtures | `test_v3_high_risk_denial.sh` |
| V3-INV-009 | Every failure remains durable; flakiness, epochs, thresholds, and immediate escalation follow policy. | Failure-family and remediation-loop fixtures | `test_v3_failure_history.sh` |
| V3-INV-010 | Finalization reaches `FINALIZED` only after every gate and projection journal step succeeds. | Failure injection after every step, no-premature-completion assertion | `test_v3_finalization.sh` |
| V3-INV-011 | Export/install uses canonical package identity, immutable versions, and atomic activation. | Tamper, interrupted activation, old-run binding, clean-export fixtures | `test_v3_package_identity.sh` |
| V3-INV-012 | No committed state is lost and no two writers can mutate one checkout after restart or recovery. | Restart, recovery, fencing, and concurrent-writer fixtures | `test_v3_recovery_availability.sh` |
| V3-INV-013 | Public CLI names, documented fields, semantic exit codes, and v2 behavior stay compatible through the migration window. | Golden output and installed-package compatibility fixtures | `test_v3_cli_compatibility.sh` |

The v3-core release gate must execute every implemented row above from the
installed candidate package under trusted-prior-release or protected external
validation. Missing planned gates block v3-core release; they are not warnings.
