#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

report_dir="${HARNESS_REPORT_DIR:-$HARNESS_DOCS_DIR/reports}"
score_report="${HARNESS_SCORE_REPORT:-$report_dir/harness-quality-score.md}"
min_score="${HARNESS_MIN_SCORE:-90}"
template_mode="${HARNESS_TEMPLATE_MODE:-false}"

mkdir -p "$report_dir"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

if [ "$template_mode" != "true" ] && ! has_active_plan; then
  fail "Missing active plan; set HARNESS_TEMPLATE_MODE=true to score the clean template"
fi

task_id="clean-template"
if has_active_plan && [ "$template_mode" != "true" ]; then
  task_id="$(fm_value "$PLAN_PATH" "task_id")"
fi

total_score=0
result="pass"
failed_checks=()
categories=()

add_category() {
  local label="$1"
  local score="$2"
  local max="$3"
  categories+=("$label|$score|$max")
  total_score=$((total_score + score))
}

run_category() {
  local label="$1"
  local max="$2"
  shift 2
  if "$@"; then
    add_category "$label" "$max" "$max"
  else
    add_category "$label" 0 "$max"
    failed_checks+=("$label")
    result="fail"
  fi
}

score_clean_template() {
  local export_root="$tmp/export"
  local zip_path="$tmp/template.zip"
  local export_args=(--output "$export_root" --zip "$zip_path")
  if [ "$template_mode" = "true" ]; then
    export_args=(--allow-no-git "${export_args[@]}")
  fi
  bash "$HARNESS_SCRIPTS_DIR/export-harness-package.sh" "${export_args[@]}" >/dev/null
  bash "$HARNESS_SCRIPTS_DIR/check-package-integrity.sh" --root "$export_root" >/dev/null
}

score_script_interface() {
  bash "$HARNESS_SCRIPTS_DIR/check-script-interface.sh" >/dev/null
}

score_regressions() {
  # Runtime readiness smoke suite. The full test suite can still be run with
  # `bash .agent-harness/harness.sh test`, but score/release gates should be
  # bounded and deterministic.
  if [ "$template_mode" = "true" ]; then
    local export_root="$tmp/export"
    (
      cd "$export_root/.agent-harness"
      bash tests/harness/test_baseline_contract.sh >/dev/null
      bash tests/harness/test_classify_repo_greenfield.sh >/dev/null
      bash tests/harness/test_classify_repo_brownfield.sh >/dev/null
      bash tests/harness/test_classify_repo_hybrid.sh >/dev/null
    )
  else
    (
      cd "$HARNESS_ROOT"
      bash tests/harness/test_baseline_contract.sh >/dev/null
      bash tests/harness/test_classify_repo_greenfield.sh >/dev/null
      bash tests/harness/test_classify_repo_brownfield.sh >/dev/null
      bash tests/harness/test_classify_repo_hybrid.sh >/dev/null
    )
  fi
}

score_repo_intelligence() {
  # Deterministic repo-intelligence readiness check for package scoring.
  [ -x "$HARNESS_SCRIPTS_DIR/repository-intelligence.sh" ] || return 1
  grep -q 'classify)' "$HARNESS_SCRIPTS_DIR/repository-intelligence.sh" || return 1
  [ -d "$HARNESS_TESTS_DIR/fixtures/repo-modes/greenfield" ] || return 1
  [ -d "$HARNESS_TESTS_DIR/fixtures/repo-modes/brownfield" ] || return 1
  [ -d "$HARNESS_TESTS_DIR/fixtures/repo-modes/hybrid" ] || return 1
}

score_active_plan_contract() {
  bash "$HARNESS_SCRIPTS_DIR/check-active-plan-contract.sh" >/dev/null
}

score_baseline_control() {
  bash "$HARNESS_SCRIPTS_DIR/check-baseline-contract.sh" >/dev/null
  bash "$HARNESS_SCRIPTS_DIR/check-change-baseline.sh" >/dev/null
  bash "$HARNESS_SCRIPTS_DIR/check-behavior-baseline.sh" >/dev/null
}

score_work_alignment() {
  bash "$HARNESS_SCRIPTS_DIR/check-work-alignment.sh" >/dev/null
}

score_context_pack() {
  bash "$HARNESS_SCRIPTS_DIR/check-context-pack.sh" >/dev/null
}

score_context_quality() {
  bash "$HARNESS_SCRIPTS_DIR/check-context-budget.sh" >/dev/null
}

score_adr_enforcement() {
  bash "$HARNESS_SCRIPTS_DIR/check-adr-awareness.sh" >/dev/null
  bash "$HARNESS_SCRIPTS_DIR/check-context-adr-exact-match.sh" >/dev/null
}

score_verification_routing() {
  bash "$HARNESS_SCRIPTS_DIR/check-test-contract.sh" >/dev/null
}

if [ "$template_mode" = "true" ]; then
  run_category "Exported template cleanliness" 35 score_clean_template
  run_category "Script interface" 15 score_script_interface
  run_category "Harness regressions" 30 score_regressions
  run_category "Repo Intelligence" 20 score_repo_intelligence
else
  run_category "Clean template" 15 score_clean_template
  run_category "Active plan contract" 10 score_active_plan_contract
  run_category "Epic/story/task alignment" 10 score_work_alignment
  run_category "Repo intelligence" 15 score_repo_intelligence
  run_category "Baseline control" 15 score_baseline_control
  run_category "Context quality" 15 score_context_quality
  run_category "ADR enforcement" 10 score_adr_enforcement
  run_category "Regression tests" 10 score_regressions
fi

if [ "$total_score" -lt "$min_score" ]; then
  result="fail"
fi

{
  echo "# Harness Quality Score"
  echo
  echo "task_id: $task_id"
  echo "generated_at: $(date '+%Y-%m-%d %H:%M')"
  echo "threshold: $min_score"
  echo "total_score: $total_score"
  echo "result: $result"
  echo
  echo "## Breakdown"
  echo
  echo "| Category | Score | Max |"
  echo "|---|---:|---:|"
  for row in "${categories[@]}"; do
    IFS='|' read -r label score max <<< "$row"
    echo "| $label | $score | $max |"
  done
  echo
  echo "## Failed Checks"
  echo
  if [ "${#failed_checks[@]}" -eq 0 ]; then
    echo "- none"
  else
    printf '%s\n' "${failed_checks[@]}" | sed 's/^/- /'
  fi
  echo
  echo "## Release Decision"
  echo
  if [ "$result" = "pass" ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
} > "$score_report"

if [ "$result" != "pass" ]; then
  fail "Harness quality score did not meet threshold: $total_score < $min_score"
fi

echo "Harness quality score passed."
