#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

report_dir="${HARNESS_REPORT_DIR:-$HARNESS_DOCS_DIR/reports}"
release_report="${HARNESS_RELEASE_REPORT:-$report_dir/release-check.md}"
release_threshold="${HARNESS_RELEASE_MIN_SCORE:-90}"
score_report="$report_dir/harness-quality-score.md"
report_dir="$(python3 - "$report_dir" <<'PY'
import os
import sys
print(os.path.abspath(sys.argv[1]))
PY
)"

mkdir -p "$report_dir"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

install_root="$tmp/installed"

bash "$HARNESS_SCRIPTS_DIR/install-harness.sh" --allow-no-git --target "$install_root" >/dev/null
bash "$HARNESS_SCRIPTS_DIR/release-invariants.sh" >/dev/null

if has_active_plan; then
  bash "$HARNESS_SCRIPTS_DIR/check-context-budget.sh" >/dev/null
fi

(
  cd "$install_root/.agent-harness"
  env -u HARNESS_ROOT -u HARNESS_REPO_ROOT -u HARNESS_SCRIPT_DIR -u HARNESS_SCRIPTS_DIR -u HARNESS_DOCS_DIR -u HARNESS_TESTS_DIR bash tests/harness/test_baseline_contract.sh >/dev/null
  env -u HARNESS_ROOT -u HARNESS_REPO_ROOT -u HARNESS_SCRIPT_DIR -u HARNESS_SCRIPTS_DIR -u HARNESS_DOCS_DIR -u HARNESS_TESTS_DIR bash tests/harness/test_classify_repo_greenfield.sh >/dev/null
  env -u HARNESS_ROOT -u HARNESS_REPO_ROOT -u HARNESS_SCRIPT_DIR -u HARNESS_SCRIPTS_DIR -u HARNESS_DOCS_DIR -u HARNESS_TESTS_DIR bash tests/harness/test_classify_repo_brownfield.sh >/dev/null
  env -u HARNESS_ROOT -u HARNESS_REPO_ROOT -u HARNESS_SCRIPT_DIR -u HARNESS_SCRIPTS_DIR -u HARNESS_DOCS_DIR -u HARNESS_TESTS_DIR bash tests/harness/test_classify_repo_hybrid.sh >/dev/null
)

cat > "$score_report" <<SCORE_EOF
# Harness Quality Score

task_id: clean-template
generated_at: $(date '+%Y-%m-%d %H:%M')
blocking_invariants: all
result: pass

## Breakdown

| Category | Score | Max |
|---|---:|---:|
| Release-blocking invariants | PASS | PASS |

## Failed Checks

- none

## Release Decision

PASS
SCORE_EOF

cleanup_runtime_state() {
  local root="$1"
  rm -f "$root/.agent-harness/docs/exec-plans/active/current.md"
  find "$root/.agent-harness/docs/exec-plans/completed" -maxdepth 1 -type f -name '*.md' ! -name '.gitkeep' -delete 2>/dev/null || true
  find "$root/.agent-harness/docs/evidence" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} + 2>/dev/null || true
  find "$root/.agent-harness/docs/reviews" -maxdepth 1 -type f -name '*.md' ! -name 'TEMPLATE.md' -delete 2>/dev/null || true
  : > "$root/.agent-harness/docs/tasks/tasks.jsonl"
}

cleanup_runtime_state "$install_root"

bash "$HARNESS_SCRIPTS_DIR/check-install-integrity.sh" --root "$install_root" >/dev/null
bash "$HARNESS_SCRIPTS_DIR/check-script-interface.sh" >/dev/null

task_id="clean-template"

{
  echo "# Harness Release Check"
  echo
  echo "task_id: $task_id"
  echo "generated_at: $(date '+%Y-%m-%d %H:%M')"
  echo "release_threshold: $release_threshold"
  echo "blocking_invariants: all"
  echo "result: pass"
  echo
  echo "## Result"
  echo
  echo "Release gate passed."
  echo
  echo "## Score Report"
  echo
  echo "- $score_report"
} > "$release_report"

echo "Release gate passed."
