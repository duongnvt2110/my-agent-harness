# Context Pack

task_id: add_source_change_workflow_toc
budget: 5000

## Active Task

Add frozen-source and `SOURCE_CHANGED` handling to the TOC source-bundle contract.

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
- docs/evidence/add_source_change_workflow_toc/full-context.md

## Repo Mode Summary

Brownfield repository-local governance documentation.

## Repository Intelligence

Source provenance, package locking, successor runs, and evidence binding are relevant.

## Impact Scan

Only the approved TOC is changed as a product document.

## Convention Awareness

Use source hashes, frozen snapshots, assurance limitations, and successor-package terminology.

## Business Rule Awareness

Live source changes cannot silently alter a locked package.

## Regression Scope

No runtime implementation changes.

## Verification Scope

Run `rtk .agent-harness/harness.sh verify` and `rtk .agent-harness/harness.sh finalize`.

## Environment State

Local repository; no external services required.

## Human Approval

The user approved documenting frozen source and `SOURCE_CHANGED` handling.

## Parent Epic Summary

No parent epic.

## Parent Story Summary

No parent story.

## Epic Memory Summary

No epic memory selected.

## Integration Contract Summary

The public harness command surface remains unchanged.

## Clarification Summary

Unreproducible dynamic retrieval is an assurance limitation, not a silent update.

## Selected ADRs

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: v3 package and run authority remains canonical.
- id: ADR-0005 | path: docs/decisions/0005-v2-to-v3-explicit-migration-contract.md | status: Accepted | reason: v3-only scope remains canonical.

## Selected Repo Memory

No additional repo memory selected.

## Localization

No localization impact.

## Brownfield Conventions

Preserve TOC structure and update stamps.

## Required Checks

- `rtk .agent-harness/harness.sh verify`
- `rtk .agent-harness/harness.sh finalize`

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/autonomous-run-report.md unless it belongs to this task
- docs/evidence/*/verification-pass.md unless it belongs to this task
