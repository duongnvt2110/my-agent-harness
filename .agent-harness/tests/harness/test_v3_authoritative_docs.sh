#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

decision="docs/decisions/0004-agent-harness-vnext-authority-model.md"
index="docs/decisions/adr-index.json"
[ -f "$decision" ] || { echo "missing accepted v3 authority decision" >&2; exit 1; }
[ ! -e "docs/decisions/0005-v2-to-v3-explicit-migration-contract.md" ] || {
  echo "removed v2 migration authority decision remains" >&2
  exit 1
}

grep -q 'The repository-local harness is v3-only' "$decision"
grep -q 'There is no v2 authority' "$decision"
grep -q 'Sandboxing, network' "$decision"
if rg -n 'active v2 tasks|v2-authoritative|v2 and v3 implementations|legacy_policy.*v2 remains' "$decision" "$index" >/dev/null; then
  echo "accepted authority docs still describe v2 authority" >&2
  exit 1
fi
if rg -n '0005|v2-to-v3' "$index" >/dev/null; then
  echo "ADR index still exposes the removed v2 migration decision" >&2
  exit 1
fi

python3 - "$index" <<'PY'
import json
import pathlib
import sys

rows = json.loads(pathlib.Path(sys.argv[1]).read_text())
assert all(row["id"] != "ADR-0005" for row in rows)
assert any(row["id"] == "ADR-0004" for row in rows)
PY

echo 'v3 authoritative documentation regression passed.'
