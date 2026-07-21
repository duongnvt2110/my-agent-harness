#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

HARNESS_ROOT="$tmp/.agent-harness" mkdir -p "$tmp/.agent-harness/docs/tasks/task_ok" "$tmp/.agent-harness/scripts"
cp "$harness_root/scripts/check-task-plan-consistency.sh" "$tmp/.agent-harness/scripts/"
cp "$harness_root/scripts/harness-lib.sh" "$tmp/.agent-harness/scripts/"
printf '{"id":"task_ok","status":"DONE"}\n' > "$tmp/.agent-harness/docs/tasks/tasks.jsonl"
cat > "$tmp/.agent-harness/docs/tasks/task_ok/implementation-plan.md" <<'EOF'
---
task_id: task_ok
status: COMPLETED
lifecycle_phase: COMPLETED
---
# Task
EOF
(cd "$tmp" && HARNESS_ROOT="$tmp/.agent-harness" bash .agent-harness/scripts/check-task-plan-consistency.sh)

perl -pi -e 's/status: COMPLETED/status: APPROVED/' "$tmp/.agent-harness/docs/tasks/task_ok/implementation-plan.md"
if (cd "$tmp" && HARNESS_ROOT="$tmp/.agent-harness" bash .agent-harness/scripts/check-task-plan-consistency.sh >/dev/null 2>&1); then
  echo "accepted mismatched terminal plan" >&2
  exit 1
fi
echo "Task-plan consistency regression passed."
