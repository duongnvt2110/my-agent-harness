#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

dir="$(evidence_dir)"
file="$dir/work-alignment.md"
task_id="$(fm_value "$PLAN_PATH" "task_id")"
epic_id="$(fm_value "$PLAN_PATH" "parent_epic_id")"
story_id="$(fm_value "$PLAN_PATH" "parent_story_id")"
story_registry="$(fm_value "$PLAN_PATH" "story_registry")"
context_pack="$dir/context-pack.md"
full_context="$(full_context_file)"
task_store="${TASK_STORE:-docs/tasks/tasks.jsonl}"
repo_mode="$(fm_value "$PLAN_PATH" "repo_mode")"
task_change_type="$(fm_value "$PLAN_PATH" "task_change_type")"
task_touches_existing_behavior="$(fm_value "$PLAN_PATH" "task_touches_existing_behavior")"
task_backward_compatibility_required="$(fm_value "$PLAN_PATH" "task_backward_compatibility_required")"

[ -f "$context_pack" ] || fail "Missing context pack evidence: $context_pack"
[ -f "$full_context" ] || fail "Missing full context evidence: $full_context"
[ -f "$task_store" ] || fail "Missing task store: $task_store"
[ "$(fm_list_count "$PLAN_PATH" "approved_scopes")" -gt 0 ] || fail "approved_scopes must contain at least one entry"

python3 - "$PLAN_PATH" "$task_store" "$context_pack" "$full_context" <<'PY'
import json
import pathlib
import re
import sys

def fm_value(content, key):
    in_fm = False
    for line in content.splitlines():
        if line.strip() == "---":
            if not in_fm:
                in_fm = True
                continue
            break
        if not in_fm:
            continue
        if line.startswith(f"{key}:"):
            return line.split(":", 1)[1].strip().strip('"').strip("'")
    return ""

plan = pathlib.Path(sys.argv[1]).read_text()
task_store = pathlib.Path(sys.argv[2])
context_pack = pathlib.Path(sys.argv[3]).read_text()
full_context_path = pathlib.Path(sys.argv[4])

task_id = fm_value(plan, "task_id")
epic_id = fm_value(plan, "parent_epic_id")
story_id = fm_value(plan, "parent_story_id")
story_registry = fm_value(plan, "story_registry")
lifecycle_phase = fm_value(plan, "lifecycle_phase")
repo_mode = fm_value(plan, "repo_mode")
task_change_type = fm_value(plan, "task_change_type")
task_touches_existing_behavior = fm_value(plan, "task_touches_existing_behavior")
task_backward_compatibility_required = fm_value(plan, "task_backward_compatibility_required")

records = []
for line in task_store.read_text().splitlines():
    if line.strip():
        records.append(json.loads(line))

task_record = next((row for row in records if row.get("id") == task_id), None)
if not task_record:
    raise SystemExit(f"task_record missing for {task_id}")

if task_record.get("epic_id", "") != ("" if epic_id == "null" else epic_id):
    raise SystemExit(f"task epic mismatch for {task_id}")
if task_record.get("story_id", "") != ("" if story_id == "null" else story_id):
    raise SystemExit(f"task story mismatch for {task_id}")
if not task_record.get("title"):
    raise SystemExit(f"task title missing for {task_id}")
if task_record.get("repo_mode", "") != ("" if repo_mode == "null" else repo_mode):
    raise SystemExit(f"task repo_mode mismatch for {task_id}")
if task_record.get("task_change_type", "") != ("" if task_change_type == "null" else task_change_type):
    raise SystemExit(f"task_change_type mismatch for {task_id}")
if str(task_record.get("task_touches_existing_behavior", "")) != ("" if task_touches_existing_behavior == "null" else task_touches_existing_behavior):
    raise SystemExit(f"task_touches_existing_behavior mismatch for {task_id}")
if str(task_record.get("task_backward_compatibility_required", "")) != ("" if task_backward_compatibility_required == "null" else task_backward_compatibility_required):
    raise SystemExit(f"task_backward_compatibility_required mismatch for {task_id}")

for dep in task_record.get("depends_on", []):
    dep_record = next((row for row in records if row.get("id") == dep), None)
    if dep_record is None:
        raise SystemExit(f"Unknown dependency task id: {dep}")
    if dep_record.get("status") != "DONE":
        raise SystemExit(f"Dependency not done: {dep}")

if epic_id not in {"", "null"}:
    if not story_id or story_id == "null":
        raise SystemExit("parent_story_id required when parent_epic_id is set")
    story_registry_path = pathlib.Path(story_registry)
    if not story_registry_path.exists():
        raise SystemExit(f"Missing story registry: {story_registry}")
    story_rows = [json.loads(line) for line in story_registry_path.read_text().splitlines() if line.strip()]
    story_record = next((row for row in story_rows if row.get("id") == story_id), None)
    if not story_record:
        raise SystemExit(f"Story not found in registry: {story_id}")
    if not story_record.get("acceptance"):
        raise SystemExit(f"Story acceptance empty: {story_id}")
    if story_record.get("status") not in {"READY", "ACTIVE", "DONE", "BLOCKED"}:
        raise SystemExit(f"Invalid story status: {story_record.get('status')}")
    if story_record.get("status") == "ACTIVE" and lifecycle_phase != "EXECUTE":
        raise SystemExit("ACTIVE story status is only allowed during EXECUTE")

    deps = story_record.get("depends_on", [])
    if not isinstance(deps, list):
        raise SystemExit(f"Story dependencies malformed: {story_id}")
    for dep in deps:
        dep_story = next((row for row in story_rows if row.get("id") == dep), None)
        if dep_story is None:
            raise SystemExit(f"Unknown dependency story id: {dep}")
        if dep_story.get("status") != "DONE":
            raise SystemExit(f"Story dependency not done: {dep}")

for line in context_pack.splitlines():
    if line.startswith("## Parent Epic Summary"):
        break
else:
    raise SystemExit("Missing parent epic summary in context pack")
if epic_id not in {"", "null"} and "No parent epic." in context_pack:
    raise SystemExit("Parent epic summary missing")
if story_id not in {"", "null"} and "No parent story." in context_pack:
    raise SystemExit("Parent story summary missing")

if "## Selected Repo Memory" not in context_pack:
    raise SystemExit("Missing selected repo memory section in context pack")
if not full_context_path.exists():
    raise SystemExit(f"Missing full context evidence: {full_context_path}")
for required_section in [
    "## Repo Mode Summary",
    "## Repository Intelligence",
    "## Impact Scan",
    "## Verification Scope",
]:
    if required_section not in context_pack:
        raise SystemExit(f"Missing repo-mode section in context pack: {required_section}")

print("Work alignment checks passed.")
PY

{
  echo "# Work Alignment"
  echo
  echo "task_id: $task_id"
  echo "result: pass"
  echo "checked_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo
  echo "## Alignment"
  echo
  echo "- parent_epic_id: ${epic_id:-none}"
  echo "- parent_story_id: ${story_id:-none}"
  echo "- repo_mode: ${repo_mode:-none}"
  echo "- task_change_type: ${task_change_type:-none}"
  echo "- task_touches_existing_behavior: ${task_touches_existing_behavior:-none}"
  echo "- task_backward_compatibility_required: ${task_backward_compatibility_required:-none}"
  echo "- story_registry: ${story_registry:-none}"
  echo "- full_context: $full_context"
  echo "- lifecycle_phase: $(fm_value "$PLAN_PATH" "lifecycle_phase")"
  echo "- approved_scopes_count: $(fm_list_count "$PLAN_PATH" "approved_scopes")"
  echo "- approved_files_count: $(fm_list_count "$PLAN_PATH" "approved_files")"
  echo "- task_record: present"
  echo
  echo "## Result"
  echo
  echo "Work alignment checks passed."
} > "$file"

echo "Work alignment checks passed."
