#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

verdict="${1:-}"
plan="${2:-${PLAN_PATH:-}}"
[ -f "$verdict" ] && [ -f "$plan" ] || fail "Usage: $0 VERDICT.json PLAN.md"

current_workspace_hash="$($script_dir/verify-proposal.sh --workspace-hash)"

python3 - "$verdict" "$plan" "$current_workspace_hash" <<'PY'
import hashlib
import json
import pathlib
import sys

verdict_path = pathlib.Path(sys.argv[1])
plan_path = pathlib.Path(sys.argv[2])
current_workspace_hash = sys.argv[3]
data = json.loads(verdict_path.read_text())
errors = []
if data.get("authority") != "HARNESS_VERIFICATION":
    errors.append("verdict is not harness-authored")
if data.get("verification_function") != "harness_verification":
    errors.append("verification function is not harness_verification")
if data.get("verdict") != "PASSED" or data.get("accepted_for_finalization") is not True:
    errors.append("v4 verification did not pass")
if data.get("plan_hash") != hashlib.sha256(plan_path.read_bytes()).hexdigest():
    errors.append("plan hash mismatch")
if data.get("workspace_hash") != current_workspace_hash:
    errors.append("workspace hash mismatch")
if not data.get("verification_id") or data.get("verification_id") == data.get("agent_session_id"):
    errors.append("verification identity is missing or agent-owned")
if errors:
    for error in errors:
        print(error, file=sys.stderr)
    raise SystemExit(1)
print("v4 verification authority check passed")
PY
