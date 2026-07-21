#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

if [ "${1:-}" = "review" ]; then
  plan="${2:-}"
  review="${3:-}"
  verification="${4:-}"
  [ -f "$plan" ] && [ -f "$review" ] && [ -f "$verification" ] || fail "Usage: scripts/check-finalization-authority.sh review PLAN REVIEW.md VERIFICATION.md"
  python3 - "$plan" "$review" "$verification" <<'PY'
import pathlib
import re
import sys

plan, review, verification = [pathlib.Path(value).read_text() for value in sys.argv[1:]]
def value(text, key):
    match = re.search(rf"^(?:-\s+)?{re.escape(key)}:\s*(.+)$", text, re.MULTILINE)
    return match.group(1).strip().strip('"') if match else ""
task_id = value(plan, "task_id")
if value(review, "task_id") != task_id:
    raise SystemExit("final review task binding mismatch")
if not value(review, "reviewer"):
    raise SystemExit("final review reviewer identity is missing")
if value(review, "reviewer").lower().startswith(("codex", "agent", "verifier", "oracle")):
    raise SystemExit("final review must be human-owned")
if not value(review, "reviewed_at"):
    raise SystemExit("final review timestamp is missing")
if value(review, "result") != "PASS" or value(review, "blocker_findings") != "0" or value(review, "blocks_completion") != "false":
    raise SystemExit("final review does not approve completion")
if value(verification, "result") != "pass":
    raise SystemExit("final review requires a passing verification artifact")
print(f"final_review: valid task_id={task_id}")
PY
  exit 0
fi

approval="${1:-}"
state="${2:-}"
evidence="${3:-}"
[ -f "$approval" ] && [ -f "$state" ] && [ -f "$evidence" ] || fail "Usage: scripts/check-finalization-authority.sh APPROVAL.json STATE.json EVIDENCE.json"

python3 - "$approval" "$state" "$evidence" "$script_dir" <<'PY'
import datetime as dt
import hashlib
import json
import pathlib
import sys

approval_path, state_path, evidence_path, script_dir = map(pathlib.Path, sys.argv[1:])
approval = json.loads(approval_path.read_text())
state = json.loads(state_path.read_text())
required = ("approved", "human_id", "approved_at", "reason", "single_use", "task_id", "run_id", "spec_hash", "policy_hash", "snapshot_hash", "evidence_hash", "authority_status", "issuer_mac")
missing = [key for key in required if not approval.get(key)]
if missing:
    raise SystemExit("final approval missing: " + ",".join(missing))
if approval.get("approved") is not True or approval.get("single_use") is not True:
    raise SystemExit("final approval must be approved and single-use")
if approval.get("authority_status") != "PROTECTED":
    raise SystemExit("final approval requires protected authority provenance")
for key in ("task_id", "run_id", "spec_hash", "policy_hash", "snapshot_hash"):
    if approval.get(key) != state.get(key):
        raise SystemExit(f"final approval context mismatch: {key}")
if approval.get("evidence_hash") != hashlib.sha256(evidence_path.read_bytes()).hexdigest():
    raise SystemExit("final approval evidence hash mismatch")
try:
    approved_at = dt.datetime.fromisoformat(str(approval["approved_at"]).replace("Z", "+00:00"))
except ValueError as exc:
    raise SystemExit("final approval timestamp must be ISO-8601") from exc
if approved_at.tzinfo is None:
    raise SystemExit("final approval timestamp must include timezone")
if approved_at > dt.datetime.now(dt.timezone.utc) + dt.timedelta(minutes=5):
    raise SystemExit("final approval timestamp is in the future")
sys.path.insert(0, str(script_dir))
from provenance import verify
if not verify(approval):
    raise SystemExit("final approval provenance is invalid")
print(json.dumps({"valid": True, "task_id": state["task_id"], "run_id": state["run_id"]}, sort_keys=True))
PY
