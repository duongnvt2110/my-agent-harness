#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

task_store="${TASK_STORE:-docs/tasks/tasks.jsonl}"
plan_snapshot_dir="docs/tasks/$(fm_value "$PLAN_PATH" "task_id")"
plan_snapshot_file="$plan_snapshot_dir/implementation-plan.md"
normalize_fm_value() {
  local value="${1:-}"
  if [ -z "$value" ] || [ "$value" = "null" ]; then
    printf '%s' ""
  else
    printf '%s' "$value"
  fi
}

task_id="$(normalize_fm_value "$(fm_value "$PLAN_PATH" "task_id")")"
task_title="$(normalize_fm_value "$(fm_value "$PLAN_PATH" "title")")"
epic_id="$(normalize_fm_value "$(fm_value "$PLAN_PATH" "parent_epic_id")")"
story_id="$(normalize_fm_value "$(fm_value "$PLAN_PATH" "parent_story_id")")"
story_registry="$(normalize_fm_value "$(fm_value "$PLAN_PATH" "story_registry")")"
epic_context_required="$(fm_value "$PLAN_PATH" "epic_context_required")"
plan_lane="$(normalize_fm_value "$(fm_value "$PLAN_PATH" "lane")")"
repo_mode="$(normalize_fm_value "$(fm_value "$PLAN_PATH" "repo_mode")")"
task_change_type="$(normalize_fm_value "$(fm_value "$PLAN_PATH" "task_change_type")")"
task_touches_existing_behavior="$(normalize_fm_value "$(fm_value "$PLAN_PATH" "task_touches_existing_behavior")")"
task_backward_compatibility_required="$(normalize_fm_value "$(fm_value "$PLAN_PATH" "task_backward_compatibility_required")")"

[ -n "$task_id" ] || fail "Missing task_id in active plan"
[ -n "$task_title" ] || task_title="$task_id"

mkdir -p "$plan_snapshot_dir"
cp -p "$PLAN_PATH" "$plan_snapshot_file"

if [ "$epic_context_required" = "true" ] || [ -n "$epic_id" ] || [ -n "$story_id" ]; then
  [ -n "$epic_id" ] && [ -n "$story_id" ] || fail "Epic-scoped plans require both parent_epic_id and parent_story_id"
  story_registry="${story_registry:-docs/epics/$epic_id/stories.jsonl}"
  [ -f "$story_registry" ] || fail "Missing story registry: $story_registry"
  python3 - "$story_registry" "$story_id" <<'PY'
import json
import pathlib
import sys

story_registry = pathlib.Path(sys.argv[1])
story_id = sys.argv[2]
rows = [json.loads(line) for line in story_registry.read_text().splitlines() if line.strip()]
story = next((row for row in rows if row.get("id") == story_id), None)
if story is None:
    raise SystemExit(f"Story not found in registry: {story_id}")
if not story.get("acceptance"):
    raise SystemExit(f"Story acceptance empty: {story_id}")
if story.get("status") not in {"READY", "ACTIVE", "DONE", "BLOCKED"}:
    raise SystemExit(f"Invalid story status: {story.get('status')}")
PY
fi

mkdir -p "$(dirname "$task_store")"
touch "$task_store"

python3 - "$task_store" "$task_id" "$task_title" "$epic_id" "$story_id" "$plan_lane" "$repo_mode" "$task_change_type" "$task_touches_existing_behavior" "$task_backward_compatibility_required" "$plan_snapshot_file" <<'PY'
import json
import pathlib
import sys

task_store = pathlib.Path(sys.argv[1])
task_id = sys.argv[2]
title = sys.argv[3]
epic_id = sys.argv[4]
story_id = sys.argv[5]
lane = sys.argv[6]
repo_mode = sys.argv[7]
task_change_type = sys.argv[8]
task_touches_existing_behavior = sys.argv[9]
task_backward_compatibility_required = sys.argv[10]
plan_snapshot_file = sys.argv[11]

records = [json.loads(line) for line in task_store.read_text().splitlines() if line.strip()] if task_store.exists() else []
record = next((row for row in records if row.get("id") == task_id), None)
if record is None:
    record = {
        "id": task_id,
        "epic_id": "",
        "story_id": "",
        "title": title,
        "status": "READY",
        "depends_on": [],
        "priority": "normal",
        "lane": lane or "normal",
        "repo_mode": repo_mode,
        "task_change_type": task_change_type,
        "task_touches_existing_behavior": task_touches_existing_behavior,
        "task_backward_compatibility_required": task_backward_compatibility_required,
        "implementation_plan_path": plan_snapshot_file,
    }
    records.append(record)
else:
    record.setdefault("depends_on", [])
    record.setdefault("priority", "normal")
    record.setdefault("lane", lane or "normal")
    record.setdefault("repo_mode", repo_mode)
    record.setdefault("task_change_type", task_change_type)
    record.setdefault("task_touches_existing_behavior", task_touches_existing_behavior)
    record.setdefault("task_backward_compatibility_required", task_backward_compatibility_required)
    record.setdefault("implementation_plan_path", plan_snapshot_file)
    record["title"] = title

record["epic_id"] = "" if epic_id == "null" else epic_id
record["story_id"] = "" if story_id == "null" else story_id
if lane:
    record["lane"] = lane
if repo_mode:
    record["repo_mode"] = repo_mode
if task_change_type:
    record["task_change_type"] = task_change_type
if task_touches_existing_behavior:
    record["task_touches_existing_behavior"] = task_touches_existing_behavior
if task_backward_compatibility_required:
    record["task_backward_compatibility_required"] = task_backward_compatibility_required
if plan_snapshot_file:
    record["implementation_plan_path"] = plan_snapshot_file

task_store.write_text("\n".join(json.dumps(row, separators=(",", ":")) for row in records) + "\n")
PY

echo "Consumed active plan into task store: $task_id"
