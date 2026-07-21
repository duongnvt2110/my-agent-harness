#!/usr/bin/env bash
set -euo pipefail

grep -q 'run_gate file-map SCOPE_REMEDIATION ./scripts/check-file-map.sh' scripts/verify.sh || {
  echo "verify.sh does not route file-map failures to SCOPE_REMEDIATION" >&2
  exit 1
}
grep -q 'run_gate required-checks DIAGNOSE ./scripts/run-required-checks.sh' scripts/verify.sh || {
  echo "verify.sh does not route required-check failures to DIAGNOSE" >&2
  exit 1
}
grep -q 'run_gate spec-clarification PLAN ./scripts/check-spec-clarification.sh --check-only' scripts/verify.sh || {
  echo "verify.sh does not route planning failures to PLAN" >&2
  exit 1
}

echo "Verification routing regression passed."
