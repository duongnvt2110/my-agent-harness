#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/repository_intelligence_temp' EXIT

task_id="repository_intelligence_temp"
plan="$tmp/current.md"
task_store="$tmp/tasks.jsonl"
dir="docs/evidence/$task_id"

cat > "$plan" <<'EOF'
---
task_id: repository_intelligence_temp
title: "Repository intelligence temp"
status: APPROVED
lifecycle_phase: EXECUTE
lane: tiny
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
verification_mode: required_checks
testing_required: true
testing_skip_reason: ""
approved_scopes:
  - harness_core
  - harness_docs
  - app_tests
approved_files: []
approved_deletions: []
review_required: false
implementation_allowed: true
clarification_status: CLEAR
approved_by: codex
approved_at: "2026-06-26 00:00"
baseline_ref: test-baseline
file_map_approved: true
requires_rollback_plan: false
requires_human_approval: false
environment_mode: local
environment_setup_required: false
environment_run_prefix: ""
acceptance_criteria:
  - repository intelligence scaffolding is generated
required_checks: []
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
work_alignment_evidence: docs/evidence/repository_intelligence_temp/work-alignment.md
spec_clarification_evidence: docs/evidence/repository_intelligence_temp/spec-clarification.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/repository_intelligence_temp/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/repository_intelligence_temp/context-pack.md
working_memory_path: docs/evidence/repository_intelligence_temp/working-memory.md
---
EOF

mkdir -p "$dir"
cat > "$dir/full-context.md" <<'EOF'
# Full Context

Minimal full-context evidence for repository intelligence regression.
EOF

PLAN_PATH="$plan" ./scripts/context.sh index
PLAN_PATH="$plan" ./scripts/context.sh localize --task "$task_id"
PLAN_PATH="$plan" ./scripts/context.sh conventions --task "$task_id"
PLAN_PATH="$plan" ./scripts/context.sh pack --task "$task_id" --budget 5000

[ -f docs/context/repository-intelligence/README.md ] || {
  echo "Missing repository intelligence README" >&2
  exit 1
}
[ -f docs/context/repository-intelligence/repo-profile.yml ] || {
  echo "Missing repository intelligence repo profile" >&2
  exit 1
}
[ -f docs/context/repository-intelligence/knowledge-index.json ] || {
  echo "Missing repository intelligence knowledge index" >&2
  exit 1
}

grep -q '^repo_mode: brownfield$' "docs/evidence/$task_id/repo-knowledge-selection.md" || {
  echo "Repo knowledge selection did not record brownfield mode" >&2
  exit 1
}
grep -q '^## Repo Mode Summary$' "docs/evidence/$task_id/context-pack.md" || {
  echo "Context pack is missing repo mode summary" >&2
  exit 1
}
grep -q '^## Repository Intelligence$' "docs/evidence/$task_id/context-pack.md" || {
  echo "Context pack is missing repository intelligence section" >&2
  exit 1
}

TASK_STORE="$task_store" PLAN_PATH="$plan" ./scripts/consume-plan.sh >/dev/null
TASK_STORE="$task_store" PLAN_PATH="$plan" ./scripts/check-work-alignment.sh >/dev/null
PLAN_PATH="$plan" ./scripts/check-context-pack.sh >/dev/null

echo "Repository intelligence regression passed."
