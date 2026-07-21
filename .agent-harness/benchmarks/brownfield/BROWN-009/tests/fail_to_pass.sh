#!/usr/bin/env bash
set -euo pipefail
cat > previous.json <<'JSON'
{"summary":{"total_score":80,"max_score":100,"result":"pass"}}
JSON
cat > current.json <<'JSON'
{"summary":{"total_score":95,"max_score":100,"result":"pass"}}
JSON
python3 src/report.py current.json report.md --previous previous.json
grep -q 'previous_total_score: 80' report.md
grep -q 'delta_score: 15' report.md
grep -q 'trend: improved' report.md
