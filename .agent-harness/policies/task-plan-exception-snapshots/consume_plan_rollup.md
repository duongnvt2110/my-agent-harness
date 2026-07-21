---
task_id: consume_plan_rollup
title: "Consume plan rollup"
status: APPROVED
lifecycle_phase: EXECUTE
lane: tiny
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
change_type: harness_improvement
implementation_target: scratch_harness
workflow_version: 1
implementation_allowed: true
clarification_status: CLEAR
blocking_questions: []
approved_by: codex
approved_at: "2026-06-26 00:00"
baseline_ref: ed416bc84d9ffe998d140243772ecc6e120186c1
file_map_approved: true
review_required: false
evidence_required: true
requires_rollback_plan: false
requires_human_approval: false
approved_scopes:
  - harness_core
  - harness_docs
  - app_tests
approved_files: []
approved_deletions: []
environment_mode: local
environment_setup_required: false
environment_run_prefix: ""
verification_mode: required_checks
testing_required: true
testing_skip_reason: ""
parent_epic_id: sample_harness_testing_tasks
parent_story_id: sample_harness_story_alpha
epic_path: /var/folders/t7/snp9w8v11sx7fqks93ygw8nr0000gq/T/tmp.sOQ0rUcr/epics/sample_harness_testing_tasks/epic.md
story_registry: /var/folders/t7/snp9w8v11sx7fqks93ygw8nr0000gq/T/tmp.sOQ0rUcr/epics/sample_harness_testing_tasks/stories.jsonl
epic_memory: /var/folders/t7/snp9w8v11sx7fqks93ygw8nr0000gq/T/tmp.sOQ0rUcr/epics/sample_harness_testing_tasks/epic-memory.md
epic_progress: /var/folders/t7/snp9w8v11sx7fqks93ygw8nr0000gq/T/tmp.sOQ0rUcr/epics/sample_harness_testing_tasks/progress.md
integration_contract: /var/folders/t7/snp9w8v11sx7fqks93ygw8nr0000gq/T/tmp.sOQ0rUcr/epics/sample_harness_testing_tasks/integration-contract.md
epic_clarifications: /var/folders/t7/snp9w8v11sx7fqks93ygw8nr0000gq/T/tmp.sOQ0rUcr/epics/sample_harness_testing_tasks/clarifications.md
epic_context_required: true
spec_clarification_required: false
spec_clarification_evidence: docs/evidence/consume_plan_rollup/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/consume_plan_rollup/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/consume_plan_rollup/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/consume_plan_rollup/context-pack.md
working_memory_path: docs/evidence/consume_plan_rollup/working-memory.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
acceptance_criteria:
  - consume plan syncs linkage
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
required_checks:
  - id: plan-check
    type: automated
    command: "rtk ./scripts/harness.sh next"
    blocking: true
    timeout_seconds: 180
    covers:
      - AC-001
    evidence: "docs/evidence/consume_plan_rollup/plan-check.md"
---
