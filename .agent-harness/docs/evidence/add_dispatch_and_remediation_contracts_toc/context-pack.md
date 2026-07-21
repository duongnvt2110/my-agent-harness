# Context Pack

task_id: add_dispatch_and_remediation_contracts_toc
budget: 5000

## Active Task

Add dispatcher metadata and remediation evidence contracts to the TOC while preserving exclusions.

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
- docs/evidence/add_dispatch_and_remediation_contracts_toc/full-context.md

## Repo Mode Summary

Brownfield repository-local v3 governance documentation.

## Repository Intelligence

Dispatcher metadata, remediation evidence, decision ledger, and execution log are relevant.

## Impact Scan

Only the approved TOC is changed as a product document.

## Convention Awareness

Expose assurance limits explicitly and keep remediation artifacts linked to one run log.

## Business Rule Awareness

Legacy or audit-only behavior cannot be presented as full v3 enforcement.

## Regression Scope

No runtime implementation changes.

## Verification Scope

Run `rtk .agent-harness/harness.sh verify` and `rtk .agent-harness/harness.sh finalize`.

## Environment State

Local repository; no external services required.

## Human Approval

The user approved adding only dispatcher metadata and remediation evidence, while excluding external identity, sandboxing, and signed releases.

## Parent Epic Summary

No parent epic.

## Parent Story Summary

No parent story.

## Epic Memory Summary

No epic memory selected.

## Integration Contract Summary

The public harness command surface remains unchanged.

## Clarification Summary

Protected external identity, sandboxing, and signed-release features remain out of scope.

## Selected ADRs

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: v3 authority and assurance metadata remain canonical.
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
