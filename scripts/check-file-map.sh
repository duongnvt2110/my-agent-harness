#!/usr/bin/env bash
set -euo pipefail

source scripts/harness-lib.sh

baseline_ref="$(fm_value "$PLAN_PATH" "baseline_ref")"
[ -n "$baseline_ref" ] && [ "$baseline_ref" != "null" ] || fail "Missing baseline_ref"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "File-map enforcement requires a Git repository"
git rev-parse --verify "$baseline_ref" >/dev/null 2>&1 || fail "baseline_ref is not a valid Git ref: $baseline_ref"

mapfile -t approved_files < <(fm_list "$PLAN_PATH" "approved_files")
mapfile -t approved_deletions < <(fm_list "$PLAN_PATH" "approved_deletions")
mapfile -t approved_scopes < <(fm_list "$PLAN_PATH" "approved_scopes")
mapfile -t scope_patterns_list < <(expand_scopes "${approved_scopes[@]}")

allowed_patterns=("${scope_patterns_list[@]}" "${approved_files[@]}")

while IFS=$'\t' read -r status path rest; do
  [ -n "${status:-}" ] || continue
  if [ "$status" = "D" ]; then
    matches_any_pattern "$path" "${allowed_patterns[@]}" \
      || matches_any_pattern "$path" "${approved_deletions[@]}" \
      || fail "Deleted file outside approved scopes/deletions: $path"
  else
    matches_any_pattern "$path" "${allowed_patterns[@]}" || fail "Changed file outside approved scope/files: $path"
  fi
done < <(git diff --name-status "$baseline_ref" --)

while IFS= read -r path; do
  [ -n "$path" ] || continue
  matches_any_pattern "$path" "${allowed_patterns[@]}" || fail "Untracked file outside approved scope/files: $path"
done < <(git ls-files --others --exclude-standard)

echo "File-map checks passed."
