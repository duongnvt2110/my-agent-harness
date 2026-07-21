#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/tiny.json" <<'EOF'
{"evidence_status":"clear_low_risk","tiny_eligible":true,"observable_signals":[]}
EOF
cat > "$tmp/normal.json" <<'EOF'
{"evidence_status":"ambiguous","tiny_eligible":false}
EOF
cat > "$tmp/high.json" <<'EOF'
{"evidence_status":"clear_low_risk","tiny_eligible":true,"mandatory_signals":["lifecycle_authority"]}
EOF
tiny="$($harness_root/scripts/calculate-run-budget "$tmp/tiny.json")"
normal="$($harness_root/scripts/calculate-run-budget "$tmp/normal.json")"
high="$($harness_root/scripts/calculate-run-budget "$tmp/high.json" "$tmp/high-manifest.json")"
printf '%s\n' "$tiny" | grep -q '"risk": "tiny"'
printf '%s\n' "$normal" | grep -q '"risk": "normal"'
printf '%s\n' "$high" | grep -q '"risk": "high_risk"'
printf '%s\n' "$high" | grep -q '"weakens_verification": false'
if "$harness_root/scripts/calculate-run-budget" "$tmp/tiny.json" "$tmp/high-manifest.json" >/dev/null 2>&1; then
  echo "sticky high-risk lane was downgraded" >&2
  exit 1
fi
echo "Deterministic budget routing regression passed."
