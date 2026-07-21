#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/scripts" "$tmp/docs/tasks" "$tmp/docs/intake" "$tmp/docs/evidence/clean"
cp "$root/scripts/audit.sh" "$root/scripts/harness-lib.sh" "$root/scripts/harness.sh" "$tmp/scripts/"
touch "$tmp/docs/intake/request.md"

cat > "$tmp/docs/tasks/tasks.jsonl" <<EOF
{"id":"clean-task","status":"DONE","source_plan_path":"$tmp/docs/intake/request.md"}
EOF
cat > "$tmp/docs/evidence/clean/finalization-journal.json" <<'EOF'
{"task_id":"clean-task","status":"FINALIZED","steps":[{"name":"verify","status":"DONE"}]}
EOF

clean="$(HARNESS_ROOT="$tmp" PLAN_PATH="$tmp/no-active.md" HARNESS_V3_DISPATCHED=1 "$tmp/scripts/harness.sh" audit --json)"
[[ "$clean" == *'"passed": true'* ]]

cat > "$tmp/docs/tasks/tasks.jsonl" <<EOF
{"id":"stale-task","status":"IN_PROGRESS","source_plan_path":"$tmp/docs/intake/missing.md"}
EOF
if HARNESS_ROOT="$tmp" PLAN_PATH="$tmp/no-active.md" HARNESS_V3_DISPATCHED=1 "$tmp/scripts/harness.sh" audit --json >/dev/null 2>&1; then
  echo "stale audit unexpectedly passed" >&2
  exit 1
fi

echo "v4 Slice 0 audit regression passed."
