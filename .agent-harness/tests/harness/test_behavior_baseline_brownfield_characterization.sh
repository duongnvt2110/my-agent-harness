#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/behavior_baseline_brownfield_characterization' EXIT

task_id="behavior_baseline_brownfield_characterization"
plan="$tmp/current.md"
root="$tmp/brownfield-no-tests"

cat > "$plan" <<EOF
---
task_id: $task_id
repo_mode: brownfield
task_touches_existing_behavior: true
---
EOF

cp -R tests/fixtures/baseline/brownfield-no-tests "$root"

PLAN_PATH="$plan" ./scripts/detect-behavior-baseline.sh --task "$task_id" --root "$root" >/dev/null

grep -q '^behavior_tracking:[[:space:]]*characterization$' "docs/evidence/$task_id/behavior-baseline.md" || {
  echo "Expected characterization behavior tracking" >&2
  exit 1
}

PLAN_PATH="$plan" ./scripts/check-behavior-baseline.sh --task "$task_id" >/dev/null

echo "Behavior baseline brownfield characterization regression passed."
