#!/usr/bin/env bash
set -euo pipefail

harness_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
workspace="$tmp/workspace"
checkpoint="$tmp/checkpoint"
restored="$tmp/restored"
mkdir -p "$workspace" "$restored"
printf 'alpha\n' >"$workspace/file.txt"
mkdir -p "$workspace/sub"
printf 'beta\n' >"$workspace/sub/other.txt"

"$harness_root/scripts/create-checkpoint.sh" "$workspace" "$checkpoint" run-1 >/dev/null
"$harness_root/scripts/verify-checkpoint.sh" "$checkpoint" "$workspace" | grep -q '^checkpoint_valid: true$'
"$harness_root/scripts/restore-checkpoint.sh" "$checkpoint" "$restored" | grep -q '^checkpoint_restored: true$'
cmp "$workspace/file.txt" "$restored/file.txt"
cmp "$workspace/sub/other.txt" "$restored/sub/other.txt"

cp -R "$checkpoint" "$tmp/legacy-checkpoint"
perl -0pi -e 's/"checkpoint_schema_version":2/"checkpoint_schema_version":1/' "$tmp/legacy-checkpoint/manifest.json"
if "$harness_root/scripts/verify-checkpoint.sh" "$tmp/legacy-checkpoint" - >/dev/null 2>&1; then
  echo "legacy checkpoint schema was accepted" >&2
  exit 1
fi

cp -R "$checkpoint" "$tmp/unsafe-checkpoint"
python3 - "$tmp/unsafe-checkpoint/manifest.json" <<'PY'
import hashlib, json, pathlib, sys
path = pathlib.Path(sys.argv[1]); data = json.loads(path.read_text())
data["files"][0]["path"] = "../escape.txt"
copy = dict(data); copy.pop("manifest_hash", None)
data["manifest_hash"] = hashlib.sha256(json.dumps(copy, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
path.write_text(json.dumps(data, sort_keys=True, separators=(",", ":")) + "\n")
PY
mkdir "$tmp/unsafe-restored"
if "$harness_root/scripts/restore-checkpoint.sh" "$tmp/unsafe-checkpoint" "$tmp/unsafe-restored" >/dev/null 2>&1; then
  echo "unsafe checkpoint path was restored" >&2
  exit 1
fi
if [ -e "$tmp/unsafe-restored/escape.txt" ] || [ -e "$tmp/unsafe-restored/.checkpoint-restore-journal.json" ]; then
  echo "unsafe restore modified destination" >&2
  exit 1
fi

printf 'unexpected\n' >"$restored/extra.txt"
if "$harness_root/scripts/verify-checkpoint.sh" "$checkpoint" "$restored" >/dev/null 2>&1; then
  echo "extra workspace content was accepted" >&2
  exit 1
fi
rm "$restored/extra.txt" "$restored/.checkpoint-restore-journal.json"

printf 'changed\n' >"$workspace/file.txt"
if "$harness_root/scripts/verify-checkpoint.sh" "$checkpoint" "$workspace" >/dev/null 2>&1; then
  echo "workspace drift was accepted" >&2
  exit 1
fi

if CHECKPOINT_RISK=high_risk "$harness_root/scripts/create-checkpoint.sh" "$workspace" "$tmp/high-risk" run-high >/dev/null 2>&1; then
  echo "high-risk checkpoint without authority bindings was accepted" >&2
  exit 1
fi
CHECKPOINT_RISK=high_risk CHECKPOINT_SPEC_HASH=spec CHECKPOINT_POLICY_HASH=policy CHECKPOINT_WORKFLOW_STATE_HASH=state CHECKPOINT_EVENT_CHAIN_POSITION=event-1 CHECKPOINT_PENDING_OPERATIONS_HASH=pending "$harness_root/scripts/create-checkpoint.sh" "$workspace" "$tmp/high-risk" run-high >/dev/null

echo "Checkpoint contract regression passed."
