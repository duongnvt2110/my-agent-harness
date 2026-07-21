#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

if find docs/specifications/v3_authority_exclusivity_milestone -type f -print -quit 2>/dev/null | grep -q .; then
  echo 'stale pre-cutover milestone specification remains' >&2
  exit 1
fi
if rg -n 'docs/specifications/v3_authority_exclusivity_milestone' scripts tests --glob '!tests/harness/test_stale_milestone_artifacts.sh' >/dev/null; then
  echo 'live scripts or tests still depend on removed milestone artifacts' >&2
  exit 1
fi
[ -f scripts/workflow-dispatch.sh ] || { echo 'v3 dispatcher is missing' >&2; exit 1; }
[ -f scripts/transition-state ] || { echo 'v3 transition writer is missing' >&2; exit 1; }

echo 'Stale milestone artifact regression passed.'
