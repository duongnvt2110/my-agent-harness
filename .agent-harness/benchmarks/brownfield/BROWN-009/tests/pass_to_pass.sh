#!/usr/bin/env bash
set -euo pipefail
cat > current.json <<'JSON'
{"summary":{"total_score":95,"max_score":100,"result":"pass"}}
JSON
python3 src/report.py current.json report.md
grep -q 'total_score: 95' report.md
grep -q 'result: pass' report.md
