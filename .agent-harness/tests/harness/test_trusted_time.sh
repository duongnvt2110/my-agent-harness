#!/usr/bin/env bash
set -euo pipefail
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
record="$tmp/time.json"
scripts/trusted-time.sh observe "$record" >/dev/null
scripts/trusted-time.sh check "$record" >/dev/null
if scripts/trusted-time.sh observe "$record" 1 >/dev/null 2>&1; then exit 1; fi
if scripts/trusted-time.sh decision "$record" >/dev/null 2>&1; then exit 1; fi
scripts/trusted-time.sh observe "$record" >/dev/null
sed -i.bak 's/"time_source": "control_plane_clock"/"time_source": "untrusted_observation"/' "$record"
if scripts/trusted-time.sh decision "$record" >/dev/null 2>&1; then exit 1; fi
echo "Trusted time regression passed."
