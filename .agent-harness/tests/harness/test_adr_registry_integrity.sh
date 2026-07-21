#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

python3 - <<'PY'
import json
import pathlib

index_path = pathlib.Path("docs/decisions/adr-index.json")
rows = json.loads(index_path.read_text())
assert rows, "ADR registry must not be empty"
for row in rows:
    assert row.get("id") and row.get("path")
    assert pathlib.Path(row["path"]).is_file(), row["path"]
assert [row["id"] for row in rows] == ["ADR-0004"]
PY

echo 'ADR registry integrity regression passed.'
