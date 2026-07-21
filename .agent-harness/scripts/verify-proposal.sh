#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

proposal="${1:-}"
plan="${2:-${PLAN_PATH:-}}"
run_id="${3:-v4-verification-run}"
[ "$proposal" != "--workspace-hash" ] || {
  python3 - "$HARNESS_REPO_ROOT" <<'PY'
import hashlib
import os
import pathlib
import stat
import sys

root = pathlib.Path(sys.argv[1]).resolve()
excluded = {
    ".git",
    ".agent-harness/runtime",
    ".agent-harness/docs/evidence",
    ".agent-harness/docs/reports",
    ".agent-harness/benchmarks/history",
}

def ignored(relative):
    value = relative.as_posix()
    return any(value == item or value.startswith(item + "/") for item in excluded)

entries = []
for path in sorted(root.rglob("*")):
    relative = path.relative_to(root)
    if ignored(relative):
        continue
    try:
        info = path.lstat()
    except OSError:
        continue
    if stat.S_ISDIR(info.st_mode):
        continue
    if stat.S_ISLNK(info.st_mode):
        payload = os.readlink(path).encode()
        kind = "symlink"
    elif stat.S_ISREG(info.st_mode):
        payload = path.read_bytes()
        kind = "file"
    else:
        continue
    digest = hashlib.sha256(payload).hexdigest()
    entries.append(f"{kind}\t{relative.as_posix()}\t{info.st_mode & 0o7777:o}\t{len(payload)}\t{digest}")
print(hashlib.sha256(("\\n".join(entries) + "\\n").encode()).hexdigest())
PY
  exit 0
}
[ -f "$proposal" ] || fail "Usage: $0 PROPOSAL.json [PLAN.md] [RUN_ID]"
[ -f "$plan" ] || fail "Missing verification plan: $plan"

hash_file() {
  python3 - "$1" <<'PY'
import hashlib, pathlib, sys
print(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest())
PY
}

workspace_hash() {
  "$script_dir/verify-proposal.sh" --workspace-hash
}

plan_hash="$(hash_file "$plan")"
current_workspace_hash="$(workspace_hash)"
proposal_plan_hash="$(python3 - "$proposal" <<'PY'
import json, pathlib, sys
print(json.loads(pathlib.Path(sys.argv[1]).read_text()).get("plan_hash", ""))
PY
)"
proposal_workspace_hash="$(python3 - "$proposal" <<'PY'
import json, pathlib, sys
print(json.loads(pathlib.Path(sys.argv[1]).read_text()).get("workspace_hash", ""))
PY
)"

check_results="[]"
checks_ok=true
while IFS=$'\t' read -r check_id _ command blocking; do
  [ -n "$check_id" ] || continue
  set +e
  output="$(cd "$HARNESS_REPO_ROOT" && bash -lc "$command" 2>&1)"
  code=$?
  set -e
  check_results="$(python3 - "$check_results" "$check_id" "$command" "$code" "$output" <<'PY'
import json, sys
rows = json.loads(sys.argv[1])
rows.append({"id": sys.argv[2], "command": sys.argv[3], "exit_code": int(sys.argv[4]), "output": sys.argv[5]})
print(json.dumps(rows, sort_keys=True))
PY
)"
  if [ "$code" -ne 0 ] && [ "$blocking" != "false" ]; then
    checks_ok=false
  fi
done < <(required_check_rows "$plan")

python3 - "$proposal" "$plan_hash" "$current_workspace_hash" "$proposal_plan_hash" "$proposal_workspace_hash" "$checks_ok" "$check_results" "$run_id" <<'PY'
import hashlib, json, pathlib, sys, uuid
proposal_path = pathlib.Path(sys.argv[1])
proposal = json.loads(proposal_path.read_text())
plan_hash, workspace_hash, proposed_plan, proposed_workspace, checks_ok, checks, run_id = sys.argv[2:]
errors = []
if proposed_plan != plan_hash:
    errors.append("plan hash mismatch")
if proposed_workspace != workspace_hash:
    errors.append("workspace hash mismatch")
if checks_ok != "true":
    errors.append("required check failed")
verdict = "PASSED" if not errors else "FAILED"
result = {
    "schema_version": 1,
    "verdict": verdict,
    "accepted_for_finalization": verdict == "PASSED",
    "authority": "HARNESS_VERIFICATION",
    "verification_function": "harness_verification",
    "verification_id": str(uuid.uuid4()),
    "agent_session_id": proposal.get("agent_session_id", "agent-proposal"),
    "task_id": proposal.get("task_id", "unknown"),
    "plan_hash": plan_hash,
    "workspace_hash": workspace_hash,
    "artifact_hash": hashlib.sha256(proposal_path.read_bytes()).hexdigest(),
    "run_id": run_id,
    "checks": json.loads(checks),
    "errors": errors,
}
print(json.dumps(result, indent=2, sort_keys=True))
raise SystemExit(0 if verdict == "PASSED" else 1)
PY
