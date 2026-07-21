#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for command in network-capability run-in-sandbox network-request; do
  if "$harness_root/harness.sh" "$command" >/dev/null 2>&1; then
    echo "excluded command remains public: $command" >&2
    exit 1
  fi
done

for path in \
  "$harness_root/scripts/network-capability.sh" \
  "$harness_root/scripts/network-request" \
  "$harness_root/scripts/run-in-sandbox" \
  "$harness_root/policies/sandbox-profiles.yaml"; do
  if [ -e "$path" ]; then
    echo "excluded adapter remains present: $path" >&2
    exit 1
  fi
done

if rg -n 'network_default|sandbox|network_adapter|tool_adapter|verifier_adapter' \
  "$harness_root/policies/policy-bundle-v1.json" "$harness_root/scripts/enforcement-gate.sh"; then
  echo 'excluded technical controls remain in the v3 governance policy' >&2
  exit 1
fi

echo 'excluded capability adapter regression passed'
