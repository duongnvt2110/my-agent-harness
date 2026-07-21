#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

bad_plan="$tmp/bad-current.md"
good_plan="$tmp/good-current.md"

cat > "$bad_plan" <<'EOF'
---
task_id: plan_decomposition_semantic_bad
title: "Plan decomposition semantic bad"
status: DRAFT
lifecycle_phase: PLAN
lane: tiny
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
approved_scopes:
  - harness_docs
approved_files: []
approved_deletions: []
verification_mode: required_checks
testing_required: true
testing_skip_reason: ""
implementation_allowed: false
clarification_status: CLEAR
approved_by: null
approved_at: null
baseline_ref: test-baseline
file_map_approved: false
requires_rollback_plan: false
requires_human_approval: false
environment_mode: local
environment_setup_required: false
environment_run_prefix: ""
acceptance_criteria:
  - plan decomposition gate exists
required_checks:
  - id: plan-check
    type: automated
    command: "rtk ./scripts/harness.sh next"
    blocking: true
    timeout_seconds: 180
    evidence: "docs/evidence/plan_decomposition_semantic_bad/plan-check.md"
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
epic_context_required: false
spec_clarification_required: false
parent_epic_id: null
parent_story_id: null
epic_path: null
story_registry: null
epic_memory: null
epic_progress: null
epic_clarifications: null
work_alignment_evidence: docs/evidence/plan_decomposition_semantic_bad/work-alignment.md
spec_clarification_evidence: docs/evidence/plan_decomposition_semantic_bad/spec-clarification.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/plan_decomposition_semantic_bad/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/plan_decomposition_semantic_bad/context-pack.md
working_memory_path: docs/evidence/plan_decomposition_semantic_bad/working-memory.md
---

# Execution Plan: Plan decomposition semantic bad

## Goal

Describe the exact outcome.

## Feature Intake

### Problem

Describe the user or system problem the task solves.

### Scope

Describe what is in scope for this task.

### Out of Scope

Describe what is explicitly out of scope.

### Success Criteria

List the outcomes that prove the task is complete.

### Dependencies

Describe any relevant dependencies or constraints.

## Epic / Story / Task Breakdown

### Epic 1: <name>

Stories:

- <story>

Tasks:

- <task>
EOF

cat > "$good_plan" <<'EOF'
---
task_id: plan_decomposition_semantic_good
title: "Plan decomposition semantic good"
status: DRAFT
lifecycle_phase: PLAN
lane: tiny
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
approved_scopes:
  - harness_docs
approved_files: []
approved_deletions: []
verification_mode: required_checks
testing_required: true
testing_skip_reason: ""
implementation_allowed: false
clarification_status: CLEAR
approved_by: null
approved_at: null
baseline_ref: test-baseline
file_map_approved: false
requires_rollback_plan: false
requires_human_approval: false
environment_mode: local
environment_setup_required: false
environment_run_prefix: ""
acceptance_criteria:
  - plan decomposition gate exists
required_checks:
  - id: plan-check
    type: automated
    command: "rtk ./scripts/harness.sh next"
    blocking: true
    timeout_seconds: 180
    evidence: "docs/evidence/plan_decomposition_semantic_good/plan-check.md"
decision_policy_allow_safe_revert: true
decision_policy_allow_test_fix: true
decision_policy_allow_source_fix: true
decision_policy_allow_scope_expansion: false
decision_policy_allow_dependency_change: false
decision_policy_allow_environment_change: false
decision_policy_allow_test_skip: false
decision_policy_allow_timeout_increase: false
epic_context_required: false
spec_clarification_required: false
parent_epic_id: null
parent_story_id: null
epic_path: null
story_registry: null
epic_memory: null
epic_progress: null
epic_clarifications: null
work_alignment_evidence: docs/evidence/plan_decomposition_semantic_good/work-alignment.md
spec_clarification_evidence: docs/evidence/plan_decomposition_semantic_good/spec-clarification.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/plan_decomposition_semantic_good/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/plan_decomposition_semantic_good/context-pack.md
working_memory_path: docs/evidence/plan_decomposition_semantic_good/working-memory.md
---

# Execution Plan: Plan decomposition semantic good

## Goal

Add semantic validation to the plan decomposition gate so it rejects placeholder
content, weak intake, and weak decomposition structure.

## Feature Intake

### Problem

The current structural gate can accept placeholder content.

### Scope

Strengthen the approval gate with semantic checks.

### Out of Scope

Do not auto-generate plans, bypass the semantic validator, or broaden the
approval integration beyond the plan decomposition gate and regression test
coverage.

### Success Criteria

- Placeholder plans fail.
- Concrete plans pass.

### Dependencies

- Structural decomposition gate
- Approval flow

## Epic / Story / Task Breakdown

### Epic 1: Semantic validation rules

Dependencies:

- Structural plan decomposition gate

Acceptance Criteria:

- Placeholder detection rejects weak plans
- Coverage checks reject orphan requirements

Stories:

- Placeholder detection
- Coverage checks

Tasks:

- implement semantic plan decomposition checks
- add clear failure messages

### Epic 2: Approval integration

Dependencies:

- Validation scripts

Acceptance Criteria:

- Approval runs the semantic validator
- The script interface exposes the checker

Stories:

- Approval runs the semantic validator

Tasks:

- update approval wiring

### Epic 3: Regression coverage

Dependencies:

- Semantic validator

Acceptance Criteria:

- Negative case fails
- Positive case passes

Stories:

- Negative case fails
- Positive case passes

Tasks:

- add semantic regression test
EOF

set +e
PLAN_PATH="$bad_plan" ./scripts/check-plan-decomposition-semantic.sh >/dev/null
bad_status=$?
set -e
[ "$bad_status" -ne 0 ] || {
  echo "Expected placeholder plan to fail"
  exit 1
}

PLAN_PATH="$good_plan" ./scripts/check-plan-decomposition-semantic.sh >/dev/null

echo "Plan decomposition semantic regression passed."
