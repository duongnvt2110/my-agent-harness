#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"

bash "$harness_root/scripts/benchmark.sh" --no-history --output "$tmp/latest.json" --markdown "$tmp/latest.md" --history "$tmp/history.jsonl" --timeout 60 > "$tmp/out.txt" 2>&1
cat "$tmp/out.txt"

grep -q 'Benchmark result: pass 140/140' "$tmp/out.txt"
[ -f "$tmp/latest.json" ]
[ -f "$tmp/latest.md" ]
[ ! -s "$tmp/history.jsonl" ] || {
  echo "--no-history should not append history" >&2
  exit 1
}

python3 - "$tmp/latest.json" <<'PY'
import json
import sys
from pathlib import Path
result=json.loads(Path(sys.argv[1]).read_text())
assert result['schema_version'] == 1
assert result['summary']['result'] == 'pass'
assert result['summary']['total_score'] == 140
ids={row['id'] for row in result['benchmarks']}
required={'BENCH-001','BENCH-002','BENCH-003','BENCH-004','BENCH-005','BENCH-006','BENCH-007','BENCH-008','BENCH-009','BENCH-010'}
missing=required-ids
assert not missing, missing
projects=next(row for row in result['benchmarks'] if row['id']=='BENCH-002')['metrics']['projects']
assert {p['id'] for p in projects} == {'PROJECT-001','PROJECT-002','PROJECT-003','PROJECT-004','PROJECT-005'}
assert all(p['result']=='pass' for p in projects)
brownfield=next(row for row in result['benchmarks'] if row['id']=='BENCH-009')['metrics']['tasks']
assert {t['id'] for t in brownfield} == {'BROWN-006','BROWN-007','BROWN-008','BROWN-009','BROWN-010'}
assert all(t['result']=='pass' for t in brownfield)
PY

grep -q 'PROJECT-001: pass' "$tmp/latest.md"
grep -q 'BROWN-010: pass' "$tmp/latest.md"
grep -q 'trend: first_run' "$tmp/latest.md"

echo "Benchmark suite regression passed."
