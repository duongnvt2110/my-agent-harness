#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/docs/exec-plans/active" "$tmp/docs/reviews" "$tmp/scripts"
cp scripts/harness-lib.sh scripts/check-reviews.sh "$tmp/scripts/"
cp docs/reviews/TEMPLATE.md "$tmp/docs/reviews/"
cat > "$tmp/docs/exec-plans/active/current.md" <<'EOF'
---
task_id: review_contract_task
lane: normal
review_required: true
---
EOF
cat > "$tmp/docs/reviews/review.md" <<'EOF'
---
task_id: review_contract_task
result: PASS
reviewed_at: "2026-07-12 15:00"
blocker_findings: 0
blocks_completion: false
reviewer: verifier-session
review_session: session-1
---
EOF
HARNESS_ROOT="$tmp" PLAN_PATH="$tmp/docs/exec-plans/active/current.md" \
  "$tmp/scripts/check-reviews.sh" >/dev/null

perl -0pi -e 's/reviewer: verifier-session/reviewer: Primary/' "$tmp/docs/reviews/review.md"
if HARNESS_ROOT="$tmp" PLAN_PATH="$tmp/docs/exec-plans/active/current.md" \
  "$tmp/scripts/check-reviews.sh" >/dev/null 2>&1; then
  echo "legacy role-named review unexpectedly passed" >&2
  exit 1
fi
echo "Required review contract regression passed."
