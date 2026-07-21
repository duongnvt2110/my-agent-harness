#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/../.." && pwd)"

for command in migrate-v2-v3 network-capability run-in-sandbox network-request verifier-adapter signed-release deploy; do
  if "$root/harness.sh" "$command" >/dev/null 2>&1; then
    echo "excluded command was accepted: $command" >&2
    exit 1
  fi
done

for script in migrate-v2-v3 network-capability run-in-sandbox network-request verifier-adapter; do
  if [ -e "$root/scripts/$script" ]; then
    echo "excluded authority script remains: $script" >&2
    exit 1
  fi
done

metadata="$root/runtime/v3-workflow.json"
python3 - "$metadata" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
if data.get("workflow_version") != "v3" or data.get("implementation_version") != "v3-core":
    raise SystemExit("active workflow is not v3-core")
if data.get("mixed_artifacts") or data.get("migration_required"):
    raise SystemExit("active workflow permits mixed or migrated artifacts")
PY

echo "v3 scope-exclusion regression passed."
