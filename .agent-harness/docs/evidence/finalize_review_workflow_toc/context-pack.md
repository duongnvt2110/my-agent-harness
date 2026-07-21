# Context Pack

task_id: finalize_review_workflow_toc
budget: 5000

## Active Task

Update the v3 research/review TOC with the agreed conflict and finalization workflow.

## Selected Context Files

- docs/context/repository-intelligence/README.md
- docs/context/repository-intelligence/repo-profile.yml
- docs/context/repository-intelligence/repo-map.md
- docs/context/repository-intelligence/architecture-map.md
- docs/context/repository-intelligence/module-boundaries.md
- docs/context/repository-intelligence/domain-model.md
- docs/context/repository-intelligence/business-rules.md
- docs/context/repository-intelligence/data-flow.md
- docs/context/repository-intelligence/api-contracts.md
- docs/context/repository-intelligence/database-model.md
- docs/context/repository-intelligence/implementation-patterns.md
- docs/context/repository-intelligence/testing-style.md
- docs/context/repository-intelligence/dependency-map.md
- docs/context/repository-intelligence/dangerous-areas.md
- docs/context/repository-intelligence/legacy-constraints.md
- docs/context/repository-intelligence/knowledge-index.json
- docs/decisions/0004-agent-harness-vnext-authority-model.md
- docs/decisions/0005-v2-to-v3-explicit-migration-contract.md
- docs/evidence/finalize_review_workflow_toc/full-context.md

## Repo Mode Summary

Brownfield repository-local harness; this task is documentation-only.

## Repository Intelligence

The selected repository intelligence files define the existing harness
authority, lifecycle, scope, and verification conventions.

## Impact Scan

Only the approved research/review TOC is changed as a product document.

## Convention Awareness

Use the repository's v3 terminology and keep the TOC as a human-readable review artifact.

## Business Rule Awareness

The agent cannot change locked authority or declare completion; human approval is final.

## Regression Scope

No runtime behavior changes; verify harness documentation and plan contracts.

## Verification Scope

Run `rtk .agent-harness/harness.sh verify` and then `rtk .agent-harness/harness.sh finalize`.

## Environment State

Local repository; no external services or credentials are required.

## Human Approval

The user approved the TOC update and the documented final-review workflow.

## Parent Epic Summary

No parent epic.

## Parent Story Summary

No parent story.

## Epic Memory Summary

No epic memory is required for this tiny documentation task.

## Integration Contract Summary

The public harness command surface remains unchanged.

## Clarification Summary

The scope is limited to v3 repository-local governance; excluded capabilities remain excluded.

## Selected ADRs

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: The TOC documents lifecycle authority, immutable state, and generated projections.
- id: ADR-0005 | path: docs/decisions/0005-v2-to-v3-explicit-migration-contract.md | status: Accepted | reason: The TOC remains v3-focused and does not introduce a silent v2 fallback.

## Selected Repo Memory

No additional repo memory selected.

## Localization

No localization impact.

## Brownfield Conventions

Preserve existing TOC structure, update history, and v3 terminology.

## Required Checks

- `rtk .agent-harness/harness.sh verify`
- `rtk .agent-harness/harness.sh finalize`

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/autonomous-run-report.md unless it belongs to this task
- docs/evidence/*/verification-pass.md unless it belongs to this task
