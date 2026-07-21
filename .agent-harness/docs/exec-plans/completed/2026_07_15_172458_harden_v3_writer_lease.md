---
task_id: harden_v3_writer_lease
title: "Harden v3 writer lease ownership and fencing"
status: COMPLETED
lifecycle_phase: COMPLETED
lane: tiny
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 2
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: human
approved_at: "2026-07-15 17:22"
baseline_ref: null
file_map_approved: true
review_required: false
evidence_required: true
requires_rollback_plan: false
requires_human_approval: false
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
approved_scopes: 
  - harness_core
  - app_tests
approved_files: 
  - scripts/writer-lease.sh
  - tests/harness/test_writer_lease.sh
  - docs/context/repository-intelligence/repo-profile.yml
  - docs/tasks/tasks.jsonl
approved_deletions: []
environment_mode: local
environment_setup_required: false
environment_run_prefix: null
environment_compose_file: null
environment_service: null
environment_reason: null
verification_mode: required_checks
testing_required: true
testing_skip_reason: null
parent_epic_id: null
parent_story_id: null
epic_path: null
story_registry: null
epic_memory: null
epic_progress: null
integration_contract: null
epic_clarifications: null
epic_context_required: false
spec_clarification_required: false
spec_clarification_evidence: docs/evidence/harden_v3_writer_lease/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/harden_v3_writer_lease/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/harden_v3_writer_lease/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/harden_v3_writer_lease/context-pack.md
working_memory_path: docs/evidence/harden_v3_writer_lease/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
source_plan_path: null
implementation_plan_path: docs/tasks/harden_v3_writer_lease/implementation-plan.md
acceptance_criteria: 
  - Writer leases bind one active writer to an exact run, checkout, and session identity.
  - Lease validation uses fencing tokens, monotonic duration, persisted UTC expiry, and rejects clock rollback or reboot-invalid leases.
  - Expired leases require explicit recovery and stale writers cannot heartbeat, release, or validate after replacement.
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: writer-lease-test
    type: automated
    command: rtk bash tests/harness/test_writer_lease.sh
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: docs/evidence/harden_v3_writer_lease/writer-lease-test.md
completed_at: "2026-07-15 17:24"
---

# Active Task: Harden v3 writer lease ownership and fencing

## Goal

Harden v3 writer lease ownership and fencing

## Parent References

- epic_id: `none`
- story_id: `none`
- source_plan_path: `none`
- implementation_plan_path: `docs/tasks/harden_v3_writer_lease/implementation-plan.md`

## Scope

### Approved Scopes

- harness_core
- app_tests

### Approved Files

- scripts/writer-lease.sh
- tests/harness/test_writer_lease.sh

## Acceptance Criteria

- Writer leases bind one active writer to an exact run, checkout, and session identity.
- Lease validation uses fencing tokens, monotonic duration, persisted UTC expiry, and rejects clock rollback or reboot-invalid leases.
- Expired leases require explicit recovery and stale writers cannot heartbeat, release, or validate after replacement.

## Required Checks

- `rtk bash tests/harness/test_writer_lease.sh`

## Out of Scope

- Do not place the full epic/story/task tree in this active plan.
- Do not modify files outside approved scopes/files.

## Verification

Run the required checks listed in frontmatter, then run `rtk ./scripts/verify.sh` when implementation is complete.
