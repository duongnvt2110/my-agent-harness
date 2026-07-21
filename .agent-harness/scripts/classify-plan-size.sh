#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'USAGE' >&2
Usage:
  scripts/classify-plan-size.sh <plan.md>

Classifies a markdown plan as single_task, medium_task, or long_plan using
structural signals. The decision is based on execution/verifiability scope, not
only word count.
USAGE
}

plan_path="${1:-}"
[ -n "$plan_path" ] || { usage; exit 1; }
[ -f "$plan_path" ] || fail "Missing plan file: $plan_path"

python3 - "$plan_path" <<'PY'
import json
import pathlib
import re
import sys

plan_path = pathlib.Path(sys.argv[1])
text = plan_path.read_text(encoding="utf-8")
lines = text.splitlines()
lower = text.lower()

heading_re = re.compile(r"^#{1,6}\s+(.+?)\s*$")
task_bullet_re = re.compile(r"^\s*(?:[-*]|\d+[.)])\s+(?:\[[ xX]\]\s+)?(.+?)\s*$")
file_like_re = re.compile(r"(?:(?:^|\s)(?:scripts|docs|tests|src|app|pkg|cmd|internal|benchmarks|\.agent-harness)/[^\s`'\")]+|[^\s`'\")]+\.(?:sh|py|go|js|ts|json|ya?ml|md))")
command_re = re.compile(r"\b(?:bash|python3?|go test|npm|pnpm|yarn|cargo|pytest|rtk|docker compose)\b")

headings = [m.group(1).strip() for line in lines for m in [heading_re.match(line)] if m]
bullets = [m.group(1).strip() for line in lines for m in [task_bullet_re.match(line)] if m]

feature_words = [
    "add", "fix", "implement", "create", "update", "refactor", "remove",
    "benchmark", "schema", "evaluator", "runner", "history", "workflow",
    "decompose", "verify", "report", "api", "cli", "tests", "metrics",
]
task_like_bullets = [b for b in bullets if any(re.search(rf"\b{re.escape(word)}\b", b.lower()) for word in feature_words)]
module_hits = sorted(set(match.group(0).strip() for match in file_like_re.finditer(text)))
module_roots = sorted(set(hit.split('/')[0] if '/' in hit else pathlib.PurePosixPath(hit).suffix.lstrip('.') for hit in module_hits))
commands = command_re.findall(text)
acceptance_sections = [h for h in headings if "acceptance" in h.lower() or "success" in h.lower()]
workflow_terms = [term for term in ["epic", "story", "task", "dependency", "depends", "phase", "milestone", "workflow"] if term in lower]

score = 0
reasons = []

def add(points: int, reason: str) -> None:
    global score
    score += points
    reasons.append(reason)

if len(task_like_bullets) >= 5:
    add(2, f"contains {len(task_like_bullets)} task-like bullets")
elif len(task_like_bullets) >= 2:
    add(1, f"contains {len(task_like_bullets)} task-like bullets")

if len(module_roots) >= 3:
    add(2, f"touches {len(module_roots)} file/module areas")
elif len(module_roots) >= 2:
    add(1, f"touches {len(module_roots)} file/module areas")

if len(acceptance_sections) >= 2 or lower.count("acceptance") >= 3:
    add(2, "has multiple acceptance/success sections")

if any(term in lower for term in ["depends on", "dependency", "after", "before", "phase 2", "phase ii"]):
    add(2, "mentions dependency or ordering constraints")

verification_terms = sum(1 for term in ["unit test", "integration test", "benchmark", "verify", "verification", "regression", "smoke"] if term in lower)
if verification_terms >= 3:
    add(2, "requires multiple verification concerns")
elif verification_terms >= 1:
    add(1, "mentions verification/testing")

if len(workflow_terms) >= 3:
    add(1, "mentions epic/story/task or workflow concepts")

if len(commands) >= 2:
    add(1, f"mentions {len(commands)} commands/checks")

if len(text.split()) > 900:
    add(1, "large word count")

if score >= 6:
    classification = "long_plan"
elif score >= 3:
    classification = "medium_task"
else:
    classification = "single_task"

recommended_action = {
    "long_plan": "decompose",
    "medium_task": "review_manually_or_decompose",
    "single_task": "activate_as_current_task",
}[classification]

print(json.dumps({
    "schema_version": 1,
    "plan_path": str(plan_path),
    "classification": classification,
    "score": score,
    "recommended_action": recommended_action,
    "signals": {
        "headings": len(headings),
        "bullets": len(bullets),
        "task_like_bullets": len(task_like_bullets),
        "module_areas": module_roots,
        "commands": len(commands),
        "acceptance_sections": len(acceptance_sections),
        "workflow_terms": workflow_terms,
    },
    "reasons": reasons or ["plan is small and has one focused execution scope"],
}, indent=2, sort_keys=True))
PY
