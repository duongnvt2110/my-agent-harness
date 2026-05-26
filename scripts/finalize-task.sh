#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

[ -f "$PLAN_PATH" ] || fail "Missing active plan: $PLAN_PATH"

./scripts/verify.sh

pass_file="$(evidence_dir)/verification-pass.md"
[ -f "$pass_file" ] || fail "Missing verification pass file after verify: $pass_file"

task_id="$(fm_value "$PLAN_PATH" "task_id")"
completed_dir="docs/exec-plans/completed"
completed_at="$(date '+%Y-%m-%d %H:%M')"
completed_file="$completed_dir/$(date '+%Y_%m_%d')_${task_id}.md"

mkdir -p "$completed_dir"
[ ! -e "$completed_file" ] || fail "Completed plan already exists: $completed_file"

set_fm_value "$PLAN_PATH" "status" "COMPLETED"
set_fm_value "$PLAN_PATH" "lifecycle_phase" "FINALIZE"
set_fm_value "$PLAN_PATH" "completed_at" "\"$completed_at\""

mv "$PLAN_PATH" "$completed_file"

echo "Task finalized: $completed_file"
