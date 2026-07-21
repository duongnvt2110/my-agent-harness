#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/.agent-harness/runtime" "$tmp/.agent-harness/docs/exec-plans/active"
cp "$harness_root/runtime/v3-workflow.json" "$tmp/.agent-harness/runtime/"
cat > "$tmp/.agent-harness/runtime/state.json" <<'JSON'
{"schema_version":1,"canonicalization_version":1,"run_id":"run-agent-interface","task_id":"task-agent-interface","state":"IMPLEMENTING","active_function":"execution","event_sequence":1,"event_hash":"0000000000000000000000000000000000000000000000000000000000000000"}
JSON
cat > "$tmp/.agent-harness/docs/exec-plans/active/current.md" <<'MD'
---
task_id: task-agent-interface
approved_files:
  - src/example.py
required_checks:
  - id: check-example
---
MD
mkdir -p "$tmp/src"
printf 'hello\n' > "$tmp/src/example.py"
printf 'proposal\n' > "$tmp/proposal.txt"

run_interface() {
  env -u PLAN_PATH -u HARNESS_STATE_DIR -u HARNESS_DOCS_DIR -u HARNESS_TESTS_DIR \
    -u HARNESS_SCRIPT_DIR -u HARNESS_SCRIPTS_DIR \
    HARNESS_ROOT="$tmp/.agent-harness" HARNESS_REPO_ROOT="$tmp" \
    bash "$harness_root/scripts/agent-interface.sh" "$@"
}

assigned="$(run_interface assigned-task)"
printf '%s' "$assigned" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["command"]=="assigned-task"; assert d["workflow_version"]=="v3"; assert d["task_id"]=="task-agent-interface"; assert d["authority"]=="observation_only"'

artifact="$(run_interface read-artifact src/example.py)"
printf '%s' "$artifact" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["content"]=="hello\n"; assert d["authority"]=="observation_only"'

if run_interface read-artifact ../outside.txt >/dev/null 2>&1; then
  echo "outside artifact unexpectedly readable" >&2
  exit 1
fi

check="$(run_interface run-check -- true)"
printf '%s' "$check" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["exit_code"]==0; assert d["authority"]=="proposal_only"'

if run_interface run-check -- false >/dev/null 2>&1; then
  echo "failing check unexpectedly succeeded" >&2
  exit 1
fi

submission="$(run_interface submit-result evidence "$tmp/proposal.txt")"
printf '%s' "$submission" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["authority"]=="PROPOSAL_ONLY"; assert d["passed"] is False'
test "$(find "$tmp/.agent-harness/runtime/agent-submissions" -type f | wc -l | tr -d ' ')" = "1"

blocked="$(run_interface report-blocked "$tmp/proposal.txt")"
printf '%s' "$blocked" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["kind"]=="blocked"; assert d["passed"] is False'
test "$(find "$tmp/.agent-harness/runtime/agent-submissions" -type f | wc -l | tr -d ' ')" = "2"

if run_interface transition-state IMPLEMENTING >/dev/null 2>&1; then
  echo "lifecycle command unexpectedly exposed" >&2
  exit 1
fi

echo "v3 agent interface tests passed"
