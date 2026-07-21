# Context Pack

task_id: review_agent_harness_research_toc
budget: 5000

## Active Task

Align the research review TOC with the v3 repository-local governance scope.

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

Brownfield repository-local harness; current public dispatcher reports the
legacy v2 audit-only path unless explicit v3 metadata is selected.

## Repository Intelligence

The selected repository-intelligence files describe the harness boundaries,
authority model, lifecycle, and verification conventions.

## Impact Scan

Docs-only scope; no runtime behavior is changed.

## Convention Awareness

Use v3 terminology and keep `my_docs` as the human-owned review artifact.

## Business Rule Awareness

Human requirements are authoritative; the harness owns deterministic
verification and completion.

## Regression Scope

Confirm the TOC has no active sections for sandboxing, network restriction,
signed releases, or agent-specific adapters.

## Verification Scope

Run the harness verification gates and inspect the resulting TOC headings.

## Environment State

Local filesystem; no external services required.

## Human Approval

Human approved the v3-only repository-local governance boundary.

## Parent Epic Summary

No parent epic.

## Parent Story Summary

No parent story.

## Epic Memory Summary

No epic memory.

## Integration Contract Summary

No integration contract.

## Clarification Summary

The harness does not duplicate coding-agent capabilities.

## Selected ADRs

- id: ADR-0004 | path: docs/decisions/0004-agent-harness-vnext-authority-model.md | status: Accepted | reason: v3 state authority defines the review boundary.
- id: ADR-0005 | path: docs/decisions/0005-v2-to-v3-explicit-migration-contract.md | status: Accepted | reason: explicit migration supports the v3-only product decision.

## Selected Repo Memory

Prior same-repository authority decisions were used as hypotheses and verified
against the live checkout.

## Localization

No localization changes.

## Brownfield Conventions

Preserve unrelated worktree changes and use the harness public command surface.

## Required Checks

- rtk .agent-harness/harness.sh verify
- rtk git diff --check

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/autonomous-run-report.md unless task-local

