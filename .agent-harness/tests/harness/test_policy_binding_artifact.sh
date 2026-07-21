#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
out="$tmp/binding.json"
scripts/bind-policy.sh --policy policies/policy-bundle-v1.json --intake intake-1 --task task-1 --run run-1 --out "$out" >/dev/null
grep -q '"policy_bundle_id"' "$out"
if scripts/bind-policy.sh --policy policies/policy-bundle-v1.json --intake intake-1 --task task-1 --run run-1 --out "$out" >/dev/null 2>&1; then
  echo "policy binding was overwritten" >&2
  exit 1
fi
cat > "$tmp/bad-policy.json" <<'EOF'
{"policy_bundle_id":"bad"}
EOF
if scripts/bind-policy.sh --policy "$tmp/bad-policy.json" --intake intake-1 --task task-1 --run run-1 >/dev/null 2>&1; then
  echo "malformed policy bundle unexpectedly bound" >&2
  exit 1
fi
echo "Policy binding artifact regression passed."
