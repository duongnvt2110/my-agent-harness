#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
tmp="$(cd "$tmp" && pwd -P)"
trap 'rm -rf "$tmp"' EXIT

harness_root="$tmp/harness"
mkdir -p "$harness_root/scripts" \
  "$harness_root/docs/exec-plans/active" \
  "$harness_root/docs/exec-plans/completed" \
  "$harness_root/docs/evidence/quality_lifecycle_alpha" \
  "$harness_root/docs/epics/sample_harness_testing_tasks" \
  "$harness_root/docs/tasks"

for script in harness-lib.sh finalize-task.sh story.sh epic.sh task.sh update-epic-progress.sh check-rollup-projection.sh list-baseline-changes.sh create-baseline-snapshot.sh; do
  cp "scripts/$script" "$harness_root/scripts/$script"
done

cat > "$harness_root/scripts/verify.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

mkdir -p "$(evidence_dir)"
cat > "$(evidence_dir)/verification-pass.md" <<'EOF'
# Verification Pass

result: pass
EOF
cat > "$(evidence_dir)/test-report.md" <<'EOF'
# Test Report

result: pass
EOF

set_fm_value "$PLAN_PATH" "status" "VERIFIED"
set_fm_value "$PLAN_PATH" "lifecycle_phase" "FINALIZE"
echo "Harness verification passed."
SH
chmod +x "$harness_root/scripts/verify.sh"

cat > "$harness_root/scripts/consume-plan.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
echo "Consumed active plan into task store: $(basename "$(dirname "$(dirname "${PLAN_PATH:-}")")")"
SH
chmod +x "$harness_root/scripts/consume-plan.sh"

cat > "$harness_root/scripts/generate-autonomous-run-report.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

mkdir -p "$(evidence_dir)"
cat > "$(evidence_dir)/autonomous-run-report.md" <<'EOF'
# Autonomous Run Report

result: pass
EOF
SH
chmod +x "$harness_root/scripts/generate-autonomous-run-report.sh"

plan="$harness_root/docs/exec-plans/active/current.md"
task_store="$harness_root/docs/tasks/tasks.jsonl"
epic_root="$harness_root/docs/epics"

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
  - harness_core
approved_files: []
approved_deletions: []
review_required: false
implementation_allowed: true
clarification_status: CLEAR
approved_by: codex
approved_at: "2026-07-02 14:02"
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
parent_epic_id: sample_harness_testing_tasks
parent_story_id: sample_harness_story_alpha
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
adr_check_required: false
adr_index: docs/decisions/adr-index.json
adr_review_evidence: docs/evidence/quality_lifecycle_alpha/adr-review.md
context_pack_required: false
context_pack_path: docs/evidence/quality_lifecycle_alpha/context-pack.md
working_memory_path: docs/evidence/quality_lifecycle_alpha/working-memory.md
---
EOF

mkdir -p "$harness_root/docs/evidence/quality_lifecycle_alpha"
cat > "$harness_root/docs/evidence/quality_lifecycle_alpha/work-alignment.md" <<'EOF'
# Work Alignment

Aligned.
EOF
cat > "$harness_root/docs/evidence/quality_lifecycle_alpha/spec-clarification.md" <<'EOF'
# Spec Clarification

No clarifications needed.
EOF
cat > "$harness_root/docs/evidence/quality_lifecycle_alpha/adr-review.md" <<'EOF'
# ADR Review

No ADR issues.
EOF
cat > "$harness_root/docs/evidence/quality_lifecycle_alpha/context-pack.md" <<'EOF'
# Context Pack

Minimal context.
EOF
cat > "$harness_root/docs/evidence/quality_lifecycle_alpha/working-memory.md" <<'EOF'
# Working Memory

Minimal working memory.
EOF

cat > "$task_store" <<'EOF'
{"id":"quality_lifecycle_alpha","epic_id":"sample_harness_testing_tasks","story_id":"sample_harness_story_alpha","title":"Lifecycle task alpha","status":"READY","depends_on":[],"priority":"normal","lane":"tiny"}
EOF

cat > "$epic_root/sample_harness_testing_tasks/stories.jsonl" <<'EOF'
{"id":"sample_harness_story_alpha","title":"Lifecycle story alpha","status":"READY","depends_on":[],"acceptance":["all tasks complete"],"notes":""}
EOF

cat > "$epic_root/sample_harness_testing_tasks/progress.md" <<'EOF'
# Epic Progress

## Status

DRAFT

## Completed Stories

## Active Story

## Blocked Stories

## Next Candidate Tasks
EOF

cat > "$epic_root/sample_harness_testing_tasks/epic-memory.md" <<'EOF'
# Epic Memory

Minimal memory.
EOF
cat > "$epic_root/sample_harness_testing_tasks/clarifications.md" <<'EOF'
# Clarifications

None.
EOF
cat > "$epic_root/sample_harness_testing_tasks/integration-contract.md" <<'EOF'
# Integration Contract

None.
EOF

snapshot="$harness_root/docs/evidence/quality_lifecycle_alpha/baseline-snapshot.json"
PLAN_PATH="$plan" "$harness_root/scripts/create-baseline-snapshot.sh" \
  --task quality_lifecycle_alpha --root "$harness_root" --snapshot "$snapshot" >/dev/null
cat > "$harness_root/docs/evidence/quality_lifecycle_alpha/baseline-decision.md" <<EOF
# Baseline Decision

task_id: quality_lifecycle_alpha
change_tracking: snapshot
repo_root: $harness_root
snapshot_path: $snapshot
EOF

real_rollup_check="$harness_root/scripts/check-rollup-projection.sh.real"
mv "$harness_root/scripts/check-rollup-projection.sh" "$real_rollup_check"
cat > "$harness_root/scripts/check-rollup-projection.sh" <<'SH'
#!/usr/bin/env bash
echo 'simulated rollup failure' >&2
exit 1
SH
chmod +x "$harness_root/scripts/check-rollup-projection.sh"

if PLAN_PATH="$plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" "$harness_root/scripts/finalize-task.sh" >/tmp/finalize-task-failure.out 2>&1; then
  echo "finalization unexpectedly succeeded with a failed rollup" >&2
  exit 1
fi
grep -q '^status: VERIFIED$' "$plan"
grep -q '^lifecycle_phase: FINALIZE$' "$plan"
[ ! -e "$harness_root/docs/exec-plans/completed/"*quality_lifecycle_alpha.md ] 2>/dev/null || {
  echo "failed finalization moved the active plan" >&2
  exit 1
}

mv "$real_rollup_check" "$harness_root/scripts/check-rollup-projection.sh"
PLAN_PATH="$plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" "$harness_root/scripts/finalize-task.sh" >/tmp/finalize-task.out 2>&1

python3 - "$task_store" "$epic_root/sample_harness_testing_tasks/stories.jsonl" "$epic_root/sample_harness_testing_tasks/progress.md" <<'PY'
import json
import pathlib
import sys

task_store = pathlib.Path(sys.argv[1])
stories_file = pathlib.Path(sys.argv[2])
progress_file = pathlib.Path(sys.argv[3])

tasks = [json.loads(line) for line in task_store.read_text().splitlines() if line.strip()]
task = next(row for row in tasks if row.get("id") == "quality_lifecycle_alpha")
if task.get("status") != "DONE":
    raise SystemExit(f"task status not DONE: {task.get('status')}")

stories = [json.loads(line) for line in stories_file.read_text().splitlines() if line.strip()]
story = next(row for row in stories if row.get("id") == "sample_harness_story_alpha")
if story.get("status") != "DONE":
    raise SystemExit(f"story status not DONE: {story.get('status')}")

progress = progress_file.read_text()
if "- epic_status: DONE" not in progress:
    raise SystemExit("epic progress did not record DONE status")
PY

completed_plan="$(find "$harness_root/docs/exec-plans/completed" -type f -name '*_quality_lifecycle_alpha.md' | head -n 1)"
[ -n "$completed_plan" ] || {
  cat /tmp/finalize-task.out >&2
  echo "Missing completed plan output" >&2
  exit 1
}

grep -q 'Task finalized:' /tmp/finalize-task.out

PLAN_PATH="$completed_plan" TASK_STORE="$task_store" EPIC_ROOT="$epic_root" \
  "$harness_root/scripts/update-epic-progress.sh" >/dev/null
if [ "$(grep -Fc -- '- task_id: quality_lifecycle_alpha' "$epic_root/sample_harness_testing_tasks/progress.md")" -ne 1 ]; then
  echo "epic progress updater duplicated a task entry" >&2
  exit 1
fi

python3 - "$harness_root/docs/evidence/quality_lifecycle_alpha/finalization-journal.json" <<'PY'
import json
import pathlib
import sys

journal = json.loads(pathlib.Path(sys.argv[1]).read_text())
if journal.get("status") != "FINALIZED":
    raise SystemExit(f"journal status is not FINALIZED: {journal.get('status')}")
expected = ["verify", "review", "mark_terminal", "task_projection", "reports", "move_plan"]
steps = journal.get("steps", [])
if [step.get("name") for step in steps] != expected:
    raise SystemExit("journal step order changed")
if any(step.get("status") != "DONE" for step in steps):
    raise SystemExit("journal contains incomplete steps")
mark = next(step for step in steps if step["name"] == "mark_terminal")
if not mark.get("expected_before_hash") or not mark.get("expected_after_hash"):
    raise SystemExit("terminal step is missing before/after hashes")
PY

echo "Finalize epic progress regression passed."
