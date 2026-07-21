#!/usr/bin/env bash
set -euo pipefail
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
grep -q 'check-release-fixtures' scripts/release-invariants.sh
./scripts/check-release-fixtures --json >/dev/null

python3 - "${tmp}/bad.json" <<'PY'
import json, pathlib, sys
data=json.loads(pathlib.Path('policies/release-fixtures-v1.json').read_text())
data['required_fixture_ids'].append('MISSING-RELEASE-FIXTURE')
pathlib.Path(sys.argv[1]).write_text(json.dumps(data))
PY
if ./scripts/check-release-fixtures --manifest "$tmp/bad.json" >/dev/null 2>&1; then
  echo 'release invariant fixture audit accepted missing fixture' >&2
  exit 1
fi
echo 'Release invariant fixture gate regression passed.'
