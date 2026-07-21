#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

scan_root="tests/fixtures/repo-modes/greenfield"
intel_root="$tmp/out/docs/context/repository-intelligence"

REPO_SCAN_ROOT="$scan_root" REPO_INTELLIGENCE_ROOT="$intel_root" ./scripts/repository-intelligence.sh classify >/dev/null

grep -q '^  mode: greenfield$' "$intel_root/repo-profile.yml" || {
  echo "Greenfield fixture was not classified as greenfield" >&2
  exit 1
}
grep -q '^  brownfield_score: 5$' "$intel_root/repo-profile.yml" || {
  echo "Greenfield fixture brownfield score mismatch" >&2
  exit 1
}
grep -q '^  greenfield_score: 95$' "$intel_root/repo-profile.yml" || {
  echo "Greenfield fixture greenfield score mismatch" >&2
  exit 1
}

echo "Greenfield classification regression passed."
