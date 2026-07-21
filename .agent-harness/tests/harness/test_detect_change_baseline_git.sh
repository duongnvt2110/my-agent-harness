#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/detect_change_baseline_git' EXIT

task_id="detect_change_baseline_git"
plan="$tmp/current.md"
root="$tmp/git-repo"

cat > "$plan" <<EOF
---
task_id: $task_id
---
EOF

cp -R tests/fixtures/baseline/git-repo "$root"
git -C "$root" init -q
git -C "$root" config user.email test@example.com
git -C "$root" config user.name Test
git -C "$root" add .
git -C "$root" commit -q -m "baseline"

PLAN_PATH="$plan" ./scripts/detect-change-baseline.sh --task "$task_id" --root "$root" >/dev/null

grep -q '^change_tracking:[[:space:]]*git$' "docs/evidence/$task_id/baseline-decision.md" || {
  echo "Expected git change tracking" >&2
  exit 1
}

PLAN_PATH="$plan" ./scripts/check-change-baseline.sh --task "$task_id" >/dev/null

echo "Detect change baseline git regression passed."
