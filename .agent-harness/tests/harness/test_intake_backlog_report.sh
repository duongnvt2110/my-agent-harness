#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/scripts" "$tmp/runtime" "$tmp/docs/intake" "$tmp/docs/tasks"
cp "$root/scripts/harness.sh" "$root/scripts/harness-lib.sh" "$root/scripts/task.sh" "$tmp/scripts/"
cp "$root/runtime/v3-workflow.json" "$tmp/runtime/"
touch "$tmp/docs/intake/completed.md" "$tmp/docs/intake/unfinished.md"

cat > "$tmp/docs/tasks/tasks.jsonl" <<EOF
{"id":"done-task","source_plan_path":"$tmp/docs/intake/completed.md","status":"DONE"}
{"id":"open-task","source_plan_path":"$tmp/docs/intake/unfinished.md","status":"READY"}
EOF

output="$(HARNESS_ROOT="$tmp" HARNESS_V3_DISPATCHED=1 "$tmp/scripts/harness.sh" next)" || true
[[ "$output" == *"Long-plan intake files: 1"* ]]

sed 's/"status":"READY"/"status":"DONE"/' "$tmp/docs/tasks/tasks.jsonl" > "$tmp/docs/tasks/done.jsonl"
mv "$tmp/docs/tasks/done.jsonl" "$tmp/docs/tasks/tasks.jsonl"
output="$(HARNESS_ROOT="$tmp" HARNESS_V3_DISPATCHED=1 "$tmp/scripts/harness.sh" next)" || true
[[ "$output" == *"Long-plan intake files: 0"* ]]

echo "Intake backlog report regression passed."
