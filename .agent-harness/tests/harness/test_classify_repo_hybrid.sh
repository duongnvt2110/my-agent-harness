#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

scan_root="tests/fixtures/repo-modes/hybrid"
intel_root="$tmp/out/docs/context/repository-intelligence"

REPO_SCAN_ROOT="$scan_root" REPO_INTELLIGENCE_ROOT="$intel_root" ./scripts/repository-intelligence.sh classify >/dev/null

grep -q '^  mode: hybrid$' "$intel_root/repo-profile.yml" || {
  echo "Hybrid fixture was not classified as hybrid" >&2
  exit 1
}
grep -q '^  brownfield_score: 55$' "$intel_root/repo-profile.yml" || {
  echo "Hybrid fixture brownfield score mismatch" >&2
  exit 1
}
grep -q '^  greenfield_score: 45$' "$intel_root/repo-profile.yml" || {
  echo "Hybrid fixture greenfield score mismatch" >&2
  exit 1
}

echo "Hybrid classification regression passed."
