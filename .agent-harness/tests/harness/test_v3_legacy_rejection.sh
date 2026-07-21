#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/v2.json" <<'JSON'
{"workflow_version":"v2","implementation_version":"2.9.0","enforcement_mode":"AUDIT_ONLY"}
JSON
if "$harness_root/scripts/workflow-dispatch.sh" "$tmp/v2.json" >/dev/null 2>&1; then
  echo "v2 workflow metadata was accepted" >&2
  exit 1
fi
if [ -e "$harness_root/scripts/migrate-v2-v3.sh" ]; then
  echo "v2 migration authority script still exists" >&2
  exit 1
fi
if "$harness_root/scripts/harness.sh" migrate-v2-v3 >/dev/null 2>&1; then
  echo "public v2 migration command was accepted" >&2
  exit 1
fi
echo "v3 legacy rejection tests passed"
