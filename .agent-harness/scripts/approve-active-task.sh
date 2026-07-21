#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

TASK_STORE="${TASK_STORE:-docs/tasks/tasks.jsonl}"
EPIC_ROOT="${EPIC_ROOT:-docs/epics}"

[ -f "$PLAN_PATH" ] || fail "Missing active plan: $PLAN_PATH"

./scripts/check-active-plan-contract.sh >/dev/null

python3 - "$PLAN_PATH" "$TASK_STORE" "$EPIC_ROOT" <<'PY'
from __future__ import annotations

import json
import pathlib
import re
import sys

plan = pathlib.Path(sys.argv[1])
task_store = pathlib.Path(sys.argv[2])
epic_root = pathlib.Path(sys.argv[3])
text = plan.read_text()
frontmatter = text.split("---", 2)[1] if text.startswith("---") else ""
body = text.split("---", 2)[2] if text.startswith("---") and len(text.split("---", 2)) == 3 else text

def fm(key: str) -> str:
    m = re.search(rf"^{re.escape(key)}:\s*(.+?)\s*$", frontmatter, flags=re.M)
    if not m:
        return ""
    value = m.group(1).strip().strip('"\'')
    return "" if value in {"null", "None"} else value

task_id = fm("task_id")
if not re.match(r"^[a-z0-9]+(_[a-z0-9]+)*$", task_id or ""):
    raise SystemExit(f"Invalid task_id: {task_id}")
if "## Epic / Story / Task Breakdown" in body:
    raise SystemExit("Active task must not contain full Epic / Story / Task Breakdown")
if len(re.findall(r"^###\s+Epic\b", body, flags=re.M)) > 0:
    raise SystemExit("Active task must not contain epic sections")
if len(re.findall(r"^###\s+Story\b", body, flags=re.M)) > 0:
    raise SystemExit("Active task must not contain story sections")
if len(re.findall(r"^###\s+Task\b", body, flags=re.M)) > 1:
    raise SystemExit("Active task must contain only one task section")

records = []
if task_store.exists():
    records = [json.loads(line) for line in task_store.read_text().splitlines() if line.strip()]
record = next((row for row in records if row.get("id") == task_id), None)
if record is None:
    raise SystemExit(f"Task not found in registry: {task_id}")
if record.get("status") not in {"READY", "ACTIVE", "IN_PROGRESS"}:
    raise SystemExit(f"Task is not activatable: {task_id} status={record.get('status')}")

epic_id = fm("parent_epic_id") or record.get("epic_id")
story_id = fm("parent_story_id") or record.get("story_id")
if epic_id:
    story_file = epic_root / epic_id / "stories.jsonl"
    if not story_file.exists():
        raise SystemExit(f"Missing story registry: {story_file}")
    stories = [json.loads(line) for line in story_file.read_text().splitlines() if line.strip()]
    if not any(row.get("id") == story_id for row in stories):
        raise SystemExit(f"Story not found: {story_id}")

if not record.get("acceptance_criteria"):
    raise SystemExit(f"Task missing acceptance_criteria: {task_id}")
if not record.get("required_checks"):
    raise SystemExit(f"Task missing required_checks: {task_id}")
PY

set_fm_value "$PLAN_PATH" "status" "IN_PROGRESS"
set_fm_value "$PLAN_PATH" "lifecycle_phase" "EXECUTE"
set_fm_value "$PLAN_PATH" "implementation_allowed" "true"
set_fm_value "$PLAN_PATH" "file_map_approved" "true"
set_fm_value "$PLAN_PATH" "approved_by" "human"
set_fm_value "$PLAN_PATH" "approved_at" "\"$(date '+%Y-%m-%d %H:%M')\""

task_id="$(fm_value "$PLAN_PATH" "task_id")"
task_title="$(fm_value "$PLAN_PATH" "title")"
./scripts/task.sh mark-in-progress "$task_id" "$task_title" >/dev/null

echo "Approved active task: $PLAN_PATH"
