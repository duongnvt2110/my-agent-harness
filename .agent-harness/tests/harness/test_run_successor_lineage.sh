#!/usr/bin/env bash
set -euo pipefail
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
./scripts/run-events.sh create "$tmp/prior" task-1 spec-1 policy-1 >/dev/null
./scripts/run-events.sh create "$tmp/successor" task-1 spec-1 policy-1 "$tmp/prior/run.json" >/dev/null
python3 - "$tmp/successor/run.json" "$tmp/prior/run.json" <<'PY'
import json, pathlib, sys
successor=json.loads(pathlib.Path(sys.argv[1]).read_text()); prior=json.loads(pathlib.Path(sys.argv[2]).read_text())
assert successor['supersedes_run_id']==prior['run_id']
assert successor['supersedes_run_hash']
assert successor['lineage_hash']
PY
./scripts/run-events.sh verify "$tmp/successor" >/dev/null
if ./scripts/run-events.sh create "$tmp/bad" task-1 spec-OTHER policy-1 "$tmp/prior/run.json" >/dev/null 2>&1; then exit 1; fi
echo 'Run successor lineage regression passed.'
