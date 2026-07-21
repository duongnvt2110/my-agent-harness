# TOC Reconciliation Evidence

## Scope

Updated `my_docs/agent-harness-research-review-toc.md` after the v3 core and
one-file intake/specification-lock behavior passed focused tests and the full
benchmark.

## Reconciled decisions

- v3 is the only active authority model; historical v2 artifacts are not
  migrated or selected.
- The Change Package is one canonical machine-readable package file.
- Human approval is the immutable specification-lock event and final review;
  execution and remediation remain autonomous.
- `RETHINK_REQUIRED` replaces the stale `STUCK` recovery wording.
- `ROLLED_BACK` is limited to harness-controlled technical restoration.
- Approval is recorded as a repository-local assertion; external identity and
  multi-person approval are outside scope.
- Release bootstrap, signed releases, sandboxing, network restriction, and
  agent-specific adapters remain excluded from the active contract.
- The readiness and review order describe v3 repository verification rather
  than release or deployment controls.

## Verification basis

- Existing v3 core focused contract tests passed.
- One-file intake control-plane regression passed.
- Public CLI compatibility regression passed.
- Script interface check passed.
- Full v3 benchmark passed `140/140`.
