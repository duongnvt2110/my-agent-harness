#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

cmd="${1:-next}"

case "$cmd" in
  next)
    if [ ! -f "$PLAN_PATH" ]; then
      cat <<'EOF'
HARNESS TASK PACKET

Current lifecycle phase: PLAN
Active plan: missing

Next allowed action:
Create docs/exec-plans/active/current.md from docs/exec-plans/TEMPLATE.md and define the task contract.

Forbidden:
- Do not implement without an active plan.
- Do not edit outside the intended harness scope.
EOF
      exit 1
    fi

    approved_scopes="$(fm_list "$PLAN_PATH" "approved_scopes" | sed 's/^/- /')"
    [ -n "$approved_scopes" ] || approved_scopes="- (none)"
    approved_files="$(fm_list "$PLAN_PATH" "approved_files" | sed 's/^/- /')"
    [ -n "$approved_files" ] || approved_files="- (none)"
    approved_deletions="$(fm_list "$PLAN_PATH" "approved_deletions" | sed 's/^/- /')"
    [ -n "$approved_deletions" ] || approved_deletions="- (none)"

    cat <<EOF
HARNESS TASK PACKET

Task ID: $(fm_value "$PLAN_PATH" "task_id")
Status: $(fm_value "$PLAN_PATH" "status")
Lifecycle phase: $(fm_value "$PLAN_PATH" "lifecycle_phase")
Lane: $(fm_value "$PLAN_PATH" "lane")
Active plan: $PLAN_PATH

Next allowed action:
Follow the active plan lifecycle phase and change only approved scopes.

Approved scopes:
$approved_scopes

Approved file exceptions:
$approved_files

Approved deletions:
$approved_deletions

Required checks:
$(required_check_rows "$PLAN_PATH" | awk -F '\t' '{print "- " $1 ": " $3}')

Forbidden:
- Do not change files outside approved scopes or approved file exceptions.
- Do not delete files outside approved scopes or approved deletions.
- Do not mark completion manually.
- Do not skip required checks.
- Do not treat direct chat as approval to bypass the harness lifecycle.
EOF
    ;;
  verify)
    exec ./scripts/verify.sh
    ;;
  finalize)
    exec ./scripts/finalize-task.sh
    ;;
  *)
    fail "Usage: $0 [next|verify|finalize]"
    ;;
esac
