#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

usage() {
  cat <<'USAGE' >&2
Usage:
  scripts/decompose-plan.sh <implementation-plan.md> [--epic <epic_id>] [--title <title>]

Consumes a long implementation plan, classifies it, and creates a structured
backlog outside docs/exec-plans/active/current.md:
  docs/intake/
  docs/epics/<epic_id>/
  docs/tasks/tasks.jsonl
  docs/tasks/<task_id>/
  docs/reports/plan-decomposition.md
USAGE
}

plan_path="${1:-}"
[ -n "$plan_path" ] || { usage; exit 1; }
[ -f "$plan_path" ] || fail "Missing implementation plan: $plan_path"
shift || true

epic_id=""
title=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --epic)
      epic_id="${2:-}"
      [ -n "$epic_id" ] || fail "--epic requires an id"
      shift 2
      ;;
    --title)
      title="${2:-}"
      [ -n "$title" ] || fail "--title requires a title"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

classification_json="$(mktemp)"
trap 'rm -f "$classification_json"' EXIT
./scripts/classify-plan-size.sh "$plan_path" > "$classification_json"

python3 - "$plan_path" "$classification_json" "$epic_id" "$title" <<'PY'
from __future__ import annotations

import datetime as dt
import json
import pathlib
import re
import shutil
import sys
from collections import defaultdict

plan_path = pathlib.Path(sys.argv[1]).resolve()
classification_path = pathlib.Path(sys.argv[2])
forced_epic_id = sys.argv[3].strip()
forced_title = sys.argv[4].strip()
classification = json.loads(classification_path.read_text())

root = pathlib.Path.cwd()
docs = root / "docs"
intake_root = pathlib.Path(__import__("os").environ.get("PLAN_INTAKE_ROOT", str(docs / "intake")))
epic_root = pathlib.Path(__import__("os").environ.get("EPIC_ROOT", str(docs / "epics")))
task_root = pathlib.Path(__import__("os").environ.get("TASK_ROOT", str(docs / "tasks")))
report_root = pathlib.Path(__import__("os").environ.get("REPORT_ROOT", str(docs / "reports")))

text = plan_path.read_text(encoding="utf-8")
lines = text.splitlines()


def slugify(value: str, fallback: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"[`*_\[\](){}:;,.!?/\\]+", " ", value)
    value = re.sub(r"[^a-z0-9]+", "_", value)
    value = re.sub(r"_+", "_", value).strip("_")
    return value[:64] or fallback


def unique(base: str, used: set[str]) -> str:
    candidate = base
    idx = 2
    while candidate in used:
        candidate = f"{base}_{idx}"
        idx += 1
    used.add(candidate)
    return candidate


def strip_marker(line: str) -> str:
    value = re.sub(r"^\s*(?:[-*]|\d+[.)])\s+(?:\[[ xX]\]\s+)?", "", line).strip()
    value = re.sub(r"^(?:task|story|epic)\s*[:\-]\s*", "", value, flags=re.I)
    return value


def first_heading() -> str:
    for line in lines:
        m = re.match(r"^#\s+(.+?)\s*$", line)
        if m:
            return m.group(1).strip()
    return forced_title or plan_path.stem.replace("-", " ").replace("_", " ").title()

plan_title = forced_title or first_heading()
epic_id = forced_epic_id or slugify(plan_title, "implementation_plan")
if not epic_id.endswith("_epic"):
    epic_id = f"{epic_id}_epic"

# Parse explicitly structured markdown if present.
epics: list[dict] = []
current_epic: dict | None = None
current_story: dict | None = None
used_task_titles: set[str] = set()

def ensure_epic(title: str | None = None) -> dict:
    global current_epic, current_story
    if current_epic is None:
        current_epic = {"title": title or plan_title, "stories": []}
        epics.append(current_epic)
    return current_epic


def ensure_story(title: str | None = None) -> dict:
    global current_story
    epic = ensure_epic()
    if current_story is None:
        current_story = {"title": title or "Implementation tasks", "tasks": []}
        epic["stories"].append(current_story)
    return current_story

for raw in lines:
    line = raw.rstrip()
    heading = re.match(r"^(#{2,6})\s+(.+?)\s*$", line)
    if heading:
        level = len(heading.group(1))
        body = heading.group(2).strip()
        if re.match(r"^epic\b", body, flags=re.I):
            title = re.sub(r"^epic\s*\d*\s*[:\-]?\s*", "", body, flags=re.I).strip() or plan_title
            current_epic = {"title": title, "stories": []}
            epics.append(current_epic)
            current_story = None
            continue
        if re.match(r"^story\b", body, flags=re.I):
            title = re.sub(r"^story\s*\d*\s*[:\-]?\s*", "", body, flags=re.I).strip() or "Implementation story"
            current_story = {"title": title, "tasks": []}
            ensure_epic()["stories"].append(current_story)
            continue
        if re.match(r"^task\b", body, flags=re.I):
            title = re.sub(r"^task\s*\d*\s*[:\-]?\s*", "", body, flags=re.I).strip()
            if title:
                ensure_story()["tasks"].append(title)
                used_task_titles.add(title)
            continue
    bullet = re.match(r"^\s*(?:[-*]|\d+[.)])\s+(?:\[[ xX]\]\s+)?(.+?)\s*$", line)
    if bullet:
        value = strip_marker(line)
        if not value:
            continue
        if re.match(r"^epic\b", value, flags=re.I):
            title = re.sub(r"^epic\s*\d*\s*[:\-]?\s*", "", value, flags=re.I).strip() or plan_title
            current_epic = {"title": title, "stories": []}
            epics.append(current_epic)
            current_story = None
            continue
        if re.match(r"^story\b", value, flags=re.I):
            title = re.sub(r"^story\s*\d*\s*[:\-]?\s*", "", value, flags=re.I).strip() or "Implementation story"
            current_story = {"title": title, "tasks": []}
            ensure_epic()["stories"].append(current_story)
            continue
        if re.match(r"^(?:add|fix|implement|create|update|refactor|remove|validate|verify|benchmark|wire|split)\b", value, flags=re.I):
            ensure_story()["tasks"].append(value)
            used_task_titles.add(value)

# If the plan is a numbered feature list with no explicit stories, use all task-like bullets.
if not any(story.get("tasks") for epic in epics for story in epic.get("stories", [])):
    task_candidates = []
    for raw in lines:
        if re.match(r"^\s*(?:[-*]|\d+[.)])\s+", raw):
            value = strip_marker(raw)
            if re.match(r"^(?:add|fix|implement|create|update|refactor|remove|validate|verify|benchmark|wire|split)\b", value, flags=re.I):
                task_candidates.append(value)
    if not task_candidates:
        task_candidates = [plan_title]
    epics = [{"title": plan_title, "stories": []}]
    for idx in range(0, len(task_candidates), 3):
        story_title = "Implementation slice " + str((idx // 3) + 1)
        epics[0]["stories"].append({"title": story_title, "tasks": task_candidates[idx:idx+3]})

# Normalize to one epic directory for the requested long-plan source. If multiple explicit epics exist,
# preserve them as stories under this root epic to keep activation predictable for the harness MVP.
all_stories = []
for epic in epics:
    for story in epic.get("stories", []):
        if story.get("tasks"):
            all_stories.append(story)
if not all_stories:
    all_stories = [{"title": "Implementation tasks", "tasks": [plan_title]}]

intake_root.mkdir(parents=True, exist_ok=True)
epic_root.mkdir(parents=True, exist_ok=True)
task_root.mkdir(parents=True, exist_ok=True)
report_root.mkdir(parents=True, exist_ok=True)

intake_copy = intake_root / plan_path.name
shutil.copy2(plan_path, intake_copy)

epic_dir = epic_root / epic_id
epic_dir.mkdir(parents=True, exist_ok=True)

(epic_dir / "epic.md").write_text(f"""# Epic: {plan_title}

## Source Plan

`{intake_copy}`

## Goal

Deliver the decomposed implementation plan through one-task-at-a-time execution.

## Non-Goals

Do not place the full epic/story/task tree inside `docs/exec-plans/active/current.md`.

## Acceptance Summary

- The long plan is decomposed into stories and executable tasks.
- Each task has acceptance criteria, approved file scope, and required checks.
- One READY task can be activated into `current.md` without carrying the full roadmap.
""", encoding="utf-8")

for name, content in {
    "epic-memory.md": "# Epic Memory\n\n## Stable Decisions\n\n- Long plans are stored in docs/intake/.\n- current.md contains one active task only.\n",
    "integration-contract.md": "# Integration Contract\n\n## Execution Contract\n\nEvery decomposed task must carry acceptance criteria, approved files/scopes, and required checks.\n",
    "clarifications.md": "# Clarifications\n\n## Blocking Questions\n\nNone recorded by automated decomposition.\n",
}.items():
    path = epic_dir / name
    if not path.exists():
        path.write_text(content, encoding="utf-8")

used_story_ids: set[str] = set()
used_task_ids: set[str] = set()
story_records = []
task_records = []

for story_index, story in enumerate(all_stories, start=1):
    story_title = story.get("title") or f"Implementation slice {story_index}"
    story_id = unique(slugify(story_title, f"story_{story_index}"), used_story_ids)
    task_ids = []
    acceptance = [f"All child tasks for {story_title} are DONE", "Story-level verification passes"]
    story_records.append({
        "id": story_id,
        "title": story_title,
        "status": "READY",
        "depends_on": [],
        "acceptance": acceptance,
        "required_checks": ["bash .agent-harness/harness.sh benchmark --no-history"],
        "notes": "generated from long implementation plan",
    })
    for task_index, task_title in enumerate(story.get("tasks", []), start=1):
        base = slugify(task_title, f"task_{story_index}_{task_index}")
        task_id = unique(base, used_task_ids)
        task_ids.append(task_id)
        task_dir = task_root / task_id
        task_dir.mkdir(parents=True, exist_ok=True)
        approved_scopes = ["harness_core", "harness_docs", "app_tests"]
        approved_files = []
        if any(term in task_title.lower() for term in ["benchmark", "brownfield", "greenfield", "fixture", "schema", "evaluator", "metrics", "history"]):
            approved_files.append(".agent-harness/benchmarks/**")
        if any(term in task_title.lower() for term in ["test", "verify", "regression"]):
            approved_files.append(".agent-harness/tests/**")
        acceptance_criteria = [
            f"Implement: {task_title}",
            "Required checks pass",
            "Changes stay inside approved scopes/files",
        ]
        required_checks = [
            {"id": "task-benchmark", "type": "automated", "command": "rtk ./scripts/harness.sh benchmark --no-history --timeout 60", "blocking": True, "timeout_seconds": 180, "covers": ["AC-001"], "evidence": f"docs/evidence/{task_id}/benchmark.md"}
        ]
        implementation_plan_path = task_dir / "implementation-plan.md"
        implementation_plan_path.write_text(f"""# Task Implementation Plan: {task_title}

## Source Plan

`{intake_copy}`

## Parent

- epic_id: `{epic_id}`
- story_id: `{story_id}`

## Goal

{task_title}

## Acceptance Criteria

""" + "\n".join(f"- {item}" for item in acceptance_criteria) + "\n\n## Required Checks\n\n" + "\n".join(f"- `{check['command']}`" for check in required_checks) + "\n", encoding="utf-8")
        (task_dir / "acceptance.md").write_text("# Acceptance Criteria\n\n" + "\n".join(f"- {item}" for item in acceptance_criteria) + "\n", encoding="utf-8")
        (task_dir / "file-map.md").write_text("# File Map\n\n## Approved Scopes\n\n" + "\n".join(f"- {item}" for item in approved_scopes) + "\n\n## Approved Files\n\n" + ("\n".join(f"- {item}" for item in approved_files) if approved_files else "- None") + "\n", encoding="utf-8")
        task_records.append({
            "id": task_id,
            "epic_id": epic_id,
            "story_id": story_id,
            "title": task_title,
            "status": "READY",
            "depends_on": [],
            "priority": "normal",
            "lane": "normal",
            "source_plan_path": str(intake_copy),
            "implementation_plan_path": str(implementation_plan_path),
            "approved_scopes": approved_scopes,
            "approved_files": approved_files,
            "acceptance_criteria": acceptance_criteria,
            "required_checks": required_checks,
            "size": "small" if len(task_title.split()) <= 10 else "medium",
            "risk": "medium",
            "ready_reason": "generated from long implementation plan",
        })
    story_records[-1]["tasks"] = task_ids

(epic_dir / "stories.jsonl").write_text("".join(json.dumps(row, separators=(",", ":")) + "\n" for row in story_records), encoding="utf-8")

# Merge records by task id while preserving existing unrelated tasks.
task_store = pathlib.Path(__import__("os").environ.get("TASK_STORE", str(task_root / "tasks.jsonl")))
task_store.parent.mkdir(parents=True, exist_ok=True)
existing = []
if task_store.exists():
    for line in task_store.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if row.get("id") not in {record["id"] for record in task_records}:
            existing.append(row)
task_store.write_text("".join(json.dumps(row, separators=(",", ":")) + "\n" for row in existing + task_records), encoding="utf-8")

progress = epic_dir / "progress.md"
progress.write_text(f"""# Epic Progress

## Status

READY

## Source Plan

`{intake_copy}`

## Stories

""" + "\n".join(f"- {row['id']}: READY" for row in story_records) + "\n\n## Next Candidate Tasks\n\n" + "\n".join(f"- {row['id']}: {row['title']}" for row in task_records[:10]) + "\n", encoding="utf-8")

report = report_root / "plan-decomposition.md"
report.write_text(f"""# Plan Decomposition Report

generated_at: {dt.datetime.now().strftime('%Y-%m-%d %H:%M')}
source_plan: `{plan_path}`
intake_copy: `{intake_copy}`
classification: `{classification.get('classification')}`
classification_score: {classification.get('score')}
recommended_action: `{classification.get('recommended_action')}`
epic_id: `{epic_id}`
stories: {len(story_records)}
tasks: {len(task_records)}

## Reasons

""" + "\n".join(f"- {reason}" for reason in classification.get("reasons", [])) + "\n\n## Tasks\n\n" + "\n".join(f"- `{row['id']}` — {row['title']}" for row in task_records) + "\n", encoding="utf-8")

print(f"Decomposed plan: {plan_path}")
print(f"Classification: {classification.get('classification')} score={classification.get('score')}")
print(f"Epic: {epic_id}")
print(f"Stories: {len(story_records)}")
print(f"Tasks: {len(task_records)}")
print(f"Report: {report}")
PY
