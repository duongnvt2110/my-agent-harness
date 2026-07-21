#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
task_id="v4_slice_2_deterministic_context_compiler"
tmp_dir="$(mktemp -d)"
plan="$tmp_dir/plan.md"
manifest="$repo_root/.agent-harness/docs/evidence/$task_id/context-manifest.json"
tmp="$(mktemp)"
trap 'rm -rf "$tmp_dir"; rm -f "$tmp"' EXIT

cat > "$plan" <<'EOF'
---
task_id: v4_slice_2_deterministic_context_compiler
title: "Context compiler fixture"
status: IN_PROGRESS
lifecycle_phase: EXECUTE
lane: tiny
repo_mode: brownfield
task_change_type: extend_existing
task_touches_existing_behavior: true
task_backward_compatibility_required: true
review_required: false
verification_mode: required_checks
max_context_tokens: 5000
parent_epic_id: null
parent_story_id: null
required_checks:
  - id: fixture-check
    type: automated
    command: true
    blocking: true
    timeout_seconds: 30
    evidence: fixture-check.md
acceptance_criteria:
  - Context compiler remains deterministic
---
# Context compiler fixture
EOF

PLAN_PATH="$plan" "$repo_root/.agent-harness/scripts/context.sh" pack --task "$task_id" --budget 5000 >/dev/null
cp "$manifest" "$tmp"
PLAN_PATH="$plan" "$repo_root/.agent-harness/scripts/context.sh" pack --task "$task_id" --budget 5000 >/dev/null
cmp -s "$tmp" "$manifest" || {
  echo "Context manifest is not reproducible" >&2
  diff -u "$tmp" "$manifest" >&2 || true
  exit 1
}

python3 - "$manifest" <<'PY'
import json
import pathlib
import sys

manifest = json.loads(pathlib.Path(sys.argv[1]).read_text())
assert manifest["status"] == "generated", manifest
assert manifest["compiler_version"] == "v4-context-compiler-1", manifest
assert manifest["within_budget"], manifest
assert manifest["estimated_tokens"] <= manifest["budget"], manifest
assert manifest["sources"], manifest
assert all(item["sha256"] and item["selection_reason"] for item in manifest["sources"]), manifest
assert all(item["reason"] for item in manifest["omissions"]), manifest
PY

PLAN_PATH="$plan" "$repo_root/.agent-harness/scripts/check-context-pack.sh" >/dev/null
PLAN_PATH="$plan" "$repo_root/.agent-harness/scripts/check-context-budget.sh" >/dev/null

echo "v4 Slice 2 deterministic context compiler regression passed."
