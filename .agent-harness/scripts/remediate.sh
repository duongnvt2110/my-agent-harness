#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

dir="$(evidence_dir)"

[ -f "$dir/failure-packet.md" ] || fail "Missing failure packet: $dir/failure-packet.md"
[ -f "$dir/failure-diagnosis.md" ] || fail "Missing failure diagnosis: $dir/failure-diagnosis.md"
[ -f "$dir/repair-plan.md" ] || fail "Missing repair plan: $dir/repair-plan.md"

cat <<EOF
REMEDIATION PACKET

Task ID: $(fm_value "$PLAN_PATH" "task_id")
Active plan: $PLAN_PATH

Read first:
- $dir/failure-packet.md
- $dir/failure-diagnosis.md
- $dir/repair-plan.md

Allowed action:
- Patch only files allowed by the active plan.
- Record meaningful autonomous decisions with scripts/record-decision.sh.
- Run scripts/run-targeted-checks.sh before full verification.

Forbidden:
- Do not expand scope without human approval.
- Do not skip required checks.
EOF
