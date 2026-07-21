#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

./scripts/export-harness-package.sh --allow-no-git --output "$tmp/export" --zip "$tmp/template.zip" >/dev/null
./scripts/check-package-integrity.sh --root "$tmp/export" >/dev/null
./scripts/check-install-integrity.sh --root "$tmp/export" >/dev/null

if find "$tmp/export/.agent-harness/scripts" -maxdepth 1 -type f \( \
  -name 'export-clean-template.sh' -o \
  -name 'check-template-clean.sh' -o \
  -name 'check-active-plan.sh' -o \
  -name 'pev.sh' -o \
  -name 'check-env-contract.sh' -o \
  -name 'append-managed-block.sh' \
\) | grep -q .; then
  echo "Export still includes removed compatibility scripts" >&2
  exit 1
fi

echo "Export install integrity regression passed."
