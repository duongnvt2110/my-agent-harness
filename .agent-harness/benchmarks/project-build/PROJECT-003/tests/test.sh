#!/usr/bin/env bash
set -euo pipefail
cat > app.jsonl <<'JSONL'
{"status":200,"latency_ms":10}
{"status":503,"latency_ms":30}
{"level":"error","status":200,"latency_ms":20}
JSONL
python3 src/log_analyzer.py app.jsonl --output summary.json
python3 - <<'PY'
import json
from pathlib import Path
row=json.loads(Path('summary.json').read_text())
assert row == {'avg_latency_ms':20.0,'count':3,'errors':2}, row
PY
