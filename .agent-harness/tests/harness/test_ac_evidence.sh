#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
hash='0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
cat >"$tmp/evidence.json" <<EOF
{"ac_id":"AC-001","status":"PASSED","evidence_class":"deterministic_test","producer_actor":"agent","verification_function":"harness_verification","verification_id":"verification-1","retention_class":"RUN_AUDIT","artifact_hash":"$hash","freshness":{"spec_hash":"spec-1","policy_hash":"policy-1","run_id":"run-1"},"trusted":true,"conclusive":true,"expiry_epoch":4102444800,"sanitized_summary":"deterministic check passed"}
EOF
result="$($harness_root/scripts/check-ac-evidence.sh "$tmp/evidence.json" spec-1 policy-1 run-1 high)"
echo "$result" | grep -q '"valid": true'

sed 's/"artifact_hash":"[^"]*"/"artifact_hash":"bad"/' "$tmp/evidence.json" >"$tmp/bad.json"
if "$harness_root/scripts/check-ac-evidence.sh" "$tmp/bad.json" spec-1 policy-1 run-1 high >/dev/null 2>&1; then
  echo "invalid evidence was accepted" >&2
  exit 1
fi

sed 's/"sanitized_summary":"deterministic check passed"/"sanitized_summary":"deterministic check passed","token":"raw-secret"/' "$tmp/evidence.json" >"$tmp/sensitive.json"
if "$harness_root/scripts/check-ac-evidence.sh" "$tmp/sensitive.json" spec-1 policy-1 run-1 high >/dev/null 2>&1; then
  echo "sensitive evidence was accepted" >&2
  exit 1
fi

echo "AC evidence regression passed."
