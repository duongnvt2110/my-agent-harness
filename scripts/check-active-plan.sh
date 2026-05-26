#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

active_dir="docs/exec-plans/active"

[ -d "$active_dir" ] || fail "Missing active plan directory: $active_dir"
[ -f "$PLAN_PATH" ] || fail "Missing active plan: $PLAN_PATH"

plan_count="$(find "$active_dir" -maxdepth 1 -type f -name "*.md" | wc -l | tr -d " ")"
[ "$plan_count" = "1" ] || fail "Expected exactly one active plan in $active_dir, found $plan_count"

awk 'NR==1 && $0=="---" {ok=1} END {exit(ok?0:1)}' "$PLAN_PATH" || fail "Active plan must start with YAML frontmatter: $PLAN_PATH"
awk 'BEGIN{c=0} /^---$/ {c++} END{exit(c>=2?0:1)}' "$PLAN_PATH" || fail "Active plan missing closing frontmatter delimiter: $PLAN_PATH"

status="$(fm_value "$PLAN_PATH" "status")"
[ "$status" != "COMPLETED" ] || fail "Completed plan must not remain active: $PLAN_PATH"

echo "Active plan presence checks passed."

