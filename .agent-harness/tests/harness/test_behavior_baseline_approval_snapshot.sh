#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/behavior_baseline_approval_snapshot' EXIT

task_id="behavior_baseline_approval_snapshot"
plan="$tmp/current.md"
root="$tmp/approval-snapshot"

cat > "$plan" <<EOF
---
task_id: $task_id
repo_mode: brownfield
task_touches_existing_behavior: true
---
EOF

cp -R tests/fixtures/baseline/approval-snapshot "$root"

PLAN_PATH="$plan" ./scripts/detect-behavior-baseline.sh --task "$task_id" --root "$root" --mode approval_snapshot >/dev/null

grep -q '^behavior_tracking:[[:space:]]*approval_snapshot$' "docs/evidence/$task_id/behavior-baseline.md" || {
  echo "Expected approval_snapshot behavior tracking" >&2
  exit 1
}
[ -f "docs/evidence/$task_id/approval-snapshot.md" ] || {
  echo "Missing approval snapshot" >&2
  exit 1
}

PLAN_PATH="$plan" ./scripts/check-behavior-baseline.sh --task "$task_id" >/dev/null

echo "Behavior baseline approval snapshot regression passed."
