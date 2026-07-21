#!/usr/bin/env bash
set -euo pipefail

for command in lock-spec events approve-plan break-task; do
  output="$(scripts/harness.sh "$command" 2>&1 || true)"
  case "$command" in
    lock-spec) grep -q 'Public spec-lock authority is retired in v3' <<<"$output" || exit 1 ;;
    events) grep -q 'run-events.sh create' <<<"$output" || exit 1 ;;
    approve-plan) (grep -q 'Plan approval requires' <<<"$output" || grep -q 'Missing active plan' <<<"$output") || exit 1 ;;
    break-task) grep -q 'Public intake-graph authority is retired in v3' <<<"$output" || exit 1 ;;
  esac
done
output="$(scripts/harness.sh intake 2>&1 || true)"
grep -q 'scripts/intake-control.sh create REQUEST.json PACKAGE.json' <<<"$output" || exit 1
if scripts/harness.sh verify --profile unsupported >/dev/null 2>&1; then
  echo "unsupported verification profile was not denied" >&2
  exit 1
fi
missing_plan="$(mktemp -u)"
output="$(HARNESS_V3_DISPATCHED=1 PLAN_PATH="$missing_plan" scripts/harness.sh next 2>&1 || true)"
if command -v rtk >/dev/null 2>&1; then
  grep -q 'rtk .agent-harness/scripts/create-active-plan.sh' <<<"$output" || exit 1
else
  grep -q 'bash .agent-harness/scripts/create-active-plan.sh' <<<"$output" || exit 1
fi
echo "Public CLI compatibility regression passed."
