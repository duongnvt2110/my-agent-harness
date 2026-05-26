# Plan Contract

Updated: 2026-05-26 20:56

The active plan is the single machine-readable task contract.

Active path:

```text
docs/exec-plans/active/current.md
```

Only one active plan is allowed.

## Required Frontmatter

```yaml
task_id: lowercase_snake_case
title: Short title
status: IN_PROGRESS
lifecycle_phase: EXECUTE
lane: normal
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 1
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "YYYY-MM-DD HH:MM"
baseline_ref: <git-ref>
file_map_approved: true
review_required: true
evidence_required: true
requires_rollback_plan: false
requires_human_approval: false
test_matrix_refs:
  - AC-HARNESS-001
approved_scopes:
  - harness_core
  - harness_docs
approved_files: []
approved_deletions: []
required_checks:
  - id: unit-tests
    type: automated
    command: "rtk npm test"
    blocking: true
    evidence: "docs/evidence/<task_id>/unit-tests.md"
```

## Enums

Statuses:

```text
DRAFT
BLOCKED
APPROVED
IN_PROGRESS
VERIFICATION_FAILED
VERIFIED
COMPLETED
```

Phases:

```text
PLAN
EXECUTE
VERIFY
REVIEW
FINALIZE
BLOCKED
```

Lanes:

```text
tiny
normal
high_risk
```

Clarification statuses:

```text
CLEAR
BLOCKED
DEFAULTS_APPROVED
```

## Scope Catalog

Named scopes are the primary way to keep task contracts short. Use them first,
then add `approved_files` only for exceptions that do not fit a named scope.

| Scope | Expands to |
|---|---|
| `harness_core` | `AGENTS.md`, `CONTEXT.md`, `README.md`, `WORKFLOW.md`, `scripts/**` |
| `harness_docs` | `docs/PLANS.md`, `docs/TEST_MATRIX.md`, `docs/prompts/**`, `docs/exec-plans/**`, `docs/evidence/**`, `docs/reviews/**`, `docs/adr/**`, `docs/product-specs/**`, `docs/product-contracts/**`, `docs/design-docs/**`, `docs/reference/**` |
| `app_source` | `src/**`, `app/**`, `pages/**`, `components/**`, `lib/**`, `internal/**`, `pkg/**`, `cmd/**` |
| `app_tests` | `tests/**`, `test/**`, `__tests__/**`, `*_test.*`, `*.test.*` |
| `app_config` | `package.json`, lockfiles, `tsconfig*`, `go.mod`, `go.sum`, `Cargo.toml`, `pyproject.toml`, `Makefile`, `.env.example`, common app config files |
| `app_docs` | `README.md`, `docs/**`, `CHANGELOG.md`, `CONTRIBUTING.md` |
| `task_evidence` | `docs/evidence/<task_id>/**` |
| `empty_folder_cleanup` | `docs/clarifications/**`, `docs/decisions/**`, `docs/learnings/**`, `docs/references/**`, `docs/tutorials/**` |
| `legacy_cleanup` | `ARCHITECTURE.md`, `docs/FRONTEND.md`, `docs/GATES.md`, `docs/PRODUCT_SENSE.md`, `docs/QUALITY_SCORE.md`, `docs/RELIABILITY.md`, `docs/RISK_LANES.md`, `docs/SECURITY.md`, `docs/START_HERE.md`, `docs/index.md`, `docs/generated/**`, `docs/stories/**`, `docs/prompts/**`, `scripts/check-*`, `scripts/copy-harness-instance.sh`, `scripts/generate-docs.sh`, `scripts/init.sh` |

## Rules

- `task_id` must be lowercase snake_case.
- `implementation_allowed: true` requires `approved_by`, `approved_at`,
  `baseline_ref`, `file_map_approved: true`, and no blocking questions.
- `baseline_ref` is required before implementation.
- `approved_scopes` is required for every plan.
- `approved_files` is optional and should be used for exceptions only.
- `approved_deletions` is required and may be empty.
- `required_checks` is required and must use `rtk` commands by default.
- `normal` and `high_risk` lanes require `review_required: true`.
- `normal` and `high_risk` lanes require non-empty `test_matrix_refs`.
- `high_risk` requires rollback and explicit human approval.
