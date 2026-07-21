#!/usr/bin/env bash
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
printf '{"requirement":"dependency"}\n' > "$tmp/requirements.json"
printf '{"kind":"SPEC_LOCK","spec_hash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}\n' > "$tmp/spec-lock.json"
cat > "$tmp/graph.json" <<'JSON'
{"acceptance_criteria":[{"ac_id":"AC-1","blocking":true},{"ac_id":"AC-2","blocking":true}],"tasks":[{"task_id":"producer","ac_ids":["AC-1"],"check_ids":["C-1"],"depends_on":[]},{"task_id":"consumer","ac_ids":["AC-2"],"check_ids":["C-2"],"depends_on":["producer"],"dependency_consumption":{"producer":{"mode":"EARLY_ARTIFACT","artifact_hash":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","artifact_version":"v1","contract_hash":"contract-v1","freshness":"until-producer-rollback","rollback_semantics":"invalidate-consumer"}}}]}
JSON

# Creation through the retired v2 authority must remain denied.
if scripts/intake-graph.sh create "$tmp/requirements.json" "$tmp/spec-lock.json" "$tmp/graph.json" "$tmp/retired.json" >"$tmp/retired.out" 2>&1; then
  echo "retired intake-graph creation unexpectedly succeeded" >&2
  exit 1
fi
grep -q 'authority creation is retired in v3' "$tmp/retired.out"

# Verification still protects historical/imported graph artifacts.
python3 - "$tmp/requirements.json" "$tmp/spec-lock.json" "$tmp/graph.json" "$tmp/intake.json" <<'PY'
import hashlib
import json
import pathlib
import sys

requirements = json.loads(pathlib.Path(sys.argv[1]).read_text())
spec_lock = json.loads(pathlib.Path(sys.argv[2]).read_text())
graph = json.loads(pathlib.Path(sys.argv[3]).read_text())
canonical = json.dumps(requirements, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n"
record = {
    "schema_version": 1,
    "canonicalization_version": 1,
    "kind": "INTAKE",
    "intake_id": "dependency-artifact-contract",
    "requirements_hash": hashlib.sha256(canonical.encode()).hexdigest(),
    "spec_hash": spec_lock["spec_hash"],
    "graph": graph,
}
pathlib.Path(sys.argv[4]).write_text(json.dumps(record, sort_keys=True, indent=2) + "\n")
PY
scripts/intake-graph.sh verify "$tmp/intake.json" >/dev/null

python3 - "$tmp/intake.json" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["graph"]["tasks"][1]["dependency_consumption"]["producer"].pop("rollback_semantics")
path.write_text(json.dumps(data, sort_keys=True, indent=2) + "\n")
PY
if scripts/intake-graph.sh verify "$tmp/intake.json" >/dev/null 2>&1; then
  echo "incomplete early artifact contract unexpectedly accepted" >&2
  exit 1
fi

echo "Dependency artifact contract regression passed."
