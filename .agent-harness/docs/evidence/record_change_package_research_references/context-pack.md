# Context Pack

task_id: record_change_package_research_references
budget: 5000

## Active Task

Record research references in the review TOC.

## Selected Context Files

- docs/context/README.md
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

## Repo Mode Summary

Brownfield repository-local harness; docs-only TOC update.

## Repository Intelligence

Selected files describe current authority and documentation conventions.

## Impact Scan

No runtime behavior changes.

## Convention Awareness

Research references are explanatory and do not become task authority.

## Business Rule Awareness

The Human-Approved Change Package remains the review boundary.

## Regression Scope

Confirm all four references and their purposes appear in the TOC.

## Verification Scope

Run harness verification and diff checks.

## Environment State

Local filesystem; no external services required.

## Human Approval

Human requested that the research URLs be recorded before discussion continues.

## Parent Epic Summary

No parent epic.

## Parent Story Summary

No parent story.

## Epic Memory Summary

No epic memory.

## Integration Contract Summary

No integration contract.

## Clarification Summary

The references inform implementation review only.

## Selected ADRs

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: v3 authority remains canonical.

## Selected Repo Memory

Prior authority decisions were verified against the live repository.

## Localization

No localization changes.

## Brownfield Conventions

Preserve unrelated worktree changes.

## Required Checks

- /Users/exe-macbook/.local/bin/rtk ./harness.sh next

## Do Not Read

- docs/exec-plans/completed/*
