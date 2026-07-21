# Context Pack

task_id: harness_enhancement_full
budget: 5000

## Active Task

- task_id: harness_enhancement_full
- title: Implement harness enhancements from review and closure idea
- goal: Stabilize runner timeouts, file-map enforcement, closeout automation, and benchmark/report alignment.

## Selected Context Files

- docs/evidence/harness_enhancement_full/adr-review.md
- docs/evidence/harness_enhancement_full/full-context.md
- docs/evidence/harness_enhancement_full/working-memory.md
- docs/evidence/harness_enhancement_full/work-alignment.md
- docs/evidence/harness_enhancement_full/spec-clarification.md
- docs/epics/sample_harness_testing_tasks/epic.md
- docs/epics/sample_harness_testing_tasks/progress.md
- docs/epics/sample_harness_testing_tasks/stories.jsonl
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

## Repo Mode Summary

Brownfield harness maintenance with existing scripts, reports, and fixtures.

## Repository Intelligence

- The harness uses `.agent-harness/` as the public execution namespace.
- Lifecycle operations are script-driven and plan-gated.
- Benchmark output is stored under `docs/reports/benchmark/`.

## Impact Scan

- Runner portability affects `tests/harness/run_all.sh`.
- Finalization affects `scripts/finalize-task.sh`, story closeout, and epic closeout.
- File-map enforcement affects snapshot and approved-file checks.
- Benchmark output depends on `scripts/benchmark.py` and its shell wrapper.

## Convention Awareness

- Keep changes under the harness namespace and task evidence tree.
- Preserve current shell and Markdown style.
- Prefer explicit regression tests for behavior changes.

## Business Rule Awareness

- Plans must remain gated by the active-plan contract.
- Completed tasks should close their story and epic when no unfinished work remains.
- Snapshot mode must not bypass `my_docs` restrictions.

## Regression Scope

- `/bin/bash` list mode on the harness runner.
- Timeout classification for benchmark and test runner flows.
- Finalizer story/epic closeout behavior.
- Snapshot file-map rejection for unauthorized paths.
- Benchmark suite contract and report generation.

## Verification Scope

- Active plan contract.
- File-map checks.
- Targeted harness regressions.
- Benchmark suite.
- Full verify and finalize.

## Environment State

- Local checkout.
- No external service dependencies.
- Current active plan is this task.

## Human Approval

- Approved by: human
- Approved scope: harness core, docs, and state files

## Parent Epic Summary

- No parent epic.

## Parent Story Summary

- No parent story.

## Epic Memory Summary

- No prior epic memory loaded.

## Integration Contract Summary

- Closeout uses the existing story and epic scripts.
- Verification uses the existing harness gate chain.

## Clarification Summary

- No open clarification blocking the current work.

## Selected ADRs

- id: ADR-0001 | path: docs/decisions/0001-define-scratch-harness-lifecycle-terminology.md | status: Accepted | reason: Harness lifecycle and closeout compatibility
- id: ADR-0002 | path: docs/decisions/0002-remove-harness-skill-selection-contract.md | status: Accepted | reason: Harness lifecycle and closeout compatibility
- id: ADR-0003 | path: docs/decisions/0003-brownfield-agent-ready-execution-harness.md | status: Accepted | reason: Harness lifecycle and closeout compatibility

## Selected Repo Memory

- No additional repo memory selected.

## Localization

- English only.

## Brownfield Conventions

- Prefer the smallest safe diff.
- Keep backwards-compatible harness behavior where possible.
- Add regressions for fixed behavior.

## Required Checks

- plan-check: rtk ./scripts/harness.sh next (timeout: 180)

## Do Not Read

- docs/exec-plans/completed/*
- docs/evidence/*/autonomous-run-report.md unless it belongs to this task
- docs/evidence/*/verification-pass.md unless it belongs to this task
- docs/evidence/*/test-report.md unless it belongs to this task
