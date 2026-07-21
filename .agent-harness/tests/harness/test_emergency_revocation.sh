#!/usr/bin/env bash
set -euo pipefail
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
printf '%064d' 0 > "$tmp/provenance.key"
HARNESS_PROVENANCE_KEY_FILE="$tmp/provenance.key" ./scripts/capability.sh issue "$tmp/cap.json" intake task run spec policy snap Primary sess inspect ENFORCED 600 >/dev/null
./scripts/emergency-revoke issue "$tmp/rev.json" '{"run_id":"run"}' emergency 600 >/dev/null
if HARNESS_PROVENANCE_KEY_FILE="$tmp/provenance.key" ./scripts/capability.sh validate "$tmp/cap.json" Primary sess inspect "$tmp/rev.json" >/dev/null 2>&1; then exit 1; fi
HARNESS_PROVENANCE_KEY_FILE="$tmp/provenance.key" ./scripts/capability.sh validate "$tmp/cap.json" Primary sess inspect >/dev/null
printf '%s\n' '{"revocation_hash":"bad"}' > "$tmp/tampered.json"
if ./scripts/emergency-revoke check "$tmp/tampered.json" "$tmp/cap.json" "$(( $(date +%s) + 10 ))" >/dev/null 2>&1; then exit 1; fi
echo 'Emergency revocation regression passed.'
