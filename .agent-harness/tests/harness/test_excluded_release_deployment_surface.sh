#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for command in external-saga release-attest; do
  if "$harness_root/harness.sh" "$command" >/dev/null 2>&1; then
    echo "excluded command remains public: $command" >&2
    exit 1
  fi
done

for path in "$harness_root/scripts/external-saga.sh" "$harness_root/scripts/release-attest"; do
  if [ -e "$path" ]; then
    echo "excluded surface remains present: $path" >&2
    exit 1
  fi
done

if ! bash -n "$harness_root/scripts/release-check.sh"; then
  echo 'local release check is not syntactically valid' >&2
  exit 1
fi
if rg -n 'trusted prior|external validator|attestation|signature|release-attest' "$harness_root/scripts/release-check.sh"; then
  echo 'release check still claims excluded release authority' >&2
  exit 1
fi

echo 'excluded release and deployment surface regression passed'
