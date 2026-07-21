#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/scripts" "$tmp/runtime"
cp "$root/scripts/harness-lib.sh" "$root/scripts/check-batch-approval.sh" "$tmp/scripts/"

cat > "$tmp/plan.md" <<'EOF'
---
task_id: task-in-batch
approved_scopes:
  - harness_core
approved_files: []
---
EOF
cat > "$tmp/approval.json" <<'EOF'
{"schema_version":1,"batch_id":"batch-001","status":"APPROVED","approved_by":"human-operator","approved_at":"2026-07-16T00:00:00Z","tasks":[{"task_id":"task-in-batch","approved_scopes":["harness_core"],"approved_files":[]}]}
EOF
HARNESS_ROOT="$tmp" PLAN_PATH="$tmp/plan.md" "$tmp/scripts/check-batch-approval.sh" "$tmp/approval.json" "$tmp/plan.md" >/dev/null

sed 's/task-in-batch/task-outside-batch/' "$tmp/plan.md" > "$tmp/outside.md"
if HARNESS_ROOT="$tmp" PLAN_PATH="$tmp/outside.md" "$tmp/scripts/check-batch-approval.sh" "$tmp/approval.json" "$tmp/outside.md" >/dev/null 2>&1; then
  echo "task outside approved batch unexpectedly passed" >&2
  exit 1
fi

sed 's/"harness_core"/"app_tests"/' "$tmp/approval.json" > "$tmp/mismatch.json"
if HARNESS_ROOT="$tmp" PLAN_PATH="$tmp/plan.md" "$tmp/scripts/check-batch-approval.sh" "$tmp/mismatch.json" "$tmp/plan.md" >/dev/null 2>&1; then
  echo "scope mismatch unexpectedly passed" >&2
  exit 1
fi

echo "Batch finalization approval regression passed."
