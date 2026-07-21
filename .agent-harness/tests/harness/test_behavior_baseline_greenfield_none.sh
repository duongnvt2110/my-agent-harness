#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/behavior_baseline_greenfield_none' EXIT

task_id="behavior_baseline_greenfield_none"
plan="$tmp/current.md"
root="$tmp/greenfield"

cat > "$plan" <<EOF
---
task_id: $task_id
repo_mode: greenfield
task_touches_existing_behavior: false
---
EOF

cp -R tests/fixtures/baseline/greenfield "$root"

PLAN_PATH="$plan" ./scripts/detect-behavior-baseline.sh --task "$task_id" --root "$root" >/dev/null

grep -q '^behavior_tracking:[[:space:]]*none$' "docs/evidence/$task_id/behavior-baseline.md" || {
  echo "Expected none behavior tracking" >&2
  exit 1
}

PLAN_PATH="$plan" ./scripts/check-behavior-baseline.sh --task "$task_id" >/dev/null

echo "Behavior baseline greenfield none regression passed."
