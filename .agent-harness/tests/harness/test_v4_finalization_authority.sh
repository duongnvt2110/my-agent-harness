#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

harness_root="$tmp/harness"
mkdir -p "$harness_root/scripts" "$harness_root/docs/exec-plans/active" "$harness_root/docs/exec-plans/completed" "$harness_root/docs/evidence/v4-finalize" "$harness_root/docs/tasks"

for script in harness-lib.sh finalize-task.sh verify-proposal.sh check-v4-verification.sh; do
  cp "$repo_root/.agent-harness/scripts/$script" "$harness_root/scripts/$script"
done

cat > "$harness_root/scripts/verify.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/harness-lib.sh"
resolve_harness_paths
mkdir -p "$(evidence_dir)"
printf '%s\n' '# Verification Pass' 'result: pass' > "$(evidence_dir)/verification-pass.md"
printf '%s\n' '# Test Report' 'result: pass' > "$(evidence_dir)/test-report.md"
set_fm_value "$PLAN_PATH" status VERIFIED
set_fm_value "$PLAN_PATH" lifecycle_phase FINALIZE
SH

cat > "$harness_root/scripts/task.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
exit 0
SH
cat > "$harness_root/scripts/consume-plan.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
exit 0
SH
cat > "$harness_root/scripts/generate-autonomous-run-report.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/harness-lib.sh"
resolve_harness_paths
printf '%s\n' '# Autonomous Run Report' 'result: pass' > "$(evidence_dir)/autonomous-run-report.md"
SH
chmod +x "$harness_root/scripts"/*.sh

write_plan() {
  cat > "$harness_root/docs/exec-plans/active/current.md" <<'EOF'
---
task_id: v4_finalize_fixture
title: "V4 finalize fixture"
status: APPROVED
lifecycle_phase: EXECUTE
review_required: false
v4_verification_required: true
parent_epic_id: null
parent_story_id: null
adr_check_required: false
---
# V4 finalize fixture
EOF
}

write_proposal() {
  plan_hash="$(python3 -c 'import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],"rb").read()).hexdigest())' "$harness_root/docs/exec-plans/active/current.md")"
  workspace_hash="$(HARNESS_ROOT="$harness_root" HARNESS_REPO_ROOT="$harness_root" "$harness_root/scripts/verify-proposal.sh" --workspace-hash)"
  python3 - "$tmp/proposal.json" "$plan_hash" "$workspace_hash" <<'PY'
import json, pathlib, sys
pathlib.Path(sys.argv[1]).write_text(json.dumps({"task_id":"v4_finalize_fixture","agent_session_id":"agent-fixture","plan_hash":sys.argv[2],"workspace_hash":sys.argv[3]}) + "\n")
PY
}

write_plan
write_proposal
if ! PLAN_PATH="$harness_root/docs/exec-plans/active/current.md" HARNESS_V4_PROPOSAL_PATH="$tmp/proposal.json" HARNESS_V4_VERDICT_PATH="$tmp/v4-verdict.json" HARNESS_ROOT="$harness_root" HARNESS_REPO_ROOT="$harness_root" "$harness_root/scripts/finalize-task.sh" >/dev/null; then
  cat "$tmp/v4-verdict.json" >&2
  exit 1
fi
find "$harness_root/docs/exec-plans/completed" -name '*_v4_finalize_fixture.md' -print -quit | rtk rg -q 'v4_finalize_fixture'

write_plan
python3 - "$tmp/forged-verdict.json" "$harness_root/docs/exec-plans/active/current.md" <<'PY'
import hashlib, json, pathlib, sys
plan = pathlib.Path(sys.argv[2])
pathlib.Path(sys.argv[1]).write_text(json.dumps({"authority":"HARNESS_VERIFICATION","verification_function":"harness_verification","verdict":"PASSED","accepted_for_finalization":True,"verification_id":"harness-verification","agent_session_id":"agent-fixture","plan_hash":hashlib.sha256(plan.read_bytes()).hexdigest(),"workspace_hash":"forged-workspace-hash"}) + "\n")
PY
if PLAN_PATH="$harness_root/docs/exec-plans/active/current.md" HARNESS_ROOT="$harness_root" HARNESS_REPO_ROOT="$harness_root" "$harness_root/scripts/check-v4-verification.sh" "$tmp/forged-verdict.json" "$harness_root/docs/exec-plans/active/current.md" >/dev/null 2>&1; then
  echo "Standalone checker accepted forged workspace hash" >&2
  exit 1
fi

echo "v4 finalization authority integration regression passed."
