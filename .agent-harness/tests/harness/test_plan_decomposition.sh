#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

bad_plan="$tmp/bad-current.md"
good_plan="$tmp/good-current.md"

cat > "$bad_plan" <<'EOF'
---
task_id: plan_decomposition_bad
title: "Plan decomposition bad"
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
    evidence: "docs/evidence/plan_decomposition_bad/plan-check.md"
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
work_alignment_evidence: docs/evidence/plan_decomposition_bad/work-alignment.md
spec_clarification_evidence: docs/evidence/plan_decomposition_bad/spec-clarification.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/plan_decomposition_bad/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/plan_decomposition_bad/context-pack.md
working_memory_path: docs/evidence/plan_decomposition_bad/working-memory.md
---

# Execution Plan: Plan decomposition bad

## Goal

Describe the exact outcome.
EOF

cat > "$good_plan" <<'EOF'
---
task_id: plan_decomposition_good
title: "Plan decomposition good"
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
    evidence: "docs/evidence/plan_decomposition_good/plan-check.md"
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
work_alignment_evidence: docs/evidence/plan_decomposition_good/work-alignment.md
spec_clarification_evidence: docs/evidence/plan_decomposition_good/spec-clarification.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/plan_decomposition_good/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/plan_decomposition_good/context-pack.md
working_memory_path: docs/evidence/plan_decomposition_good/working-memory.md
---

# Execution Plan: Plan decomposition good

## Goal

Add a hard approval gate that rejects plans missing feature intake and
epic/story/task decomposition.

## Feature Intake

### Problem

The plan must explicitly state the feature problem.

### Scope

The scope must be bounded and specific.

### Out of Scope

The out-of-scope items must be explicit.

### Success Criteria

The plan must say how completion is judged.

### Dependencies

Any known dependencies must be stated.

## Epic / Story / Task Breakdown

### Epic 1: Validate plan intake structure

Dependencies:

- Structural plan contract

Acceptance Criteria:

- Missing intake headings fail approval
- Empty intake content fails approval

Stories:

- Intake headings exist

Tasks:

- Implement the plan decomposition validator

### Epic 2: Wire the gate into approval

Dependencies:

- Decomposition checker

Acceptance Criteria:

- Approval invokes the new validator
- Invalid plans stop before execute

Stories:

- Approval runs the validator

Tasks:

- Update plan approval wiring

### Epic 3: Update the template and test coverage

Dependencies:

- Plan template

Acceptance Criteria:

- The template shows the required sections
- A regression test covers the gate

Stories:

- Template includes the required sections

Tasks:

- Update the template and add a regression test
EOF

set +e
PLAN_PATH="$bad_plan" ./scripts/check-plan-decomposition.sh >/dev/null
bad_status=$?
set -e
[ "$bad_status" -ne 0 ] || {
  echo "Expected missing-section plan to fail"
  exit 1
}

PLAN_PATH="$good_plan" ./scripts/check-plan-decomposition.sh >/dev/null

echo "Plan decomposition regression passed."
