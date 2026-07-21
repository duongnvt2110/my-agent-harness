# 0002: Remove Harness Skill-Selection Contract

Date: 2026-06-04

## Status

Accepted

## Context

The harness previously treated skill selection as part of the active plan
contract and expected repo-local skill files under `.agents/skills/`.
That made the harness responsible for bootstrapping and validating skills that
should remain external to the repository.

The repo already has reusable global Codex skills available outside the
workspace. The harness should not create its own skill scaffolding or require
repo-local skill definitions in order to run.

## Decision

Remove the live skill-selection contract from the harness.

- Do not require `require_skill_selection`, `selected_skills`, or
  `skill_selection_evidence` in active plans.
- Do not validate repo-local `.agents/skills`.
- Do not validate `~/.codex/skills`.
- Do not create skill scaffolding in the repository as part of the harness
  workflow.
- Treat skill usage as external/user-managed context rather than a repo-owned
  harness contract.

## Consequences

- Active plans and templates should no longer include skill-selection fields.
- Harness packet output should no longer advertise selected skills.
- Skill-gate scripts and repo-local skill helpers can be removed once no other
  harness path depends on them.
- Historical evidence that mentions the old skill contract may remain in
  completed plans as audit trail, but it is no longer part of the live
  contract.
