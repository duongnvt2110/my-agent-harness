#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/../.."

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
scripts/check-v3-contract-coverage.sh >/dev/null
python3 - "policies/v3-contract.json" "$tmp/incomplete.json" <<'PY'
import json
import pathlib
import sys

data = json.loads(pathlib.Path(sys.argv[1]).read_text())
data["rules"][0].pop("negative_tests")
pathlib.Path(sys.argv[2]).write_text(json.dumps(data))
PY
if scripts/check-v3-contract-coverage.sh "$tmp/incomplete.json" >/dev/null 2>&1; then
  echo "incomplete contract coverage was accepted" >&2
  exit 1
fi
echo "V3 contract coverage regression passed."
