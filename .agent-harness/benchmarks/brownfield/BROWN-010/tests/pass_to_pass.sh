#!/usr/bin/env bash
set -euo pipefail
cat > run.json <<'JSON'
{"task_id":"TASK-123","summary":{"result":"pass"}}
JSON
python3 src/repair_report.py run.json report.md
grep -q 'task_id: TASK-123' report.md
grep -q 'result: pass' report.md
