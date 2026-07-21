#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

python3 - "$PLAN_PATH" <<'PY'
import json
import pathlib
import re
import sys

plan_path = pathlib.Path(sys.argv[1])
lines = plan_path.read_text().splitlines()
text = "\n".join(lines)

def fail(message):
    raise SystemExit(message)

def first_index(source_lines, predicate, start=0):
    for idx in range(start, len(source_lines)):
        if predicate(source_lines[idx]):
            return idx
    return None

def section_content(start_heading, end_headings):
    start = first_index(lines, lambda line: line.strip() == start_heading)
    if start is None:
        return None
    end = len(lines)
    for heading in end_headings:
        idx = first_index(lines, lambda line: line.strip() == heading, start + 1)
        if idx is not None and idx < end:
            end = idx
    return lines[start + 1:end]

def section_text(start_heading, end_headings):
    content = section_content(start_heading, end_headings)
    if content is None:
        return None
    return "\n".join(content).strip()

def bullets(content_lines):
    return [line.strip()[2:].strip() for line in content_lines if line.strip().startswith("- ")]

def normalize_word(word):
    word = word.lower()
    if len(word) > 4 and word.endswith("s"):
        word = word[:-1]
    return word

STOPWORDS = {
    "about", "after", "also", "and", "area", "before", "between", "both", "bound",
    "check", "checks", "content", "current", "decompose", "decomposition", "describe",
    "exact", "feature", "gate", "goal", "item", "items", "into", "keep", "make",
    "must", "not", "only", "plan", "plans", "problem", "section", "sections",
    "story", "task", "tasks", "that", "this", "those", "to", "with",
}

PLACEHOLDERS = {
    "Describe the exact outcome.",
    "Describe the user or system problem the task solves.",
    "Describe what is in scope for this task.",
    "Describe what is explicitly out of scope.",
    "List the outcomes that prove the task is complete.",
    "Describe any relevant dependencies or constraints.",
    "<name>",
    "<story>",
    "<task>",
    "<dependency>",
    "<acceptance criterion>",
}

def keywords(text_value):
    tokens = re.findall(r"[A-Za-z][A-Za-z0-9_-]+", text_value.lower())
    out = []
    for token in tokens:
        token = normalize_word(token)
        if len(token) <= 3 or token in STOPWORDS:
            continue
        out.append(token)
    return set(out)

def placeholder_hit(text_value):
    for token in PLACEHOLDERS:
        if token in text_value:
            return token
    return None

required_sections = [
    "## Feature Intake",
    "### Problem",
    "### Scope",
    "### Out of Scope",
    "### Success Criteria",
    "### Dependencies",
    "## Epic / Story / Task Breakdown",
]

for section in required_sections:
    if section not in text:
        fail(f"Missing required section: {section}")

ph = placeholder_hit(text)
if ph:
    fail(f"Placeholder content must be replaced before approval: {ph}")

feature_sections = {
    heading: section_text(heading, ["### Scope", "### Out of Scope", "### Success Criteria", "### Dependencies", "## Epic / Story / Task Breakdown"])
    for heading in ["### Problem", "### Scope", "### Out of Scope", "### Success Criteria", "### Dependencies"]
}

for heading, body in feature_sections.items():
    if body is None or not body.strip():
        fail(f"Missing content under {heading}")
    ph = placeholder_hit(body)
    if ph:
        fail(f"Placeholder content must be replaced before approval: {ph}")

breakdown_text = section_text("## Epic / Story / Task Breakdown", ["## Brownfield Evidence", "## Report Shape", "## Approved Decisions", "## Scope", "## Phases", "## Verification", "## Review", "## Risks"])
if breakdown_text is None or not breakdown_text.strip():
    fail("Epic/story/task breakdown section is empty")

epic_starts = [idx for idx, line in enumerate(lines) if re.match(r"^### Epic [0-9]+: ", line)]
if not epic_starts:
    fail("No epic sections found")

epic_blocks = []
for position, start in enumerate(epic_starts):
    end = epic_starts[position + 1] if position + 1 < len(epic_starts) else len(lines)
    epic_blocks.append(lines[start:end])

task_verbs = ("implement", "update", "add", "remove", "rewrite", "refactor", "wire", "validate", "document", "test", "check")
intake_overlap_score = 0
epic_quality_score = 0
runtime_quality_score = 0
task_quality_score = 0

breakdown_keywords = keywords(breakdown_text)
intake_weights = {
    "### Problem": 4,
    "### Scope": 4,
    "### Out of Scope": 4,
    "### Success Criteria": 4,
    "### Dependencies": 4,
}

for heading, body in feature_sections.items():
    body_keywords = keywords(body)
    overlap = len(body_keywords & breakdown_keywords)
    if overlap == 0:
        fail(f"Intake section '{heading}' has no semantic link to the epic/story/task breakdown")
    intake_overlap_score += intake_weights[heading]

for idx, block in enumerate(epic_blocks, start=1):
    block_text = "\n".join(block)
    if not any(line.strip() == "Dependencies:" for line in block):
        fail(f"Epic {idx} missing Dependencies block")
    if not any(line.strip() == "Acceptance Criteria:" for line in block):
        fail(f"Epic {idx} missing Acceptance Criteria block")
    if not any(line.strip() == "Stories:" for line in block):
        fail(f"Epic {idx} missing Stories block")
    if not any(line.strip() == "Tasks:" for line in block):
        fail(f"Epic {idx} missing Tasks block")

    deps_start = first_index(block, lambda line: line.strip() == "Dependencies:", 0)
    acc_start = first_index(block, lambda line: line.strip() == "Acceptance Criteria:", 0)
    stories_start = first_index(block, lambda line: line.strip() == "Stories:", 0)
    tasks_start = first_index(block, lambda line: line.strip() == "Tasks:", 0)

    if None in {deps_start, acc_start, stories_start, tasks_start}:
        fail(f"Epic {idx} is missing one or more required sections")

    if not (deps_start < acc_start < stories_start < tasks_start):
        fail(f"Epic {idx} sections are not in the expected order")

    def section_slice(start, end):
        return block[start + 1:end]

    deps_lines = section_slice(deps_start, acc_start)
    acc_lines = section_slice(acc_start, stories_start)
    stories_lines = section_slice(stories_start, tasks_start)
    tasks_lines = section_slice(tasks_start, len(block))

    deps_bullets = bullets(deps_lines)
    acc_bullets = bullets(acc_lines)
    story_bullets = bullets(stories_lines)
    task_bullets = bullets(tasks_lines)

    if not deps_bullets:
        fail(f"Epic {idx} has no dependency bullets")
    if not acc_bullets:
        fail(f"Epic {idx} has no acceptance-criteria bullets")
    if not story_bullets:
        fail(f"Epic {idx} has no story bullets")
    if not task_bullets:
        fail(f"Epic {idx} has no task bullets")

    for section_name, bullets_list, bad_words in [
        ("Dependencies", deps_bullets, {"tbd", "todo", "placeholder", "describe"}),
        ("Acceptance Criteria", acc_bullets, {"works", "done", "good", "tbd", "todo"}),
        ("Stories", story_bullets, {"<story>", "describe the story."}),
        ("Tasks", task_bullets, {"<task>", "describe the task."}),
    ]:
        for bullet in bullets_list:
            lowered = bullet.lower()
            if not bullet.strip():
                fail(f"Epic {idx} has an empty {section_name} bullet")
            if bullet in PLACEHOLDERS:
                fail(f"Epic {idx} contains placeholder {section_name} content: {bullet!r}")
            if any(word in lowered for word in bad_words):
                fail(f"Epic {idx} contains weak {section_name} content: {bullet!r}")

    for task in task_bullets:
        lowered = task.lower()
        verb_hits = sum(1 for verb in task_verbs if re.search(rf"\b{re.escape(verb)}\b", lowered))
        if verb_hits >= 3:
            fail(f"Epic {idx} task appears mixed-scope: {task!r}")
        if len(task.split()) > 18:
            fail(f"Epic {idx} task is too long and likely too broad: {task!r}")

    epic_keywords = keywords("\n".join(block))
    if len(epic_keywords & breakdown_keywords) == 0:
        fail(f"Epic {idx} has no semantic overlap with the plan breakdown")

    epic_quality_score += 20
    if len(deps_bullets) > 0:
        epic_quality_score += 2
    if len(acc_bullets) > 0:
        epic_quality_score += 2
    if len(story_bullets) > 0:
        epic_quality_score += 2
    if len(task_bullets) > 0:
        epic_quality_score += 2

    if any(re.search(r"\b(depends on|blocked by|requires|before|after)\b", bullet.lower()) for bullet in deps_bullets):
        epic_quality_score += 4
    if all(len(bullet.split()) <= 14 for bullet in acc_bullets):
        epic_quality_score += 4

    if any(task.lower().startswith(("implement ", "update ", "add ", "validate ", "wire ", "document ")) for task in task_bullets):
        task_quality_score += 10
    if all(sum(1 for verb in task_verbs if re.search(rf"\b{re.escape(verb)}\b", task.lower())) < 3 for task in task_bullets):
        task_quality_score += 10

frontmatter = {}
in_frontmatter = False
for line in lines:
    if line.strip() == "---":
        in_frontmatter = not in_frontmatter
        continue
    if not in_frontmatter:
        continue
    if ":" not in line:
        continue
    key, value = line.split(":", 1)
    frontmatter[key.strip()] = value.strip()

runtime_refs = [
    frontmatter.get("epic_path"),
    frontmatter.get("story_registry"),
    frontmatter.get("epic_memory"),
    frontmatter.get("epic_progress"),
]
runtime_refs = [value for value in runtime_refs if value and value != "null"]
if runtime_refs:
    for ref in runtime_refs:
        ref_path = pathlib.Path(ref)
        if not ref_path.exists():
            fail(f"Runtime consistency check failed: missing referenced path {ref}")
    runtime_quality_score = 20
else:
    runtime_quality_score = 20

orphan_score = 20
for heading, body in feature_sections.items():
    body_keywords = keywords(body)
    overlap = len(body_keywords & breakdown_keywords)
    if overlap < 1:
        orphan_score = 0

acceptance_score = 20 if any(line.strip() == "Acceptance Criteria:" for block in epic_blocks for line in block) else 0

score = min(100, intake_overlap_score + epic_quality_score + task_quality_score + runtime_quality_score + orphan_score + acceptance_score)
if score < 80:
    fail(f"Plan decomposition semantic score too low: {score}/100")

print(f"Plan decomposition semantic checks passed (score={score}/100).")
PY
