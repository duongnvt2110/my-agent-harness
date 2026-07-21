#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

bash "$harness_root/tests/harness/test_recipe_loader.sh"

if "$harness_root/harness.sh" verifier-adapter start >/dev/null 2>&1; then
  echo 'legacy verifier-adapter command remains public' >&2
  exit 1
fi
if [ -e "$harness_root/scripts/verifier-adapter" ]; then
  echo 'legacy verifier-adapter script remains present' >&2
  exit 1
fi

if rg -n 'required_roles|Primary|Verifier|Finalizer|Oracle' \
  "$harness_root/scripts/load-recipe" "$harness_root/recipes" "$harness_root/scripts/harness.sh"; then
  echo 'legacy role authority remains in v3 recipe surface' >&2
  exit 1
fi

echo 'v3 role authority removal regression passed'
