#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "$*" >&2
  exit 1
}

export_root="$(mktemp -d)"
trap 'rm -rf "$export_root"' EXIT
zip_path="$export_root/harness-template.zip"

./scripts/export-harness-package.sh --allow-no-git --output "$export_root/export" --zip "$zip_path"
./scripts/check-package-integrity.sh --root "$export_root/export"
./scripts/check-script-interface.sh

if rg -n "CONTEXT.md|docs/clarifications|docs/learnings|docs/references|docs/tutorials|export-clean-task|pev.sh|record-decision" scripts/harness-lib.sh >/dev/null 2>&1; then
  fail "Legacy paths still present in scripts/harness-lib.sh"
fi

removed_scripts=(
  scripts/append-managed-block.sh
  scripts/check-active-plan.sh
  scripts/check-create-active-plan-denies-existing.sh
  scripts/check-env-contract.sh
  scripts/check-harness-metrics.sh
  scripts/check-plan-alignment.sh
  scripts/check-remediation-scripts.sh
  scripts/check-template-clean.sh
  scripts/check-test-matrix.sh
  scripts/export-clean-template.sh
  scripts/intake.sh
  scripts/pev.sh
  scripts/record-discussion.sh
)
for script in "${removed_scripts[@]}"; do
  [ ! -e "$script" ] || fail "Removed script still exists: $script"
done

[ -x ./harness.sh ] || fail "Missing public harness wrapper"

if bash scripts/harness.sh export-clean >/tmp/harness-export-clean.out 2>&1; then
  fail "Deprecated export-clean subcommand unexpectedly succeeded"
fi
if bash scripts/harness.sh template-clean >/tmp/harness-template-clean.out 2>&1; then
  fail "Deprecated template-clean subcommand unexpectedly succeeded"
fi

echo "Template harness regression checks passed."
