#!/usr/bin/env bash
set -euo pipefail
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
./scripts/check-release-fixtures --json > "$tmp/result.json"
grep -q '"valid": true' "$tmp/result.json"
grep -q '"fixture_count": 8' "$tmp/result.json"
python3 - "$tmp/bad.json" <<'PY'
import json, pathlib, sys
data=json.loads(pathlib.Path('policies/release-fixtures-v1.json').read_text())
data['fixtures']=data['fixtures'][:-1]
pathlib.Path(sys.argv[1]).write_text(json.dumps(data))
PY
if ./scripts/check-release-fixtures --manifest "$tmp/bad.json" >/dev/null 2>&1; then
  echo 'incomplete fixture manifest was accepted' >&2
  exit 1
fi
echo 'Release fixture inventory regression passed.'
