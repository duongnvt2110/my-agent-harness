#!/usr/bin/env bash
set -euo pipefail
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
workspace="$tmp/workspace"; mkdir -p "$workspace"; record="$tmp/workspace.json"
token="$(scripts/workspace-guard.sh acquire "$workspace" "$record" run-1 session-1)"
scripts/workspace-guard.sh validate "$workspace" "$record" run-1 session-1 "$token" >/dev/null
if scripts/workspace-guard.sh acquire "$workspace" "$record" run-2 session-2 >/dev/null 2>&1; then exit 1; fi
printf 'drift\n' > "$workspace/drift.txt"
if scripts/workspace-guard.sh validate "$workspace" "$record" run-1 session-1 "$token" >/dev/null 2>&1; then exit 1; fi
echo "Workspace guard regression passed."
