#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

report_dir="$tmp/reports"

if HARNESS_REPORT_DIR="$report_dir" HARNESS_MIN_SCORE=999 HARNESS_SKIP_FAILURE_INJECTION=1 HARNESS_TEMPLATE_MODE=true ./scripts/score-harness.sh >/dev/null 2>&1; then
  echo "Expected score-harness.sh to fail under an impossible threshold" >&2
  exit 1
fi

[ -f "$report_dir/harness-quality-score.md" ] || {
  echo "Missing temp score report after injected failure" >&2
  exit 1
}
grep -q '^result:[[:space:]]*fail$' "$report_dir/harness-quality-score.md" || {
  echo "Temp score report did not record failure" >&2
  exit 1
}

echo "Failure injection regression passed."
