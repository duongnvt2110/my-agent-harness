#!/usr/bin/env bash
set -euo pipefail
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
approval="$tmp/a.json"; ledger="$tmp/ledger"
scripts/approval.sh issue "$approval" human-1 phishing_resistant spec task run deploy target high_risk ENFORCED 30
scripts/approval.sh validate "$approval" spec task run deploy target high_risk ENFORCED >/dev/null
scripts/approval.sh consume "$approval" "$ledger"
if scripts/approval.sh consume "$approval" "$ledger" >/dev/null 2>&1; then exit 1; fi
if scripts/approval.sh validate "$approval" spec task successor deploy target high_risk ENFORCED >/dev/null 2>&1; then exit 1; fi
echo "Approval regression passed."
