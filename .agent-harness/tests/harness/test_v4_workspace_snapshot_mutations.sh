#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fixture="$tmp/fixture"
mkdir -p "$fixture/.agent-harness/scripts" "$fixture/src"
cp "$repo_root/.agent-harness/scripts/verify-proposal.sh" "$fixture/.agent-harness/scripts/"
cp "$repo_root/.agent-harness/scripts/harness-lib.sh" "$fixture/.agent-harness/scripts/"
chmod +x "$fixture/.agent-harness/scripts/verify-proposal.sh"
printf 'tracked source\n' > "$fixture/src/tracked.txt"
git -C "$fixture" init -q
git -C "$fixture" add src/tracked.txt

cat > "$tmp/plan.md" <<'EOF'
---
task_id: workspace_snapshot_fixture
required_checks:
  - id: fixture-check
    type: automated
    command: true
    blocking: true
---
# Workspace snapshot fixture
EOF

workspace_hash() {
  HARNESS_ROOT="$fixture/.agent-harness" HARNESS_REPO_ROOT="$fixture" \
    "$fixture/.agent-harness/scripts/verify-proposal.sh" --workspace-hash
}

write_proposal() {
  plan_hash="$(python3 -c 'import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],"rb").read()).hexdigest())' "$tmp/plan.md")"
  snapshot_hash="$(workspace_hash)"
  python3 - "$tmp/plan.md" "$tmp/proposal.json" "$plan_hash" "$snapshot_hash" <<'PY'
import json, pathlib, sys
pathlib.Path(sys.argv[2]).write_text(json.dumps({
    "task_id": "workspace_snapshot_fixture",
    "agent_session_id": "agent-fixture",
    "plan_hash": sys.argv[3],
    "workspace_hash": sys.argv[4],
}) + "\n")
PY
}

write_proposal
PLAN_PATH="$tmp/plan.md" HARNESS_ROOT="$fixture/.agent-harness" HARNESS_REPO_ROOT="$fixture" \
  "$fixture/.agent-harness/scripts/verify-proposal.sh" "$tmp/proposal.json" "$tmp/plan.md" pass >/dev/null

printf 'changed source\n' >> "$fixture/src/tracked.txt"
if PLAN_PATH="$tmp/plan.md" HARNESS_ROOT="$fixture/.agent-harness" HARNESS_REPO_ROOT="$fixture" \
  "$fixture/.agent-harness/scripts/verify-proposal.sh" "$tmp/proposal.json" "$tmp/plan.md" tracked-change >/dev/null 2>&1; then
  echo "Tracked working-tree mutation was accepted" >&2
  exit 1
fi

printf 'tracked source\n' > "$fixture/src/tracked.txt"
write_proposal
printf 'untracked source\n' > "$fixture/src/untracked.txt"
if PLAN_PATH="$tmp/plan.md" HARNESS_ROOT="$fixture/.agent-harness" HARNESS_REPO_ROOT="$fixture" \
  "$fixture/.agent-harness/scripts/verify-proposal.sh" "$tmp/proposal.json" "$tmp/plan.md" untracked-change >/dev/null 2>&1; then
  echo "Untracked mutation was accepted" >&2
  exit 1
fi

echo "v4 workspace snapshot mutation regression passed."
