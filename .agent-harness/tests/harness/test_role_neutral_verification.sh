#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for test_file in \
  test_ac_evidence.sh \
  test_verifier_verdict.sh \
  test_completion_judge.sh \
  test_v3_finalization_transaction.sh; do
  bash "$harness_root/tests/harness/$test_file"
done

if rg -n '"producer"|"evaluator"|producer_session|evaluator_session|verifier_role|Primary|Verifier|Finalizer|Oracle' \
  "$harness_root/scripts/check-ac-evidence.sh" \
  "$harness_root/scripts/check-verifier-verdict.sh" \
  "$harness_root/scripts/check-completion-judge.sh"; then
  echo 'verification scripts still contain legacy role authority' >&2
  exit 1
fi

echo 'v3 role-neutral verification regression passed'
