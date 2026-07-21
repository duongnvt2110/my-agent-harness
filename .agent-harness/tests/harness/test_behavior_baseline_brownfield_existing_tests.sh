#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/behavior_baseline_brownfield_existing_tests' EXIT

task_id="behavior_baseline_brownfield_existing_tests"
plan="$tmp/current.md"
root="$tmp/brownfield-with-tests"

cat > "$plan" <<EOF
---
task_id: $task_id
repo_mode: brownfield
task_touches_existing_behavior: true
---
EOF

cp -R tests/fixtures/baseline/brownfield-with-tests "$root"

PLAN_PATH="$plan" ./scripts/detect-behavior-baseline.sh --task "$task_id" --root "$root" >/dev/null

grep -q '^behavior_tracking:[[:space:]]*existing_tests$' "docs/evidence/$task_id/behavior-baseline.md" || {
  echo "Expected existing_tests behavior tracking" >&2
  exit 1
}

PLAN_PATH="$plan" ./scripts/check-behavior-baseline.sh --task "$task_id" >/dev/null

echo "Behavior baseline brownfield existing-tests regression passed."
