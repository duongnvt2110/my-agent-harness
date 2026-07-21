#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

printf '%s\n' '{"baseline_categories":["agent_harness_authority"],"evidence_status":"clear_low_risk","tiny_eligible":true,"requested_risk":"tiny"}' >"$tmp/high.json"
high="$($harness_root/scripts/classify-risk.sh "$tmp/high.json" --json)"
echo "$high" | grep -q '"risk": "high_risk"'
echo "$high" | grep -q '"sticky": true'
echo "$high" | grep -q '"agent_requested_risk_ignored": true'

printf '%s\n' '{"evidence_status":"ambiguous","requested_risk":"tiny"}' >"$tmp/missing.json"
missing="$($harness_root/scripts/classify-risk.sh "$tmp/missing.json" --json)"
echo "$missing" | grep -q '"risk": "normal"'

printf '%s\n' '{"evidence_status":"clear_low_risk","tiny_eligible":true}' >"$tmp/tiny.json"
tiny="$($harness_root/scripts/classify-risk.sh "$tmp/tiny.json" --json)"
echo "$tiny" | grep -q '"risk": "tiny"'

binding="$($harness_root/scripts/bind-policy.sh --policy "$harness_root/policies/policy-bundle-v1.json" --intake intake-1 --task task-1 --run run-1)"
echo "$binding" | grep -Eq '"policy_bundle_hash": "[0-9a-f]{64}"'
echo "$binding" | grep -q '"authority": "control_plane"'
echo "$binding" | grep -q '"run_id": "run-1"'

echo "Policy risk and binding regression passed."
