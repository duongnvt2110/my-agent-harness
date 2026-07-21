#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

./scripts/export-harness-package.sh --allow-no-git --mode clean-template --output "$tmp/clean" >/dev/null
./scripts/check-template-cleanliness --root "$tmp/clean" --mode clean-template >/dev/null

./scripts/export-harness-package.sh --allow-no-git --mode source-snapshot --output "$tmp/source" >/dev/null
./scripts/check-template-cleanliness --root "$tmp/source" --mode source-snapshot >/dev/null

./scripts/export-harness-package.sh --allow-no-git --mode audit-snapshot --output "$tmp/audit" >/dev/null
./scripts/check-template-cleanliness --root "$tmp/audit" --mode audit-snapshot >/dev/null

mkdir -p "$tmp/clean/.git"
if ./scripts/check-template-cleanliness --root "$tmp/clean" --mode clean-template >/dev/null 2>&1; then
  echo 'cleanliness checker accepted .git' >&2
  exit 1
fi

echo 'Template cleanliness and export mode regression passed.'
