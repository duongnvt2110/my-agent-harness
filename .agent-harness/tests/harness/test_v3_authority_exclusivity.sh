#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Self-issued authority without the protected control-plane key is rejected.
if (unset HARNESS_PROVENANCE_KEY_FILE; "$harness_root/scripts/approval.sh" issue "$tmp/approval.json" human phishing_resistant spec task run mutate target high_risk ENFORCED 60) >/dev/null 2>&1; then
  echo "self-minted high-risk approval was accepted" >&2
  exit 1
fi
if (unset HARNESS_PROVENANCE_KEY_FILE; "$harness_root/scripts/capability.sh" issue "$tmp/capability.json" intake task run spec policy snapshot Primary session mutate ENFORCED 60) >/dev/null 2>&1; then
  echo "self-minted enforced capability was accepted" >&2
  exit 1
fi

cat > "$tmp/metadata.json" <<'EOF'
{"workflow_version":"v3","implementation_version":"v3-core","enforcement_mode":"AUDIT_ONLY","assurance_limitations":["technical adapters unavailable"],"mixed_artifacts":true}
EOF
if "$harness_root/scripts/workflow-dispatch.sh" validate "$tmp/metadata.json" >/dev/null 2>&1; then
  echo "mixed workflow metadata was accepted" >&2
  exit 1
fi

cat > "$tmp/context.json" <<'EOF'
{"risk":"normal","enforcement_mode":"ENFORCED","authority_status":"PROTECTED"}
EOF
if HARNESS_WORKFLOW_VERSION=v3 HARNESS_AUTHORITY_CONTEXT="$tmp/context.json" "$harness_root/scripts/enforcement-gate.sh" high_risk mutation ENFORCED worktree >/dev/null 2>&1; then
  echo "caller risk override was accepted" >&2
  exit 1
fi

echo "V3 authority exclusivity regression passed."
