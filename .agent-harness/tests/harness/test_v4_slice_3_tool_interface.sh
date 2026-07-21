#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
plan="$repo_root/.agent-harness/docs/exec-plans/active/current.md"
interface="$repo_root/.agent-harness/scripts/agent-interface.sh"

tools_json="$(PLAN_PATH="$plan" "$interface" tools)"
python3 - "$tools_json" <<'PY'
import json
import sys
payload = json.loads(sys.argv[1])
assert payload["authority"] == "proposal_only", payload
assert payload["arbitrary_command_execution"] is False, payload
assert {tool["name"] for tool in payload["tools"]} >= {"read-artifact", "run-approved-check", "submit-result"}, payload
PY

PLAN_PATH="$plan" "$interface" run-check -- true >/dev/null
if PLAN_PATH="$plan" "$interface" run-check -- echo forbidden >/dev/null 2>&1; then
  echo "Arbitrary run-check command was accepted" >&2
  exit 1
fi
if PLAN_PATH="$plan" "$interface" run-approved-check unknown-check >/dev/null 2>&1; then
  echo "Unknown approved check was accepted" >&2
  exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ln -s /etc/hosts "$tmp/escape"
if PLAN_PATH="$plan" "$interface" read-artifact "$tmp/escape" >/dev/null 2>&1; then
  echo "Symlink escape was accepted" >&2
  exit 1
fi

echo "v4 Slice 3 controlled tool interface regression passed."
