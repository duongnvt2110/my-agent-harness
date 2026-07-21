#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/v2.json" <<'EOF'
{"workflow_version":"v2","implementation_version":"2.9.0","enforcement_mode":"AUDIT_ONLY","assurance_limitations":["legacy lifecycle"]}
EOF
cat > "$tmp/v3.json" <<'EOF'
{"workflow_version":"v3","implementation_version":"v3-core","enforcement_mode":"AUDIT_ONLY","assurance_limitations":["repository-local governance"]}
EOF
if scripts/workflow-dispatch.sh "$tmp/v2.json" >/dev/null 2>&1; then
  echo "legacy v2 metadata was accepted" >&2
  exit 1
fi
grep -q '"dispatch": "v3_core"' <(scripts/workflow-dispatch.sh "$tmp/v3.json")
cat > "$tmp/enforced.json" <<'EOF'
{"workflow_version":"v3","implementation_version":"v3-test","enforcement_mode":"ENFORCED","assurance_limitations":["test limitation"]}
EOF
status_output="$(HARNESS_V3_DISPATCHED=1 HARNESS_WORKFLOW_METADATA="$tmp/enforced.json" scripts/harness.sh status)"
grep -q '^workflow_version: v3$' <<<"$status_output"
grep -q '^implementation_version: v3-test$' <<<"$status_output"
grep -q '^enforcement_mode: ENFORCED$' <<<"$status_output"
grep -q '^assurance_limitations: test limitation$' <<<"$status_output"

cat > "$tmp/mixed.json" <<'EOF'
{"workflow_version":"v3","implementation_version":"3.0.0","enforcement_mode":"AUDIT_ONLY","assurance_limitations":[],"mixed_artifacts":true}
EOF
if scripts/workflow-dispatch.sh "$tmp/mixed.json" >/dev/null 2>&1; then
  echo "mixed artifacts unexpectedly dispatched" >&2
  exit 1
fi
echo "Workflow dispatch regression passed."
