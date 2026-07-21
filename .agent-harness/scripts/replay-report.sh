#!/usr/bin/env bash
set -euo pipefail

input="${1:-}"
output="${2:-}"
[ -f "$input" ] && [ -n "$output" ] || {
  echo "Usage: $0 RUN-INPUT.json OUTPUT.json" >&2
  exit 2
}

python3 - "$input" "$output" <<'PY'
import hashlib
import json
import pathlib
import re
import sys
import uuid

source = pathlib.Path(sys.argv[1])
destination = pathlib.Path(sys.argv[2])
data = json.loads(source.read_text())
raw = source.read_bytes()
secret = re.compile(r"(?i)(token|password|secret|api[_-]?key|authorization)\s*[:=]\s*[^,\s]+")

def redact(value):
    if isinstance(value, dict):
        return {key: redact(item) for key, item in value.items()}
    if isinstance(value, list):
        return [redact(item) for item in value]
    if isinstance(value, str):
        return secret.sub(lambda match: match.group(1) + ": [REDACTED]", value)
    return value

redacted = redact(data)
known_solution = bool(data.get("known_solution_used", False))
verifier = data.get("verifier", {})
conformance = data.get("conformance", {})
agent_result = data.get("agent_result", {})
report = {
    "schema_version": 1,
    "replay_id": str(uuid.uuid4()),
    "run_id": data.get("run_id", "unknown"),
    "task_id": data.get("task_id", "unknown"),
    "input_sha256": hashlib.sha256(raw).hexdigest(),
    "redaction": {"applied": True, "pattern_version": "v1"},
    "conformance": {
        "status": conformance.get("status", "UNKNOWN"),
        "checks": conformance.get("checks", []),
        "source": "harness",
    },
    "agent_capability": {
        "status": "NOT_MEASURED" if known_solution else agent_result.get("status", "UNKNOWN"),
        "source": "agent_task",
        "known_solution_excluded": known_solution,
    },
    "verifier_outcome": {
        "verdict": verifier.get("verdict", "UNKNOWN"),
        "verification_id": verifier.get("verification_id", ""),
        "source": "harness_verification",
    },
    "artifacts": {
        "context_manifest_sha256": data.get("context_manifest_sha256", ""),
        "verifier_sha256": data.get("verifier_sha256", ""),
    },
    "redacted_input": redacted,
}
destination.parent.mkdir(parents=True, exist_ok=True)
destination.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
print(json.dumps({"status": "generated", "output": str(destination), "input_sha256": report["input_sha256"]}, sort_keys=True))
PY
