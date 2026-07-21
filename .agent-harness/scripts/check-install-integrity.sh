#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

root="."
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root)
      root="${2:-}"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--root <dir>]" >&2
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[ -n "$root" ] || fail "Missing --root"

[ -d "$root/.agent-harness/scripts" ] || fail "Missing harness scripts directory: $root/.agent-harness/scripts"
[ -d "$root/.agent-harness/docs" ] || fail "Missing harness docs directory: $root/.agent-harness/docs"
[ -d "$root/.agent-harness/tests" ] || fail "Missing harness tests directory: $root/.agent-harness/tests"
[ -d "$root/.agent-harness/benchmarks" ] || fail "Missing harness benchmarks directory: $root/.agent-harness/benchmarks"
[ -d "$root/.agent-harness/runtime" ] || fail "Missing harness runtime directory: $root/.agent-harness/runtime"
[ -d "$root/.agent-harness/policies" ] || fail "Missing harness policies directory: $root/.agent-harness/policies"
[ -d "$root/.agent-harness/recipes" ] || fail "Missing harness recipes directory: $root/.agent-harness/recipes"
[ -f "$root/.agent-harness/runtime/v3-workflow.json" ] || fail "Missing v3 workflow metadata: $root/.agent-harness/runtime/v3-workflow.json"
[ -f "$root/.agent-harness/runtime/state.json" ] || fail "Missing canonical runtime state: $root/.agent-harness/runtime/state.json"
[ -f "$root/.agent-harness/runtime/events.jsonl" ] || fail "Missing runtime event chain: $root/.agent-harness/runtime/events.jsonl"
[ -f "$root/.agent-harness/runtime/current.md" ] || fail "Missing generated runtime projection: $root/.agent-harness/runtime/current.md"
[ -f "$root/.agent-harness/policies/state-schema-v1.json" ] || fail "Missing state schema policy: $root/.agent-harness/policies/state-schema-v1.json"
[ -f "$root/.agent-harness/policies/v3-contract.json" ] || fail "Missing v3 contract registry: $root/.agent-harness/policies/v3-contract.json"
[ -f "$root/.agent-harness/benchmarks/result-schema.json" ] || fail "Missing benchmark result schema: $root/.agent-harness/benchmarks/result-schema.json"
[ -d "$root/.agent-harness/benchmarks/project-build" ] || fail "Missing project-build benchmark suite: $root/.agent-harness/benchmarks/project-build"
[ ! -e "$root/.agent-harness/core" ] || fail "Legacy core directory must not exist: $root/.agent-harness/core"
[ ! -e "$root/.agent-harness/state" ] || fail "Legacy state directory must not exist: $root/.agent-harness/state"
[ ! -e "$root/.agent-harness/config" ] || fail "Legacy config directory must not exist: $root/.agent-harness/config"
[ -f "$root/.agent-harness/harness.sh" ] || fail "Missing public harness wrapper: $root/.agent-harness/harness.sh"
[ -x "$root/.agent-harness/harness.sh" ] || fail "Public harness wrapper is not executable: $root/.agent-harness/harness.sh"
[ -f "$root/.agent-harness/scripts/harness.sh" ] || fail "Missing internal harness dispatcher: $root/.agent-harness/scripts/harness.sh"
[ -f "$root/.agent-harness/docs/exec-plans/TEMPLATE.md" ] || fail "Missing exec-plan template: $root/.agent-harness/docs/exec-plans/TEMPLATE.md"
[ -f "$root/.agent-harness/docs/exec-plans/active/.gitkeep" ] || fail "Missing active plan placeholder: $root/.agent-harness/docs/exec-plans/active/.gitkeep"
[ -f "$root/.agent-harness/docs/exec-plans/completed/.gitkeep" ] || fail "Missing completed plan placeholder: $root/.agent-harness/docs/exec-plans/completed/.gitkeep"
[ -f "$root/.agent-harness/docs/tasks/tasks.jsonl" ] || fail "Missing task store: $root/.agent-harness/docs/tasks/tasks.jsonl"

for block_file in "$root/AGENTS.md" "$root/README.md" "$root/WORKFLOW.md" "$root/CONTEXT.md"; do
  [ -f "$block_file" ] || fail "Missing root markdown file: $block_file"
  grep -q '<!-- BEGIN AGENT-HARNESS -->' "$block_file" || fail "Missing managed block start in $block_file"
  grep -q '<!-- END AGENT-HARNESS -->' "$block_file" || fail "Missing managed block end in $block_file"
done

status_output="$(
  cd "$root"
  env -u HARNESS_ROOT -u HARNESS_REPO_ROOT -u HARNESS_SCRIPT_DIR -u HARNESS_SCRIPTS_DIR -u HARNESS_DOCS_DIR -u HARNESS_TESTS_DIR     bash .agent-harness/harness.sh status
)" || fail "Exported public harness status command failed"
grep -q '^workflow_version: v3$' <<<"$status_output" || fail "Public harness status did not report workflow_version v3"
grep -q '^HARNESS STATUS$' <<<"$status_output" || fail "Public harness status output is incomplete"

echo "Install integrity checks passed."
