#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
printf '{"requirement":"ship"}\n' > "$tmp/requirements.json"
cat > "$tmp/spec-lock.json" <<'EOF'
{"kind":"SPEC_LOCK","spec_hash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
EOF
cat > "$tmp/graph.json" <<'EOF'
{"acceptance_criteria":[{"ac_id":"AC-1","blocking":true},{"ac_id":"AC-2","blocking":true}],"tasks":[{"task_id":"T-1","ac_ids":["AC-1"],"check_ids":["C-1"],"depends_on":[]},{"task_id":"T-2","ac_ids":["AC-2"],"check_ids":["C-2"],"depends_on":["T-1"]}]}
EOF
if scripts/intake-graph.sh create "$tmp/requirements.json" "$tmp/spec-lock.json" "$tmp/graph.json" "$tmp/direct-intake.json" >/dev/null 2>&1; then
  echo "direct intake-graph authority creation was accepted" >&2
  exit 1
fi
python3 - "$tmp/intake.json" <<'PY'
import json, pathlib, sys
graph = {"acceptance_criteria":[{"ac_id":"AC-1","blocking":True},{"ac_id":"AC-2","blocking":True}],"tasks":[{"task_id":"T-1","ac_ids":["AC-1"],"check_ids":["C-1"],"depends_on":[]},{"task_id":"T-2","ac_ids":["AC-2"],"check_ids":["C-2"],"depends_on":["T-1"]}]}
pathlib.Path(sys.argv[1]).write_text(json.dumps({"kind":"INTAKE","schema_version":1,"canonicalization_version":1,"intake_id":"I-1","requirements_hash":"hash","spec_hash":"a"*64,"graph":graph}) + "\n")
PY
scripts/intake-graph.sh verify "$tmp/intake.json" >/dev/null
grep -q '"tasks": \["T-1", "T-2"\]' <(scripts/intake-graph.sh impact "$tmp/intake.json" AC-1)
echo "Intake graph regression passed."
