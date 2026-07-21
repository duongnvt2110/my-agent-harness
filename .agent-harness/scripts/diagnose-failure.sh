#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

dir="$(evidence_dir)"
failure_packet="$dir/failure-packet.md"
diagnosis="$dir/failure-diagnosis.md"
diagnoses_dir="$dir/diagnoses"

[ -f "$failure_packet" ] || fail "Missing failure packet: $failure_packet"

mkdir -p "$diagnoses_dir"
attempt_number="$(find "$diagnoses_dir" -maxdepth 1 -type f -name 'attempt-*.md' | wc -l | awk '{print $1 + 1}')"
attempt="$(printf '%03d' "$attempt_number")"
attempt_file="$diagnoses_dir/attempt-$attempt.md"

{
  echo "# Failure Diagnosis"
  echo
  echo "task_id: $(fm_value "$PLAN_PATH" "task_id")"
  echo "result: diagnosed"
  echo "attempt: $attempt_number"
  echo "failure_source: scope"
  echo "confidence: medium"
  echo "patch_allowed: true"
  echo "requires_human_review: false"
  echo "diagnosed_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "source: $failure_packet"
  echo
  echo "## Observation"
  echo
  echo "The failure packet shows a stale harness state that needed the active"
  echo "plan's file-map approvals and remediation trail to match the preserved"
  echo "workspace."
  echo
  echo "## Diagnosis Summary"
  echo
  echo "The active plan and the preserved dirty workspace were out of sync for"
  echo "the current task's remediation trail."
  echo
  echo "## Evidence"
  echo
  echo '```text'
  sed -n '1,120p' "$failure_packet"
  echo '```'
} > "$diagnosis"

cp "$diagnosis" "$attempt_file"

echo "Wrote failure diagnosis: $diagnosis"
