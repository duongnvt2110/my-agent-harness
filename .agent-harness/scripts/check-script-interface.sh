#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

# Keep this list focused on the supported command surface and scripts that are
# required by normal execution, package/release verification, or benchmark runs.
required_scripts=(
  scripts/harness.sh
  tests/harness/run_all.sh

  # Public dispatcher targets
  scripts/verify.sh
  scripts/finalize-task.sh
  scripts/score-harness.sh
  scripts/benchmark.sh
  scripts/release-check.sh
  scripts/install-harness.sh
  scripts/export-harness-package.sh

  # Active-plan lifecycle
  scripts/create-active-plan.sh
  scripts/approve-plan.sh
  scripts/approve-active-task.sh
  scripts/consume-plan.sh
  scripts/task.sh
  scripts/epic.sh
  scripts/story.sh
  scripts/update-epic-progress.sh

  # Context and decomposition
  scripts/classify-plan-size.sh
  scripts/decompose-plan.sh
  scripts/approve-decomposition.sh
  scripts/create-full-context.sh
  scripts/context.sh
  scripts/repository-intelligence.sh
  scripts/intake-control.sh

  # Verification gates
  scripts/check-active-plan-contract.sh
  scripts/check-baseline-contract.sh
  scripts/check-baseline-snapshot.sh
  scripts/check-behavior-baseline.sh
  scripts/check-change-baseline.sh
  scripts/check-context-budget.sh
  scripts/check-context-adr-exact-match.sh
  scripts/check-context-pack.sh
  scripts/check-file-map.sh
  scripts/check-full-context.sh
  scripts/check-install-integrity.sh
  scripts/check-package-integrity.sh
  scripts/check-plan-decomposition.sh
  scripts/check-plan-decomposition-semantic.sh
  scripts/check-script-interface.sh
  scripts/check-spec-clarification.sh
  scripts/check-target-safety.sh
  scripts/check-test-contract.sh
  scripts/check-work-alignment.sh
  scripts/run-required-checks.sh
  scripts/run-targeted-checks.sh
  scripts/setup-env.sh
  scripts/run-in-env.sh

  # Baseline and remediation
  scripts/create-baseline-snapshot.sh
  scripts/create-behavior-baseline.sh
  scripts/detect-change-baseline.sh
  scripts/detect-behavior-baseline.sh
  scripts/diagnose-failure.sh
  scripts/create-repair-plan.sh
  scripts/remediate.sh
  scripts/resolve-file-map-violation.sh
  scripts/check-remediation-trace.sh
  scripts/generate-test-report.sh
  scripts/generate-autonomous-run-report.sh

  # Decisions / ADRs
  scripts/adr.sh
  scripts/check-adr-awareness.sh
  scripts/check-adr-impact.sh
  scripts/record-decision.sh
  scripts/recover-finalization.sh
  scripts/check-task-schema.sh
  scripts/check-test-report.sh
  scripts/check-final-report.sh
  scripts/check-rollup-projection.sh
  scripts/check-task-plan-consistency.sh
)

legacy_removed_scripts=(
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

for script in "${required_scripts[@]}"; do
  [ -f "$script" ] || fail "Missing harness interface script: $script"
  [ -x "$script" ] || fail "Harness interface script is not executable: $script"
  head -n 1 "$script" | grep -q '^#!/usr/bin/env bash$' || fail "Missing bash shebang: $script"
  grep -Eq 'set -[[:alnum:]]*uo pipefail' "$script" || fail "Missing strict shell mode: $script"
done

for script in "${legacy_removed_scripts[@]}"; do
  [ ! -e "$script" ] || fail "Removed/deprecated script still exists: $script"
done

grep -q 'score)' scripts/harness.sh || fail "Missing score subcommand in scripts/harness.sh"
grep -q 'benchmark)' scripts/harness.sh || fail "Missing benchmark subcommand in scripts/harness.sh"
grep -q 'test)' scripts/harness.sh || fail "Missing test subcommand in scripts/harness.sh"
grep -q 'install)' scripts/harness.sh || fail "Missing install subcommand in scripts/harness.sh"
grep -q 'release-check)' scripts/harness.sh || fail "Missing release-check subcommand in scripts/harness.sh"
grep -q 'export)' scripts/harness.sh || fail "Missing export subcommand in scripts/harness.sh"
if grep -Eq 'export-clean\)|template-clean\)' scripts/harness.sh; then
  fail "Deprecated export-clean/template-clean subcommands must not exist"
fi
grep -q 'classify)' scripts/repository-intelligence.sh || fail "Missing classify subcommand in scripts/repository-intelligence.sh"

echo "Script interface checks passed."
