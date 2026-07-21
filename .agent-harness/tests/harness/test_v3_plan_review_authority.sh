#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/docs/exec-plans/active" "$tmp/docs/exec-plans" "$tmp/docs/tasks" "$tmp/docs/reviews"
cp "$harness_root/docs/exec-plans/TEMPLATE.md" "$tmp/docs/exec-plans/TEMPLATE.md"
cp "$harness_root/scripts/harness-lib.sh" "$harness_root/scripts/create-active-plan.sh" "$tmp/"
printf '%s\n' '{"id":"v3_plan_task","title":"V3 plan task","status":"READY","lane":"tiny","approved_scopes":["harness_core"],"approved_files":[],"required_checks":[]}' > "$tmp/docs/tasks/tasks.jsonl"
HARNESS_ROOT="$tmp" TASK_STORE=docs/tasks/tasks.jsonl HARNESS_SKIP_BASELINE_DETECT=1 PLAN_PATH="$tmp/docs/exec-plans/active/current.md" \
  bash "$tmp/create-active-plan.sh" v3_plan_task "V3 plan task" >/dev/null
grep -q '^workflow_version: 3$' "$tmp/docs/exec-plans/active/current.md" || {
  sed -n '1,25p' "$tmp/docs/exec-plans/active/current.md" >&2
  exit 1
}

if grep -q '^workflow_version: [12]$' "$tmp/docs/exec-plans/active/current.md"; then
  echo 'legacy workflow version was written to the active plan' >&2
  exit 1
fi

echo 'v3 plan and review authority regression passed'
