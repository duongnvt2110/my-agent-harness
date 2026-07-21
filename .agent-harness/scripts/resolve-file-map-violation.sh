#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

action="${1:-}"
target="${2:-}"

[ -n "$action" ] && [ -n "$target" ] || fail "Usage: $0 <revert|remove-untracked|scope-request> <path>"

dir="$(evidence_dir)"
violation="$dir/file-map-violation.md"

[ -f "$violation" ] || fail "Missing file-map violation packet: $violation"

case "$target" in
  /*|*..*) fail "Refusing unsafe path: $target" ;;
esac

case "$action" in
  revert)
    git ls-files --error-unmatch "$target" >/dev/null 2>&1 || fail "Cannot revert untracked path with revert action: $target"
    git restore -- "$target"
    rtk ./scripts/record-decision.sh \
      --type AUTO_REVERT \
      --phase SCOPE_REMEDIATION \
      --trigger file_map_violation \
      --evidence "$violation" \
      --action "git restore -- $target" \
      --prediction "File-map check will pass after reverting the unapproved tracked edit." \
      --result reverted \
      --requires-human-review false \
      --file "$target"
    result="reverted"
    ;;
  remove-untracked)
    if git ls-files --error-unmatch "$target" >/dev/null 2>&1; then
      fail "Refusing to remove tracked file with remove-untracked action: $target"
    fi
    [ -e "$target" ] || fail "Untracked path does not exist: $target"
    rm -rf -- "$target"
    rtk ./scripts/record-decision.sh \
      --type AUTO_REMOVE_UNTRACKED \
      --phase SCOPE_REMEDIATION \
      --trigger file_map_violation \
      --evidence "$violation" \
      --action "rm -rf -- $target" \
      --prediction "File-map check will pass after removing the untracked file." \
      --result removed \
      --requires-human-review false \
      --file "$target"
    result="removed"
    ;;
  scope-request)
    rtk ./scripts/record-decision.sh \
      --type SCOPE_EXPANSION_REQUEST \
      --phase SCOPE_REMEDIATION \
      --trigger file_map_violation \
      --evidence "$violation" \
      --action "request human-approved scope expansion for $target" \
      --prediction "Human approval is required before widening the file map." \
      --result scope_request_recorded \
      --requires-human-review true \
      --file "$target"
    result="scope_request_recorded"
    ;;
  *)
    fail "Unknown action '$action' (expected revert|remove-untracked|scope-request)"
    ;;
esac

echo "File-map violation resolution recorded: $result $target"
