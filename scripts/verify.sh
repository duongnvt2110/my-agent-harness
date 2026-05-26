#!/usr/bin/env bash
set -uo pipefail

source scripts/harness-lib.sh

run_gate() {
  local id="$1"
  shift
  local tmp exit_code
  tmp="$(mktemp)"
  echo "Running gate: $id"
  "$@" > "$tmp" 2>&1
  exit_code=$?
  cat "$tmp"
  if [ "$exit_code" -ne 0 ]; then
    if [ -f "$PLAN_PATH" ]; then
      set_fm_value "$PLAN_PATH" "status" "VERIFICATION_FAILED"
      set_fm_value "$PLAN_PATH" "lifecycle_phase" "EXECUTE"
      write_failure_packet "$id" "$*" "$exit_code" "$tmp"
    fi
    rm -f "$tmp"
    exit "$exit_code"
  fi
  rm -f "$tmp"
}

echo "Running harness verification..."

run_gate active-plan ./scripts/check-active-plan.sh
run_gate active-plan-contract ./scripts/check-active-plan-contract.sh
run_gate plan-alignment ./scripts/check-plan-alignment.sh
run_gate file-map ./scripts/check-file-map.sh
run_gate test-contract ./scripts/check-test-contract.sh
run_gate required-checks ./scripts/run-required-checks.sh
run_gate test-matrix ./scripts/check-test-matrix.sh
run_gate evidence ./scripts/check-evidence.sh
run_gate reviews ./scripts/check-reviews.sh

pass_file="$(evidence_dir)/verification-pass.md"
mkdir -p "$(dirname "$pass_file")"
{
  echo "# Verification Pass"
  echo
  echo "task_id: $(fm_value "$PLAN_PATH" "task_id")"
  echo "active_plan: $PLAN_PATH"
  echo "result: pass"
  echo "verified_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo
  echo "## Gates"
  echo
  echo "- active-plan"
  echo "- active-plan-contract"
  echo "- plan-alignment"
  echo "- file-map"
  echo "- test-contract"
  echo "- required-checks"
  echo "- test-matrix"
  echo "- evidence"
  echo "- reviews"
} > "$pass_file"

set_fm_value "$PLAN_PATH" "status" "VERIFIED"
set_fm_value "$PLAN_PATH" "lifecycle_phase" "FINALIZE"

echo "Harness verification passed."
