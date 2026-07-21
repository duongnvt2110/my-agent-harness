#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/docs/tasks" "$tmp/docs/epics/epic/stories" "$tmp/docs/intake" "$tmp/docs/tasks/v3_task" "$tmp/docs/tasks/legacy_task"
printf '%s\n' '{"id":"implementation_tasks","acceptance":["task"]}' > "$tmp/docs/epics/epic/stories.jsonl"
printf '%s\n' 'v3-only implementation plan' > "$tmp/docs/intake/v3-plan.md"
printf '%s\n' 'workflow_version: 3' > "$tmp/docs/tasks/v3_task/implementation-plan.md"
printf '%s\n' 'workflow_version: 2' > "$tmp/docs/tasks/legacy_task/implementation-plan.md"
cat > "$tmp/docs/tasks/tasks.jsonl" <<EOF
{"id":"v3_task","epic_id":"epic","story_id":"implementation_tasks","title":"v3 task","status":"READY","depends_on":[],"source_plan_path":"$tmp/docs/intake/v3-plan.md","implementation_plan_path":"$tmp/docs/tasks/v3_task/implementation-plan.md"}
{"id":"legacy_task","epic_id":"epic","story_id":"implementation_tasks","title":"legacy task","status":"READY","depends_on":[],"source_plan_path":"$tmp/docs/intake/v3-plan.md","implementation_plan_path":"$tmp/docs/tasks/legacy_task/implementation-plan.md"}
EOF

if HARNESS_ROOT="$tmp" TASK_STORE="$tmp/docs/tasks/tasks.jsonl" EPIC_ROOT="$tmp/docs/epics" PLAN_PATH="$tmp/docs/exec-plans/active/current.md" \
  "$harness_root/scripts/task.sh" activate legacy_task >/dev/null 2>&1; then
  echo "legacy task artifact was selected" >&2
  exit 1
fi

echo "v3 artifact selection regression passed."
