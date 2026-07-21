#!/usr/bin/env bash
set -euo pipefail
cat > run.json <<'JSON'
{"task_id":"TASK-123","summary":{"result":"pass"},"final_status":"verified","repair_attempts":[{"failure_reason":"test_failed"},{"failure_reason":"file_scope_violation"}]}
JSON
python3 src/repair_report.py run.json report.md
grep -q 'repair_attempts: 2' report.md
grep -q 'last_failure_reason: file_scope_violation' report.md
grep -q 'final_status: verified' report.md
