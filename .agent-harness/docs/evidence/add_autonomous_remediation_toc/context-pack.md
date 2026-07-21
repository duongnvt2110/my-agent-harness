# Context Pack

task_id: add_autonomous_remediation_toc
budget: 5000

## Active Task

Document autonomous remediation, automatic budget epochs, progress detection,
and `RETHINK_REQUIRED` in the v3 research/review TOC.

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
- docs/evidence/add_autonomous_remediation_toc/full-context.md

## Repo Mode Summary

Brownfield repository-local harness; documentation-only update.

## Repository Intelligence

Existing v3 lifecycle, execution-log, verification, and finalization conventions are relevant.

## Impact Scan

Only the approved TOC is changed as a product document.

## Convention Awareness

Use existing v3 terminology and append-only history conventions.

## Business Rule Awareness

The agent remains autonomous during remediation but cannot alter locked authority or declare success.

## Regression Scope

No runtime behavior changes; verify harness contracts and evidence.

## Verification Scope

Run `rtk .agent-harness/harness.sh verify` and `rtk .agent-harness/harness.sh finalize`.

## Environment State

Local repository; no external services required.

## Human Approval

The user approved documenting this autonomous remediation workflow.

## Parent Epic Summary

No parent epic.

## Parent Story Summary

No parent story.

## Epic Memory Summary

No epic memory selected.

## Integration Contract Summary

The public harness command surface remains unchanged.

## Clarification Summary

No fixed remediation attempt limit is documented; loop detection triggers rethink rather than human intervention.

## Selected ADRs

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: Authority and state boundaries remain unchanged.
- id: ADR-0005 | path: docs/decisions/0005-v2-to-v3-explicit-migration-contract.md | status: Accepted | reason: The update remains v3-only.

## Selected Repo Memory

No additional repo memory selected.

## Localization

No localization impact.

## Brownfield Conventions

Preserve TOC structure, update history, and repository-local scope.

## Required Checks

- `rtk .agent-harness/harness.sh verify`
- `rtk .agent-harness/harness.sh finalize`

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/autonomous-run-report.md unless it belongs to this task
- docs/evidence/*/verification-pass.md unless it belongs to this task
