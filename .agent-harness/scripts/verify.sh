#!/usr/bin/env bash
set -uo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

run_gate() {
  local id="$1"
  local failure_phase="EXECUTE"
  case "${2:-}" in
    PLAN|EXECUTE|VERIFY|REVIEW|FINALIZE|BLOCKED|COMPLETED|SCOPE_REMEDIATION|DIAGNOSE|REPAIR_PLAN|PATCH)
      failure_phase="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
  local tmp exit_code
  tmp="$(mktemp)"
  echo "Running gate: $id"
  "$@" > "$tmp" 2>&1
  exit_code=$?
  cat "$tmp"
  if [ "$exit_code" -ne 0 ]; then
    if [ -f "$PLAN_PATH" ]; then
      if [ "$failure_phase" = "PLAN" ] && [ "$(fm_value "$PLAN_PATH" "implementation_allowed")" = "true" ]; then
        failure_phase="DIAGNOSE"
      fi
      set_fm_value "$PLAN_PATH" "status" "VERIFICATION_FAILED"
      set_fm_value "$PLAN_PATH" "lifecycle_phase" "$failure_phase"
      write_failure_packet "$id" "$*" "$exit_code" "$tmp"
    fi
    rm -f "$tmp"
    exit "$exit_code"
  fi
  rm -f "$tmp"
}

echo "Running harness verification..."
verification_profile="${HARNESS_VERIFY_PROFILE:-full}"
case "$verification_profile" in
  targeted|full) ;;
  *) echo "Unsupported verification profile: $verification_profile" >&2; exit 2 ;;
esac
rm -f "$(evidence_dir)/failure-packet.md"

run_gate active-plan-contract PLAN ./scripts/check-active-plan-contract.sh
run_gate baseline-contract PLAN ./scripts/check-baseline-contract.sh
run_gate change-baseline PLAN ./scripts/check-change-baseline.sh
run_gate behavior-baseline PLAN ./scripts/check-behavior-baseline.sh
if [ "$(fm_value "$PLAN_PATH" "spec_clarification_required")" = "true" ]; then
  run_gate spec-clarification PLAN ./scripts/check-spec-clarification.sh --check-only
fi
if [ "$(fm_value "$PLAN_PATH" "epic_context_required")" = "true" ]; then
  run_gate full-context PLAN ./scripts/check-full-context.sh
fi
if [ "$(fm_value "$PLAN_PATH" "work_alignment_required")" = "true" ]; then
  run_gate work-alignment PLAN ./scripts/check-work-alignment.sh
fi
if [ "$(fm_value "$PLAN_PATH" "adr_check_required")" = "true" ] && [ -x ./scripts/check-adr-awareness.sh ]; then
  run_gate adr-awareness PLAN ./scripts/check-adr-awareness.sh
fi
if [ "$(fm_value "$PLAN_PATH" "context_pack_required")" = "true" ] && [ -x ./scripts/check-context-pack.sh ]; then
  run_gate context-pack PLAN ./scripts/check-context-pack.sh
fi
if [ "$(fm_value "$PLAN_PATH" "context_pack_required")" = "true" ]; then
  run_gate context-budget PLAN ./scripts/check-context-budget.sh
fi
if [ -x ./scripts/check-v3-contract-coverage.sh ]; then
  run_gate v3-contract-coverage PLAN ./scripts/check-v3-contract-coverage.sh
fi
if [ "$(fm_value "$PLAN_PATH" "environment_setup_required")" = "true" ] && [ -x ./scripts/setup-env.sh ]; then
  run_gate setup-env PLAN ./scripts/setup-env.sh
fi
run_gate file-map SCOPE_REMEDIATION ./scripts/check-file-map.sh
run_gate test-contract PLAN ./scripts/check-test-contract.sh
run_gate required-checks DIAGNOSE ./scripts/run-required-checks.sh
if [ -x ./scripts/generate-test-report.sh ]; then
  run_gate test-report VERIFY ./scripts/generate-test-report.sh
  if [ -x ./scripts/check-test-report.sh ]; then
    run_gate test-report-contract VERIFY ./scripts/check-test-report.sh
  fi
fi
if [ -x ./scripts/check-remediation-trace.sh ] && [ -f "$(evidence_dir)/failure-packet.md" ]; then
  run_gate remediation-trace VERIFY ./scripts/check-remediation-trace.sh
fi
run_gate evidence VERIFY ./scripts/check-evidence.sh
pass_file="$(evidence_dir)/verification-pass.md"
mkdir -p "$(dirname "$pass_file")"
warnings="$(mktemp)"
while IFS=$'\t' read -r id type command blocking timeout_seconds evidence allow_raw raw_reason reason; do
  [ -n "$id" ] || continue
  [ "$blocking" = "false" ] || continue
  [ -f "$evidence" ] || continue
  result="$(awk -F: '/^result:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' "$evidence")"
  if [ "$result" != "pass" ]; then
    echo "- $id: $result ($evidence)" >> "$warnings"
  fi
done < <(required_check_rows "$PLAN_PATH")

{
  echo "# Verification Pass"
  echo
  echo "task_id: $(fm_value "$PLAN_PATH" "task_id")"
  echo "active_plan: $PLAN_PATH"
  echo "verification_profile: $verification_profile"
  echo "result: pass"
  echo "verified_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo
  echo "## Gates"
  echo
  echo "- active-plan-contract"
  if [ "$(fm_value "$PLAN_PATH" "work_alignment_required")" = "true" ]; then
    echo "- work-alignment"
  fi
  echo "- file-map"
  if [ "$(fm_value "$PLAN_PATH" "environment_setup_required")" = "true" ] && [ -x ./scripts/setup-env.sh ]; then
    echo "- setup-env"
  fi
  echo "- test-contract"
  echo "- required-checks"
  if [ -x ./scripts/generate-test-report.sh ]; then
    echo "- test-report"
  fi
  if [ -x ./scripts/check-remediation-trace.sh ] && [ -f "$(evidence_dir)/failure-packet.md" ]; then
    echo "- remediation-trace"
  fi
  echo "- evidence"
  if [ -x ./scripts/check-v3-contract-coverage.sh ]; then
    echo "- v3-contract-coverage"
  fi
  if [ -s "$warnings" ]; then
    echo
    echo "## Non-Blocking Warnings"
    echo
    cat "$warnings"
  fi
} > "$pass_file"
rm -f "$warnings"

set_fm_value "$PLAN_PATH" "status" "VERIFIED"
if [ "$(fm_value "$PLAN_PATH" "review_required")" = "true" ]; then
  set_fm_value "$PLAN_PATH" "lifecycle_phase" "REVIEW"
else
  set_fm_value "$PLAN_PATH" "lifecycle_phase" "FINALIZE"
fi

echo "Harness verification passed."
