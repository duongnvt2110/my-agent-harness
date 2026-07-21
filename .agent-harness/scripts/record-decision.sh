#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

json_array() {
  local first=1
  local out="["
  local item
  for item in "$@"; do
    if [ "$first" -eq 0 ]; then
      out+=","
    fi
    out+="\"$(json_escape "$item")\""
    first=0
  done
  out+="]"
  printf '%s' "$out"
}

usage() {
  cat <<'EOF'
Usage:
  rtk ./scripts/record-decision.sh \
    --type <DECISION_TYPE> \
    --phase <LIFECYCLE_PHASE> \
    --trigger <TRIGGER> \
    --action <ACTION> \
    --result <RESULT> \
    [--prediction <PREDICTION>] \
    [--evidence <PATH>] \
    [--requires-human-review true|false] \
    [--file <PATH> ...]
EOF
}

decision_type=""
phase=""
trigger=""
action=""
prediction=""
result=""
evidence=""
requires_human_review=""
files=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --type)
      decision_type="${2:-}"
      shift 2
      ;;
    --phase)
      phase="${2:-}"
      shift 2
      ;;
    --trigger)
      trigger="${2:-}"
      shift 2
      ;;
    --action)
      action="${2:-}"
      shift 2
      ;;
    --prediction)
      prediction="${2:-}"
      shift 2
      ;;
    --result)
      result="${2:-}"
      shift 2
      ;;
    --evidence)
      evidence="${2:-}"
      shift 2
      ;;
    --requires-human-review)
      requires_human_review="${2:-}"
      shift 2
      ;;
    --file)
      files+=("${2:-}")
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      fail "Unknown flag: $1"
      ;;
  esac
done

[ -n "$decision_type" ] || fail "Missing --type"
[ -n "$phase" ] || phase="$(fm_value "$PLAN_PATH" "lifecycle_phase")"
[ -n "$trigger" ] || trigger="manual"
[ -n "$action" ] || action="recorded"
[ -n "$result" ] || result="pending"
[ -n "$requires_human_review" ] || requires_human_review="false"

case "$decision_type" in
  AUTO_REVERT|AUTO_REMOVE_UNTRACKED|SCOPE_EXPANSION_REQUEST|PATCH_SOURCE|PATCH_TEST|BLOCKED_DEPENDENCY_CHANGE|BLOCKED_ENVIRONMENT_CHANGE|BLOCKED_TEST_SKIP|BLOCKED_TIMEOUT_INCREASE|MARK_HUMAN_REVIEW_REQUIRED|NO_AUTONOMOUS_BOUNDARY_DECISIONS|OTHER_REQUIRES_REVIEW)
    ;;
  *)
    fail "Invalid decision type '$decision_type'"
    ;;
esac

case "$phase" in
  PLAN|EXECUTE|VERIFY|REVIEW|FINALIZE|BLOCKED|COMPLETED|SCOPE_REMEDIATION|DIAGNOSE|REPAIR_PLAN|PATCH)
    ;;
  *)
    fail "Invalid lifecycle phase '$phase'"
    ;;
esac

case "$requires_human_review" in
  true|false) ;;
  *) fail "--requires-human-review must be true or false" ;;
esac

if [ "$decision_type" != "NO_AUTONOMOUS_BOUNDARY_DECISIONS" ]; then
  [ -n "$evidence" ] || fail "Missing --evidence for decision type '$decision_type'"
fi

if [ "${#files[@]}" -eq 0 ]; then
  case "$decision_type" in
    AUTO_REVERT|AUTO_REMOVE_UNTRACKED|SCOPE_EXPANSION_REQUEST|PATCH_SOURCE|PATCH_TEST)
      fail "Decision type '$decision_type' requires at least one --file"
      ;;
  esac
fi

case "$decision_type" in
  SCOPE_EXPANSION_REQUEST|BLOCKED_DEPENDENCY_CHANGE|BLOCKED_ENVIRONMENT_CHANGE|BLOCKED_TEST_SKIP|BLOCKED_TIMEOUT_INCREASE|MARK_HUMAN_REVIEW_REQUIRED|OTHER_REQUIRES_REVIEW)
    requires_human_review="true"
    ;;
esac

dir="$(evidence_dir)"
ledger="$dir/decision-ledger.jsonl"
trace="$dir/decision-trace.md"
mkdir -p "$dir"

task_id="$(fm_value "$PLAN_PATH" "task_id")"
timestamp="$(date '+%Y-%m-%d %H:%M:%S %z')"
files_json="$(json_array "${files[@]}")"

if [ -n "$evidence" ]; then
  evidence_json="\"$(json_escape "$evidence")\""
else
  evidence_json="null"
fi

printf '{"task_id":"%s","recorded_at":"%s","phase":"%s","decision_type":"%s","trigger":"%s","action":"%s","prediction":"%s","result":"%s","requires_human_review":%s,"evidence":%s,"files_affected":%s}\n' \
  "$(json_escape "$task_id")" \
  "$(json_escape "$timestamp")" \
  "$(json_escape "$phase")" \
  "$(json_escape "$decision_type")" \
  "$(json_escape "$trigger")" \
  "$(json_escape "$action")" \
  "$(json_escape "$prediction")" \
  "$(json_escape "$result")" \
  "$requires_human_review" \
  "$evidence_json" \
  "$files_json" >> "$ledger"

{
  echo "# Decision Trace"
  echo
  echo "task_id: $task_id"
  echo "result: recorded"
  echo "updated_at: $timestamp"
  echo
  echo "## Decisions"
  echo
  awk '{ print "- " $0 }' "$ledger"
} > "$trace"

echo "Recorded decision: $ledger"
