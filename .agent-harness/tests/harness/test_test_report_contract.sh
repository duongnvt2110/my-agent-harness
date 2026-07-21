#!/usr/bin/env bash
set -euo pipefail

script="scripts/generate-test-report.sh"
grep -q 'report_schema_version: 1' "$script" || {
  echo "test reports must declare report_schema_version" >&2
  exit 1
}
grep -q 'canonicalization_version: 1' "$script" || {
  echo "test reports must declare canonicalization_version" >&2
  exit 1
}
grep -q 'required_checks_count:' "$script" || {
  echo "test reports must declare required check count" >&2
  exit 1
}
grep -q 'blocking_checks_passed:' "$script" || {
  echo "test reports must declare blocking pass count" >&2
  exit 1
}
grep -q 'check-test-report.sh' scripts/verify.sh || {
  echo "verification must validate generated test reports" >&2
  exit 1
}
echo "Test report contract regression passed."
