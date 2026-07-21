#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/baseline_contract' EXIT

task_id="baseline_contract"
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
git -C "$root" init -q
git -C "$root" config user.email test@example.com
git -C "$root" config user.name Test
git -C "$root" add .
git -C "$root" commit -q -m "baseline"

PLAN_PATH="$plan" ./scripts/detect-change-baseline.sh --task "$task_id" --root "$root" >/dev/null
PLAN_PATH="$plan" ./scripts/detect-behavior-baseline.sh --task "$task_id" --root "$root" >/dev/null

PLAN_PATH="$plan" ./scripts/check-baseline-contract.sh >/dev/null

echo "Baseline contract regression passed."
