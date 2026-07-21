#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths

usage() {
  cat >&2 <<'EOF'
Usage:
  scripts/agent-interface.sh assigned-task
  scripts/agent-interface.sh tools
  scripts/agent-interface.sh read-artifact <path> [--sha256 HASH]
  scripts/agent-interface.sh run-approved-check <check_id>
  scripts/agent-interface.sh run-check -- <command> [args...]
  scripts/agent-interface.sh submit-result <proposal|evidence> <file>
  scripts/agent-interface.sh report-blocked <file>
EOF
  exit 2
}

metadata="$HARNESS_ROOT/runtime/v3-workflow.json"
state="$HARNESS_ROOT/runtime/state.json"
repo_real="$(cd "$HARNESS_REPO_ROOT" && pwd -P)"
require_v3() {
  [ -f "$metadata" ] || fail "v3 workflow metadata is missing"
  [ -f "$state" ] || fail "v3 state is missing"
  python3 - "$metadata" "$state" <<'PY'
import json, pathlib, sys
meta = json.loads(pathlib.Path(sys.argv[1]).read_text())
state = json.loads(pathlib.Path(sys.argv[2]).read_text())
if meta.get("workflow_version") != "v3" or meta.get("implementation_version") != "v3-core":
    raise SystemExit("agent interface requires v3-core workflow")
if meta.get("mixed_artifacts") is True or meta.get("migration_required") is True:
    raise SystemExit("mixed or migration-required workflow is not authoritative")
if state.get("schema_version") != 1 or not state.get("active_function"):
    raise SystemExit("v3 state is missing active_function")
PY
}

assigned_task() {
  require_v3
  [ -f "$PLAN_PATH" ] || fail "no active task packet"
  python3 - "$PLAN_PATH" "$state" <<'PY'
import json, pathlib, re, sys
plan = pathlib.Path(sys.argv[1]).read_text()
state = json.loads(pathlib.Path(sys.argv[2]).read_text())
front = plan.split("---", 2)[1] if plan.startswith("---") else ""
def scalar(key):
    match = re.search(rf"^{re.escape(key)}:\s*(.+?)\s*$", front, re.M)
    return match.group(1).strip().strip('"') if match else ""
def items(key):
    match = re.search(rf"^{re.escape(key)}:\s*\n((?:\s+-\s+.*\n?)*)", front, re.M)
    if not match:
        return []
    return [line.strip()[2:].strip().strip('"') for line in match.group(1).splitlines() if line.strip().startswith("-")]
print(json.dumps({
    "schema_version": 1,
    "command": "assigned-task",
    "workflow_version": "v3",
    "task_id": scalar("task_id"),
    "run_id": state.get("run_id"),
    "state": state.get("state"),
    "active_function": state.get("active_function"),
    "approved_files": items("approved_files"),
    "required_checks": items("required_checks"),
    "authority": "observation_only"
}, sort_keys=True))
PY
}

read_artifact() {
  require_v3
  path="${1:-}"
  [ -n "$path" ] || usage
  shift || true
  expected=""
  if [ "${1:-}" = "--sha256" ]; then
    expected="${2:-}"
    [ -n "$expected" ] || usage
  fi
  if [[ "$path" = /* ]]; then candidate="$path"; else candidate="$repo_real/$path"; fi
  absolute="$(python3 - "$candidate" <<'PY'
import pathlib, sys
path = pathlib.Path(sys.argv[1])
print(path.resolve(strict=True) if path.exists() else "")
PY
)"
  [ -n "$absolute" ] || fail "artifact does not exist: $path"
  case "$absolute" in "$repo_real"/*) ;; *) fail "artifact is outside the repository" ;; esac
  [ -f "$absolute" ] || fail "artifact is not a regular file: $path"
  python3 - "$absolute" "$expected" <<'PY'
import base64, hashlib, json, mimetypes, pathlib, sys
path = pathlib.Path(sys.argv[1])
raw = path.read_bytes()
digest = hashlib.sha256(raw).hexdigest()
if sys.argv[2] and digest != sys.argv[2]:
    raise SystemExit("artifact hash mismatch")
content = None
try:
    content = raw.decode("utf-8")
except UnicodeDecodeError:
    pass
record = {"schema_version":1,"command":"read-artifact","path":str(path),"sha256":digest,"byte_length":len(raw),"media_type":mimetypes.guess_type(path.name)[0] or "application/octet-stream","authority":"observation_only"}
if content is not None:
    record["content"] = content
else:
    record["content_base64"] = base64.b64encode(raw).decode("ascii")
print(json.dumps(record, sort_keys=True))
PY
}

run_check() {
  require_v3
  [ "${1:-}" = "--" ] || usage
  shift
  [ "$#" -gt 0 ] || usage
  command_line="$*"
  allowed=false
  if [ "$command_line" = "true" ] || [ "$command_line" = "false" ]; then
    allowed=true
  fi
  while IFS=$'\t' read -r _ _ approved_command _; do
    [ -n "$approved_command" ] && [ "$command_line" = "$approved_command" ] && allowed=true
  done < <(required_check_rows "$PLAN_PATH")
  [ "$allowed" = true ] || fail "run-check command is not in the locked tool/check contract"
  set +e
  output="$(cd "$HARNESS_REPO_ROOT" && "$@" 2>&1)"
  code=$?
  set -e
  python3 - "$code" "$output" <<'PY'
import json, sys
print(json.dumps({"schema_version":1,"command":"run-check","exit_code":int(sys.argv[1]),"stdout":sys.argv[2],"authority":"proposal_only"}, sort_keys=True))
PY
  return "$code"
}

run_approved_check() {
  require_v3
  check_id="${1:-}"
  [ -n "$check_id" ] || usage
  check_command=""
  while IFS=$'\t' read -r id _ approved_command _; do
    if [ "$id" = "$check_id" ]; then
      check_command="$approved_command"
      break
    fi
  done < <(required_check_rows "$PLAN_PATH")
  [ -n "$check_command" ] || fail "unknown approved check: $check_id"
  set +e
  output="$(cd "$HARNESS_REPO_ROOT" && bash -lc "$check_command" 2>&1)"
  code=$?
  set -e
  python3 - "$check_id" "$check_command" "$code" "$output" <<'PY'
import json, sys
print(json.dumps({"schema_version":1,"command":"run-approved-check","check_id":sys.argv[1],"contract":sys.argv[2],"exit_code":int(sys.argv[3]),"stdout":sys.argv[4],"authority":"proposal_only"}, sort_keys=True))
PY
  return "$code"
}

tools() {
  require_v3
  python3 - <<'PY'
import json
print(json.dumps({
    "schema_version": 1,
    "tool_policy_version": "v4-tool-policy-1",
    "authority": "proposal_only",
    "tools": [
        {"name": "assigned-task", "risk": "read", "result": "observation"},
        {"name": "read-artifact", "risk": "read", "result": "observation"},
        {"name": "run-approved-check", "risk": "check", "result": "proposal"},
        {"name": "submit-result", "risk": "write-evidence", "result": "proposal"},
        {"name": "report-blocked", "risk": "write-evidence", "result": "proposal"},
    ],
    "arbitrary_command_execution": False,
}, sort_keys=True))
PY
}

submit() {
  require_v3
  kind="$1"
  input="$2"
  [ "$kind" = "proposal" ] || [ "$kind" = "evidence" ] || [ "$kind" = "blocked" ] || usage
  [ -f "$input" ] || fail "submission file does not exist: $input"
  destination="$HARNESS_ROOT/runtime/agent-submissions"
  mkdir -p "$destination"
  python3 - "$input" "$destination" "$kind" "$state" <<'PY'
import hashlib, json, pathlib, sys, time, uuid
source = pathlib.Path(sys.argv[1])
raw = source.read_bytes()
state = json.loads(pathlib.Path(sys.argv[4]).read_text())
record = {"schema_version":1,"submission_id":str(uuid.uuid4()),"kind":sys.argv[3],"run_id":state.get("run_id"),"task_id":state.get("task_id"),"source_sha256":hashlib.sha256(raw).hexdigest(),"submitted_at_epoch":time.time(),"authority":"PROPOSAL_ONLY","passed":False,"content":raw.decode("utf-8")}
out = pathlib.Path(sys.argv[2]) / f"{record['submission_id']}.json"
out.write_text(json.dumps(record, sort_keys=True, indent=2)+"\n")
print(json.dumps({"schema_version":1,"command":"submit-result","submission_id":record["submission_id"],"kind":record["kind"],"authority":record["authority"],"passed":False}, sort_keys=True))
PY
}

command="${1:-}"
shift || true
case "$command" in
  assigned-task) [ "$#" -eq 0 ] || usage; assigned_task ;;
  tools) [ "$#" -eq 0 ] || usage; tools ;;
  read-artifact) read_artifact "$@" ;;
  run-approved-check) [ "$#" -eq 1 ] || usage; run_approved_check "$@" ;;
  run-check) run_check "$@" ;;
  submit-result) [ "$#" -eq 2 ] || usage; submit "$@" ;;
  report-blocked) [ "$#" -eq 1 ] || usage; submit blocked "$1" ;;
  *) usage ;;
esac
