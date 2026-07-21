#!/usr/bin/env bash
set -euo pipefail
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cap="$tmp/capability.json"
scripts/capability.sh issue "$cap" intake task run spec policy snapshot Primary session-a read,inspect AUDIT_ONLY 30 >/dev/null
grep -q 'ADVISORY_AUDIT_ONLY' "$cap"
scripts/capability.sh validate "$cap" Primary session-a read >/dev/null
if scripts/capability.sh validate "$cap" Verifier session-a read >/dev/null 2>&1; then exit 1; fi
if scripts/capability.sh validate "$cap" Primary session-a mutate >/dev/null 2>&1; then exit 1; fi
echo "Capability regression passed."
