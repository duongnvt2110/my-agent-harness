#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/consume_plan_rollup' EXIT

epic_root="$tmp/epics"
task_store="$tmp/tasks.jsonl"
plan="$tmp/current.md"
task_id="consume_plan_rollup"
epic_id="sample_harness_testing_tasks"
story_id="sample_harness_story_alpha"
baseline_repo="$tmp/baseline-repo"
mkdir -p "$baseline_repo"
git -C "$baseline_repo" init -q
git -C "$baseline_repo" config user.email harness@example.invalid
git -C "$baseline_repo" config user.name "Harness Test"
printf 'baseline
' > "$baseline_repo/baseline.txt"
git -C "$baseline_repo" add baseline.txt
git -C "$baseline_repo" commit -qm baseline
baseline_ref="$(git -C "$baseline_repo" rev-parse HEAD)"
mkdir -p "docs/evidence/$task_id"
cat > "docs/evidence/$task_id/baseline-decision.md" <<EOF
# Baseline Decision

task_id: $task_id
created_before_execution: true
repo_root: $baseline_repo
change_tracking: git
git_ref: $baseline_ref
snapshot_path: null
reason: Isolated regression fixture baseline.
EOF

mkdir -p "$epic_root"
cp -R tests/fixtures/sample_harness_testing_tasks "$epic_root/$epic_id"

cat > "$plan" <<EOF
---
task_id: $task_id
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
baseline_ref: $baseline_ref
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
parent_epic_id: $epic_id
parent_story_id: $story_id
epic_path: $epic_root/$epic_id/epic.md
story_registry: $epic_root/$epic_id/stories.jsonl
epic_memory: $epic_root/$epic_id/epic-memory.md
epic_progress: $epic_root/$epic_id/progress.md
integration_contract: $epic_root/$epic_id/integration-contract.md
epic_clarifications: $epic_root/$epic_id/clarifications.md
epic_context_required: true
spec_clarification_required: false
spec_clarification_evidence: docs/evidence/$task_id/spec-clarification.md
work_alignment_required: false
work_alignment_evidence: docs/evidence/$task_id/work-alignment.md
adr_check_required: true
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/$task_id/adr-review.md
context_pack_required: true
context_pack_path: docs/evidence/$task_id/context-pack.md
working_memory_path: docs/evidence/$task_id/working-memory.md
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
    evidence: "docs/evidence/$task_id/plan-check.md"
---
EOF

PLAN_PATH="$plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/consume-plan.sh >/dev/null

python3 - "$task_store" "$task_id" <<'PY'
import json
import pathlib
import sys

store = pathlib.Path(sys.argv[1])
task_id = sys.argv[2]
rows = [json.loads(line) for line in store.read_text().splitlines() if line.strip()]
record = next((row for row in rows if row.get("id") == task_id), None)
if record is None:
    raise SystemExit("Missing consumed task record")
if record.get("epic_id") != "sample_harness_testing_tasks":
    raise SystemExit("Epic linkage missing")
if record.get("story_id") != "sample_harness_story_alpha":
    raise SystemExit("Story linkage missing")
if record.get("status") != "READY":
    raise SystemExit("Consumed task should start READY")
PY

if PLAN_PATH="$plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/story.sh complete "$epic_id" "$story_id" >/dev/null 2>&1; then
  echo "Story completion should fail before linked task is DONE" >&2
  exit 1
fi

python3 - "$task_store" "$task_id" <<'PY'
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

PLAN_PATH="$plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/story.sh complete "$epic_id" "$story_id" >/dev/null
PLAN_PATH="$plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/story.sh complete "$epic_id" sample_harness_story_beta >/dev/null
PLAN_PATH="$plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" ./scripts/epic.sh complete "$epic_id" >/dev/null

grep -q '^- epic_status: DONE$' "$epic_root/$epic_id/progress.md" || {
  echo "Epic progress did not record DONE roll-up" >&2
  exit 1
}

echo "Plan consume and roll-up regression passed."
