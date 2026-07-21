#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d "$root/.binary-artifact.XXXXXX")"; trap 'rm -rf "$tmp"' EXIT
printf '\x89PNG\r\n\x1a\n\x00\xff' > "$tmp/image.png"
output="$(cd "$root" && bash scripts/agent-interface.sh read-artifact "$tmp/image.png")"
printf '%s' "$output" | python3 -c 'import base64,json,sys; d=json.load(sys.stdin); assert d["byte_length"]==10; assert d["media_type"]=="image/png"; assert base64.b64decode(d["content_base64"]).startswith(b"\x89PNG"); assert d["authority"]=="observation_only"'
echo "Binary artifact capture passed."
