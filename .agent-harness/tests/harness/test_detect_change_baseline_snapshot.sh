#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp" docs/evidence/detect_change_baseline_snapshot' EXIT

task_id="detect_change_baseline_snapshot"
plan="$tmp/current.md"
root="$tmp/no-git-repo"

cat > "$plan" <<EOF
---
task_id: $task_id
---
EOF

cp -R tests/fixtures/baseline/no-git-repo "$root"

PLAN_PATH="$plan" ./scripts/detect-change-baseline.sh --task "$task_id" --root "$root" >/dev/null

grep -q '^change_tracking:[[:space:]]*snapshot$' "docs/evidence/$task_id/baseline-decision.md" || {
  echo "Expected snapshot change tracking" >&2
  exit 1
}
[ -f "docs/evidence/$task_id/baseline-snapshot.json" ] || {
  echo "Missing baseline snapshot" >&2
  exit 1
}

PLAN_PATH="$plan" ./scripts/check-change-baseline.sh --task "$task_id" >/dev/null

echo "Detect change baseline snapshot regression passed."
