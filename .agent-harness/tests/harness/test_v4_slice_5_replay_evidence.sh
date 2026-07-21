#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
reporter="$repo_root/.agent-harness/scripts/replay-report.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/input.json" <<'EOF'
{
  "run_id": "replay-1",
  "task_id": "task-1",
  "known_solution_used": true,
  "agent_result": {"status": "PASSED", "message": "agent passed"},
  "conformance": {"status": "PASSED", "checks": ["contract", "evidence"]},
  "verifier": {"verdict": "PASSED", "verification_id": "verification-1"},
  "context_manifest_sha256": "context-hash",
  "verifier_sha256": "verifier-hash",
  "notes": "authorization: bearer-secret-value"
}
EOF

"$reporter" "$tmp/input.json" "$tmp/report.json" >/dev/null
python3 - "$tmp/report.json" <<'PY'
import json, pathlib, sys
report = json.loads(pathlib.Path(sys.argv[1]).read_text())
assert report["conformance"]["status"] == "PASSED", report
assert report["conformance"]["source"] == "harness", report
assert report["agent_capability"]["status"] == "NOT_MEASURED", report
assert report["agent_capability"]["known_solution_excluded"] is True, report
assert report["verifier_outcome"]["verdict"] == "PASSED", report
assert report["redaction"]["applied"] is True, report
assert "bearer-secret-value" not in json.dumps(report), report
assert "[REDACTED]" in json.dumps(report), report
assert report["input_sha256"], report
PY

echo "v4 Slice 5 honest evaluation and replay evidence regression passed."
