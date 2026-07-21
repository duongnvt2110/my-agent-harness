# 0003: Brownfield Agent-Ready Execution Harness

Date: 2026-06-17

## Status

Accepted

## Context

The harness needs to support brownfield implementation work where the agent
must read selected repo context, follow controlled ADRs, track discussions,
and keep execution bounded by the active plan and file map.

## Decision

Adopt a brownfield execution harness with these durable layers:

- a repo memory layer under `docs/context/`
- ADR selection and review against `docs/decisions/adr-index.json`
- task-local discussion tracking and memory promotion
- context packs for selected brownfield task context
- automation-only verification
- structured remediation before patching
- script-owned finalization

## Consequences

- Brownfield tasks should gather context before implementation.
- Durable decisions should be captured as ADRs instead of passive notes.
- Task-local evidence remains under `docs/evidence/<task_id>/`.
- The harness can reason about context without dumping the whole repository.
