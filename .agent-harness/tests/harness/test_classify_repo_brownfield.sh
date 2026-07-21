#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

scan_root="tests/fixtures/repo-modes/brownfield"
intel_root="$tmp/out/docs/context/repository-intelligence"

REPO_SCAN_ROOT="$scan_root" REPO_INTELLIGENCE_ROOT="$intel_root" ./scripts/repository-intelligence.sh classify >/dev/null

grep -q '^  mode: brownfield$' "$intel_root/repo-profile.yml" || {
  echo "Brownfield fixture was not classified as brownfield" >&2
  exit 1
}
grep -q '^  brownfield_score: 80$' "$intel_root/repo-profile.yml" || {
  echo "Brownfield fixture brownfield score mismatch" >&2
  exit 1
}
grep -q '^  greenfield_score: 20$' "$intel_root/repo-profile.yml" || {
  echo "Brownfield fixture greenfield score mismatch" >&2
  exit 1
}

echo "Brownfield classification regression passed."
