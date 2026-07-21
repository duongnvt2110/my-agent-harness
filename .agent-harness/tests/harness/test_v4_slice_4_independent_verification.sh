#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
verifier="$repo_root/.agent-harness/scripts/verify-proposal.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/plan.md" <<'EOF'
---
task_id: verifier_fixture
required_checks:
  - id: fixture-check
    type: automated
    command: true
    blocking: true
    timeout_seconds: 30
    evidence: fixture.md
---
# Verifier fixture
EOF

python3 - "$tmp/plan.md" "$tmp/proposal.json" "$repo_root" <<'PY'
import hashlib, json, pathlib, subprocess, sys
plan = pathlib.Path(sys.argv[1])
proposal = pathlib.Path(sys.argv[2])
root = pathlib.Path(sys.argv[3])
plan_hash = hashlib.sha256(plan.read_bytes()).hexdigest()
workspace_hash = subprocess.check_output(
    [str(root / ".agent-harness/scripts/verify-proposal.sh"), "--workspace-hash"],
    text=True,
).strip()
proposal.write_text(json.dumps({
    "task_id": "verifier_fixture",
    "agent_session_id": "agent-claimed-success",
    "agent_passed": True,
    "plan_hash": plan_hash,
    "workspace_hash": workspace_hash,
}) + "\n")
PY

passed="$(PLAN_PATH="$tmp/plan.md" "$verifier" "$tmp/proposal.json" "$tmp/plan.md" fixture-pass)"
python3 - "$passed" <<'PY'
import json, sys
result = json.loads(sys.argv[1])
assert result["verdict"] == "PASSED", result
assert result["accepted_for_finalization"] is True, result
assert result["authority"] == "HARNESS_VERIFICATION", result
assert result["agent_session_id"] != result["verification_id"], result
assert result["checks"][0]["exit_code"] == 0, result
PY

printf '\nchanged after proposal\n' >> "$tmp/plan.md"
if PLAN_PATH="$tmp/plan.md" "$verifier" "$tmp/proposal.json" "$tmp/plan.md" fixture-stale >/dev/null 2>&1; then
  echo "Changed plan was accepted" >&2
  exit 1
fi

sed 's/command: true/command: false/' "$tmp/plan.md" > "$tmp/failed-plan.md"
python3 - "$tmp/failed-plan.md" "$tmp/proposal.json" "$repo_root" <<'PY'
import hashlib, json, pathlib, subprocess, sys
plan = pathlib.Path(sys.argv[1])
proposal = pathlib.Path(sys.argv[2])
root = pathlib.Path(sys.argv[3])
listing = subprocess.check_output(["git", "-C", str(root), "ls-files", "-s"], text=True)
proposal.write_text(json.dumps({
    "task_id": "verifier_fixture",
    "agent_session_id": "agent-claimed-success",
    "agent_passed": True,
    "plan_hash": hashlib.sha256(plan.read_bytes()).hexdigest(),
    "workspace_hash": hashlib.sha256(listing.encode()).hexdigest(),
}) + "\n")
PY
if PLAN_PATH="$tmp/failed-plan.md" "$verifier" "$tmp/proposal.json" "$tmp/failed-plan.md" fixture-failed >/dev/null 2>&1; then
  echo "Failed required check was accepted" >&2
  exit 1
fi

echo "v4 Slice 4 independent verification regression passed."
