#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

active_dir="$(dirname "$PLAN_PATH")"
template_path="docs/exec-plans/TEMPLATE.md"
task_id="${1:-}"
title="${2:-Draft task}"

[ -n "$task_id" ] || fail "Usage: $0 <task_id> [title]"
[[ "$task_id" =~ ^[a-z0-9]+(_[a-z0-9]+)*$ ]] || fail "task_id must be lowercase snake_case: $task_id"
[ -f "$template_path" ] || fail "Missing plan template: $template_path"

if [ -f "$PLAN_PATH" ]; then
  fail "Active plan already exists at $PLAN_PATH. Continue, verify, or finalize that task before creating another active plan."
fi

plan_count="$(find "$active_dir" -maxdepth 1 -type f -name "*.md" | wc -l | tr -d " ")"
[ "$plan_count" = "0" ] || fail "Active plan directory already contains $plan_count markdown plan(s). Resolve the existing active plan before creating another."

mkdir -p "$active_dir"
cp "$template_path" "$PLAN_PATH"

safe_title="${title//\"/}"
set_fm_value "$PLAN_PATH" "task_id" "$task_id"
set_fm_value "$PLAN_PATH" "title" "\"$safe_title\""

echo "Created active plan: $PLAN_PATH"
echo "Next: edit this plan in place until it is approved for implementation."
