# Context Pack

task_id: update_research_review_change_package
budget: 5000

## Active Task

Add the Human-Approved Change Package workflow to the research review TOC.

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
- docs/decisions/0005-v2-to-v3-explicit-migration-contract.md

## Repo Mode Summary

Brownfield repository-local harness; this is a docs-only TOC update.

## Repository Intelligence

The selected repository-intelligence files describe the current authority,
lifecycle, architecture, and verification conventions.

## Impact Scan

No runtime behavior changes.

## Convention Awareness

Keep v3 authority language and human-owned `my_docs` scope.

## Business Rule Awareness

Human intent becomes authoritative only after review and specification lock.

## Regression Scope

Confirm the TOC includes source provenance, design review, business rules, and
acceptance mapping while preserving the existing exclusions.

## Verification Scope

Run harness verification and diff checks.

## Environment State

Local filesystem; no external services required.

## Human Approval

Human approved the Human-Approved Change Package concept for this TOC update.

## Parent Epic Summary

No parent epic.

## Parent Story Summary

No parent story.

## Epic Memory Summary

No epic memory.

## Integration Contract Summary

No integration contract.

## Clarification Summary

The package accepts text, files, images, diagrams, spreadsheets, and MCP
references as source material.

## Selected ADRs

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: v3 authority remains canonical.
- id: ADR-0005 | path: docs/decisions/0005-v2-to-v3-explicit-migration-contract.md | status: Accepted | reason: v3-only migration remains explicit.

## Selected Repo Memory

Prior same-repository authority decisions were verified against the live tree.

## Localization

No localization changes.

## Brownfield Conventions

Preserve unrelated worktree changes and use the harness public command surface.

## Required Checks

- /Users/exe-macbook/.local/bin/rtk ./harness.sh next

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/autonomous-run-report.md unless task-local
