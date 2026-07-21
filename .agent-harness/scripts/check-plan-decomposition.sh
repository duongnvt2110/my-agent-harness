#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

require_heading() {
  local heading="$1"
  grep -qx "$heading" "$PLAN_PATH" || fail "Missing required heading '$heading' in $PLAN_PATH"
}

require_pattern() {
  local pattern="$1"
  grep -Eq "$pattern" "$PLAN_PATH" || fail "Missing required plan content matching '$pattern' in $PLAN_PATH"
}

require_heading "## Feature Intake"
require_heading "## Epic / Story / Task Breakdown"
require_pattern '^### Problem$'
require_pattern '^### Scope$'
require_pattern '^### Out of Scope$'
require_pattern '^### Success Criteria$'
require_pattern '^### Dependencies$'
require_pattern '^### Epic [0-9]+: '
require_pattern '^Dependencies:$'
require_pattern '^Acceptance Criteria:$'
require_pattern '^Stories:$'
require_pattern '^Tasks:$'

echo "Plan decomposition checks passed."
