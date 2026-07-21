#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

cmd="${1:-check}"
approval_path="${2:-${HARNESS_BATCH_APPROVAL_PATH:-$HARNESS_ROOT/runtime/v3-approved-batch.json}}"

case "$cmd" in
  check)
    exec "$script_dir/check-batch-approval.sh" "$approval_path" "${3:-$PLAN_PATH}"
    ;;
  status)
    [ -f "$approval_path" ] || fail "Missing batch approval: $approval_path"
    python3 - "$approval_path" "${TASK_STORE:-docs/tasks/tasks.jsonl}" <<'PY'
import json, pathlib, sys
approval = json.loads(pathlib.Path(sys.argv[1]).read_text())
rows = {row.get("id"): row.get("status") for row in (json.loads(line) for line in pathlib.Path(sys.argv[2]).read_text().splitlines() if line.strip())}
task_ids = [item["task_id"] for item in approval.get("tasks", [])]
done = sum(rows.get(task_id) == "DONE" for task_id in task_ids)
print(json.dumps({"batch_id": approval.get("batch_id"), "status": approval.get("status"), "tasks": len(task_ids), "done": done}, sort_keys=True))
PY
    ;;
  *)
    fail "Usage: scripts/batch-control.sh {check|status} [approval.json] [plan.md]"
    ;;
esac
