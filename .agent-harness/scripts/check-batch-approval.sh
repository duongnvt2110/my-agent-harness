#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

approval_path="${1:-${HARNESS_BATCH_APPROVAL_PATH:-$HARNESS_ROOT/runtime/v3-approved-batch.json}}"
plan_path="${2:-$PLAN_PATH}"
[ -f "$approval_path" ] || fail "Missing batch approval: $approval_path"
[ -f "$plan_path" ] || fail "Missing active plan: $plan_path"

python3 - "$approval_path" "$plan_path" <<'PY'
import datetime as dt
import json
import pathlib
import sys

approval_path, plan_path = map(pathlib.Path, sys.argv[1:])
approval = json.loads(approval_path.read_text())

if approval.get("schema_version") != 1:
    raise SystemExit("batch approval schema_version must be 1")
if approval.get("status") != "APPROVED":
    raise SystemExit("batch approval must have status=APPROVED")
if not approval.get("batch_id"):
    raise SystemExit("batch approval is missing batch_id")
if not approval.get("approved_by") or str(approval["approved_by"]).lower() in {"agent", "codex", "harness"}:
    raise SystemExit("batch approval must identify a human approver")
try:
    approved_at = dt.datetime.fromisoformat(str(approval["approved_at"]).replace("Z", "+00:00"))
except (KeyError, ValueError) as exc:
    raise SystemExit("batch approval approved_at must be ISO-8601") from exc
if approved_at.tzinfo is None:
    raise SystemExit("batch approval approved_at must include timezone")
if approved_at > dt.datetime.now(dt.timezone.utc) + dt.timedelta(minutes=5):
    raise SystemExit("batch approval timestamp is in the future")

task_id = next((line.split(":", 1)[1].strip().strip('"') for line in plan_path.read_text().splitlines() if line.startswith("task_id:")), "")
if not task_id:
    raise SystemExit("active plan is missing task_id")
tasks = approval.get("tasks")
if not isinstance(tasks, list) or not tasks:
    raise SystemExit("batch approval must contain a non-empty tasks list")
matches = [item for item in tasks if isinstance(item, dict) and item.get("task_id") == task_id]
if len(matches) != 1:
    raise SystemExit(f"task {task_id} is not bound exactly once in batch approval")

def yaml_list(text, key):
    lines = text.splitlines()
    result = []
    active = False
    for line in lines:
        if line.startswith(key + ":"):
            active = line.split(":", 1)[1].strip() == ""
            if not active:
                inline = line.split(":", 1)[1].strip().strip('"')
                if inline != "[]":
                    result.append(inline)
            continue
        if active:
            if line.startswith("  - "):
                result.append(line[4:].strip().strip('"'))
            elif line and not line.startswith(" "):
                active = False
    return sorted(result)

plan_text = plan_path.read_text()
plan_scopes = yaml_list(plan_text, "approved_scopes")
plan_files = yaml_list(plan_text, "approved_files")
entry_scopes = sorted(str(value) for value in matches[0].get("approved_scopes", []))
entry_files = sorted(str(value) for value in matches[0].get("approved_files", []))
if plan_scopes != entry_scopes or plan_files != entry_files:
    raise SystemExit("batch approval scope does not exactly match active plan")

for item in tasks:
    if not isinstance(item, dict) or not item.get("task_id"):
        raise SystemExit("batch approval contains an invalid task binding")
    forbidden = {"v2", "sandbox", "network", "signed", "identity", "deployment", "adapter"}
    if forbidden.intersection(str(item).lower().split()):
        raise SystemExit("batch approval contains an excluded v3 feature")

print(json.dumps({"valid": True, "batch_id": approval["batch_id"], "task_id": task_id}, sort_keys=True))
PY
