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

if find "$tmp/clean/.agent-harness/docs/context" -type f 2>/dev/null | grep -q .; then
  echo 'Clean export retained repository-specific context' >&2
  exit 1
fi
if [ -e "$tmp/clean/.agent-harness/benchmarks" ]; then
  echo 'Clean export retained benchmark fixtures' >&2
  exit 1
fi
if [ ! -e "$tmp/source/.agent-harness/benchmarks" ]; then
  echo 'Source snapshot lost benchmark fixtures' >&2
  exit 1
fi
for path in \
  .agent-harness/docs/decisions \
  .agent-harness/docs/design-docs \
  .agent-harness/docs/product-contracts \
  .agent-harness/docs/product-specs \
  .agent-harness/docs/prompts \
  .agent-harness/docs/reference \
  .agent-harness/docs/PLANS.md \
  .agent-harness/docs/TEST_MATRIX.md
do
  if [ -e "$tmp/clean/$path" ]; then
    echo "Clean export retained development material: $path" >&2
    exit 1
  fi
done
grep -q '^  "source_commit": "not-available"' "$tmp/clean/manifest.json" || {
  echo 'Clean export retained source commit provenance' >&2
  exit 1
}
grep -q '^  "git_status_before_export": \[\],$' "$tmp/clean/manifest.json" || {
  echo 'Clean export retained source Git status' >&2
  exit 1
}
if grep -q 'Scratch Harness' "$tmp/clean/README.md" "$tmp/clean/WORKFLOW.md" "$tmp/clean/CONTEXT.md"; then
  echo 'Clean export retained scratch-repository branding' >&2
  exit 1
fi

mkdir -p "$tmp/clean/.git"
if ./scripts/check-template-cleanliness --root "$tmp/clean" --mode clean-template >/dev/null 2>&1; then
  echo 'cleanliness checker accepted .git' >&2
  exit 1
fi

echo 'Template cleanliness and export mode regression passed.'
