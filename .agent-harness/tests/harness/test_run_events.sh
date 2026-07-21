#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
run_dir="$tmp/run"
run_id="$(scripts/run-events.sh create "$run_dir" task-1 "$(printf spec | shasum -a 256 | awk '{print $1}')" "$(printf policy | shasum -a 256 | awk '{print $1}')")"
[ -n "$run_id" ]
scripts/run-events.sh append "$run_dir" START '{"role":"Primary"}' >/dev/null
scripts/run-events.sh append "$run_dir" CHECK '{"name":"unit"}' >/dev/null
scripts/run-events.sh verify "$run_dir" >/dev/null
python3 - "$run_dir/events.jsonl" <<'PY'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
rows = [json.loads(line) for line in path.read_text().splitlines()]
rows[1]["sequence"] = 3
path.write_text("\n".join(json.dumps(row, sort_keys=True, separators=(",", ":")) for row in rows) + "\n")
PY
if scripts/run-events.sh verify "$run_dir" >/dev/null 2>&1; then
  echo "corrupt event chain unexpectedly verified" >&2
  exit 1
fi
echo "Run event chain regression passed."
