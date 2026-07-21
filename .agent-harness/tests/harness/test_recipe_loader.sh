#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"
all="$($harness_root/scripts/load-recipe --all)"
printf '%s\n' "$all" | grep -q '"recipe_loader_version": 1'
printf '%s\n' "$all" | grep -q '"name": "harness-change"'
one="$($harness_root/scripts/load-recipe migration)"
printf '%s\n' "$one" | grep -q '"checkpoint_policy": "always"'
printf '%s\n' "$one" | grep -q '"recipe_hash": "[0-9a-f]'

tmp="$harness_root/recipes/.bad-test.yaml"
trap 'rm -f "$tmp"' EXIT
printf '%s\n' '{"schema_version":1,"canonicalization_version":1,"name":".bad-test","version":1,"required_states":["FINALIZED"],"verification_profile":"targeted","checkpoint_policy":"before_edit","oracle_policy":"never","human_approval_policy":"always","required_roles":["Primary"]}' > "$tmp"
if "$harness_root/scripts/load-recipe" .bad-test >/dev/null 2>&1; then
  echo "weak recipe was accepted" >&2
  exit 1
fi
echo "Recipe loader enforcement regression passed."
