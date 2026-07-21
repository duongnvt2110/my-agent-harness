# Context Pack

task_id: align_toc_and_workflow
budget: 5000

## Active Task

Update the TOC as the design source and align WORKFLOW.md as its operational projection.

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
- docs/evidence/align_toc_and_workflow/full-context.md

## Repo Mode Summary

Brownfield repository-local v3 governance documentation.

## Repository Intelligence

The TOC is the design source and WORKFLOW.md is the operational guidance.

## Impact Scan

Only the approved TOC and WORKFLOW.md files are changed as product documents.

## Convention Awareness

Preserve update history, v3 terminology, and public harness entrypoint rules.

## Business Rule Awareness

The locked package controls requirements; the harness controls verification and finalization.

## Regression Scope

No runtime implementation changes; verify documentation and harness contracts.

## Verification Scope

Run `rtk .agent-harness/harness.sh verify` and `rtk .agent-harness/harness.sh finalize`.

## Environment State

Local repository; no external services required.

## Human Approval

The user approved updating the TOC first and then aligning WORKFLOW.md.

## Parent Epic Summary

No parent epic.

## Parent Story Summary

No parent story.

## Epic Memory Summary

No epic memory selected.

## Integration Contract Summary

The public `.agent-harness/harness.sh` command surface remains unchanged.

## Clarification Summary

No sandbox, external identity, signed-release, or agent-adapter feature is added.

## Selected ADRs

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: v3 authority alignment.
- id: ADR-0005 | path: docs/decisions/0005-v2-to-v3-explicit-migration-contract.md | status: Accepted | reason: v3-only compatibility alignment.

## Selected Repo Memory

No additional repo memory selected.

## Localization

No localization impact.

## Brownfield Conventions

Preserve existing document structure and update stamps.

## Required Checks

- `rtk .agent-harness/harness.sh verify`
- `rtk .agent-harness/harness.sh finalize`

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/autonomous-run-report.md unless it belongs to this task
- docs/evidence/*/verification-pass.md unless it belongs to this task
