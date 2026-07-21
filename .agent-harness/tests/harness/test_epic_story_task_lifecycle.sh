#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

plan="$tmp/current.md"
task_store="$tmp/tasks.jsonl"
task_a="quality_lifecycle_alpha"
task_b="quality_lifecycle_beta"
epic_root="tests/fixtures"
dir="docs/evidence/$task_a"

cat > "$plan" <<'EOF'
---
task_id: quality_lifecycle_alpha
title: "Quality lifecycle alpha"
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
  - harness_docs
approved_files: []
approved_deletions: []
review_required: false
implementation_allowed: true
clarification_status: CLEAR
approved_by: codex
approved_at: "2026-06-27 11:05"
baseline_ref: test-baseline
file_map_approved: true
requires_rollback_plan: false
requires_human_approval: false
environment_mode: local
environment_setup_required: false
environment_run_prefix: ""
acceptance_criteria:
  - lifecycle tasks validate
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
work_alignment_evidence: docs/evidence/quality_lifecycle_alpha/work-alignment.md
spec_clarification_evidence: docs/evidence/quality_lifecycle_alpha/spec-clarification.md
max_context_tokens: 5000
max_memory_items: 12
include_full_adr_text: false
include_full_epic_text: false
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/quality_lifecycle_alpha/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/quality_lifecycle_alpha/context-pack.md
working_memory_path: docs/evidence/quality_lifecycle_alpha/working-memory.md
---
EOF

mkdir -p "$dir"
cat > "$dir/full-context.md" <<'EOF'
# Full Context

Minimal full-context evidence for task lifecycle regression.
EOF

PLAN_PATH="$plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/task.sh add "$task_b" "Lifecycle dependency beta" >/dev/null
PLAN_PATH="$plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/task.sh add "$task_a" "Lifecycle task alpha" --epic sample_harness_testing_tasks --story sample_harness_story_alpha >/dev/null
TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/task.sh depends-on "$task_a" "$task_b" >/dev/null

source_plan="$tmp/source-plan.md"
implementation_plan="$tmp/implementation-plan.md"
cat > "$source_plan" <<'EOF'
# v3 Task Source

Authoritative v3 lifecycle fixture.
EOF
cat > "$implementation_plan" <<'EOF'
# Implementation Plan

Use the current v3 task lifecycle.
EOF
python3 - "$task_store" "$source_plan" "$implementation_plan" <<'PY2'
import json
import pathlib
import sys

store = pathlib.Path(sys.argv[1])
source_plan = str(pathlib.Path(sys.argv[2]).resolve())
implementation_plan = str(pathlib.Path(sys.argv[3]).resolve())
rows = [json.loads(line) for line in store.read_text().splitlines() if line.strip()]
for row in rows:
    row["source_plan_path"] = source_plan
    row["implementation_plan_path"] = implementation_plan
store.write_text("\n".join(json.dumps(row, separators=(",", ":")) for row in rows) + "\n")
PY2

if PLAN_PATH="$plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/task.sh validate "$task_a" >/dev/null 2>&1; then
  echo "Validation should fail while dependency is still READY" >&2
  exit 1
fi

python3 - "$task_store" "$task_b" <<'PY'
import json
import pathlib
import sys

store = pathlib.Path(sys.argv[1])
task_id = sys.argv[2]
rows = [json.loads(line) for line in store.read_text().splitlines() if line.strip()]
for row in rows:
    if row.get("id") == task_id:
        row["status"] = "DONE"
store.write_text("\n".join(json.dumps(row, separators=(",", ":")) for row in rows) + "\n")
PY

PLAN_PATH="$plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/task.sh validate "$task_a" >/dev/null

echo "Task lifecycle regression passed."
