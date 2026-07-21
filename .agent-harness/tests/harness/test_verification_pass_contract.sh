#!/usr/bin/env bash
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/harness/scripts" "$tmp/harness/docs/exec-plans/active" "$tmp/harness/docs/evidence/contract"
cp scripts/harness-lib.sh scripts/check-evidence.sh "$tmp/harness/scripts/"
cat > "$tmp/harness/docs/exec-plans/active/current.md" <<'EOF'
---
task_id: contract
status: VERIFIED
evidence_required: true
---
EOF
cat > "$tmp/harness/docs/evidence/contract/check.md" <<'EOF'
result: pass
EOF
cat > "$tmp/harness/docs/evidence/contract/verification-pass.md" <<'EOF'
# Verification Pass

task_id: contract
result: pass
verified_at: 2026-07-12 00:00:00 +0000

## Gates

- required-checks
- evidence
EOF
cat > "$tmp/harness/docs/exec-plans/active/current.md.tmp" <<'EOF'
EOF

if ! (cd "$tmp/harness" && HARNESS_ROOT="$tmp/harness" PLAN_PATH="$tmp/harness/docs/exec-plans/active/current.md" bash scripts/check-evidence.sh); then
  echo "valid verification-pass evidence was rejected" >&2
  exit 1
fi
perl -pi -e 's/task_id: contract/task_id: other/' "$tmp/harness/docs/evidence/contract/verification-pass.md"
if (cd "$tmp/harness" && HARNESS_ROOT="$tmp/harness" PLAN_PATH="$tmp/harness/docs/exec-plans/active/current.md" bash scripts/check-evidence.sh) >/dev/null 2>&1; then
  echo "mismatched verification-pass evidence was accepted" >&2
  exit 1
fi
echo "Verification-pass contract regression passed."
