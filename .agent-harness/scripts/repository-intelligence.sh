#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

repo_intel_root="${REPO_INTELLIGENCE_ROOT:-docs/context/repository-intelligence}"
repo_scan_root="${REPO_SCAN_ROOT:-$HARNESS_REPO_ROOT}"
if [[ "$repo_scan_root" != /* ]]; then
  if [ -n "${REPO_SCAN_ROOT:-}" ] && [ -d "$HARNESS_ROOT/$repo_scan_root" ]; then
    # Preserve v3 callers that pass fixture paths relative to the harness.
    repo_scan_root="$HARNESS_ROOT/$repo_scan_root"
  else
    repo_scan_root="$HARNESS_REPO_ROOT/$repo_scan_root"
  fi
fi
repo_scan_root="$(cd "$repo_scan_root" && pwd -P)"
case "$repo_scan_root" in
  "$HARNESS_REPO_ROOT"|"$HARNESS_REPO_ROOT"/*) ;;
  *) fail "Repository scan root is outside the declared repository: $repo_scan_root" ;;
esac

plan_value() {
  if [ -n "${PLAN_PATH:-}" ] && [ -f "$PLAN_PATH" ]; then
    fm_value "$PLAN_PATH" "$1"
  else
    printf '%s' ""
  fi
}

normalize() {
  local value="${1:-}"
  if [ -z "$value" ] || [ "$value" = "null" ]; then
    printf '%s' ""
  else
    printf '%s' "$value"
  fi
}

repo_mode() {
  normalize "$(plan_value repo_mode)"
}

task_change_type() {
  normalize "$(plan_value task_change_type)"
}

task_touches_existing_behavior() {
  normalize "$(plan_value task_touches_existing_behavior)"
}

task_backward_compatibility_required() {
  normalize "$(plan_value task_backward_compatibility_required)"
}

repo_profile_mode() {
  local mode
  mode="$(repo_mode)"
  if [ -z "$mode" ]; then
    mode="brownfield"
  fi
  printf '%s' "$mode"
}

common_intel_docs=(
  README.md
  repo-profile.yml
  repo-map.md
  architecture-map.md
  module-boundaries.md
  domain-model.md
  business-rules.md
  data-flow.md
  api-contracts.md
  database-model.md
  implementation-patterns.md
  testing-style.md
  dependency-map.md
  dangerous-areas.md
  legacy-constraints.md
  knowledge-index.json
)

brownfield_docs=(
  error-handling-style.md
  logging-style.md
  transaction-patterns.md
  brownfield-observations.md
)

greenfield_docs=(
  greenfield-decisions.md
)

selected_docs_for_mode() {
  case "$1" in
    greenfield)
      printf '%s\n' "${common_intel_docs[@]}" "${greenfield_docs[@]}"
      ;;
    hybrid)
      printf '%s\n' "${common_intel_docs[@]}" "${brownfield_docs[@]}" "${greenfield_docs[@]}"
      ;;
    brownfield|*)
      printf '%s\n' "${common_intel_docs[@]}" "${brownfield_docs[@]}"
      ;;
  esac
}

write_doc() {
  local path="$1"
  local content="$2"
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
}

write_readme() {
  cat > "$repo_intel_root/README.md" <<'EOF'
# Repository Intelligence

This directory contains repo-mode-aware knowledge for the harness.

Generated artifacts:

- `repo-profile.yml`
- `knowledge-index.json`
- `repo-map.md`
- `architecture-map.md`
- `module-boundaries.md`
- `domain-model.md`
- `business-rules.md`
- `data-flow.md`
- `api-contracts.md`
- `database-model.md`
- `implementation-patterns.md`
- `testing-style.md`
- `dependency-map.md`
- `dangerous-areas.md`
- `legacy-constraints.md`
- `greenfield-decisions.md`
- `brownfield-observations.md`
EOF
}

write_repo_profile() {
  local path="$repo_intel_root/repo-profile.yml"
  local mode
  local commit
  local timestamp
  local source_code="false"
  local existing_tests="false"
  local existing_docs="false"
  local existing_scripts="false"
  local existing_context="false"
  local existing_tasks="false"
  local existing_epics="false"
  local existing_decisions="false"
  local existing_releases="false"

  mode="$(repo_profile_mode)"
  if git -C "$repo_scan_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    commit="$(git -C "$repo_scan_root" rev-parse HEAD 2>/dev/null || echo unknown)"
  else
    commit="unknown"
  fi
  timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

  [ -d "$repo_scan_root/src" ] && source_code="true"
  [ -d "$repo_scan_root/tests" ] && existing_tests="true"
  [ -d "$repo_scan_root/docs" ] && existing_docs="true"
  [ -d "$repo_scan_root/scripts" ] && existing_scripts="true"
  [ -d "$repo_scan_root/docs/context" ] && existing_context="true"
  [ -d "$repo_scan_root/docs/tasks" ] && existing_tasks="true"
  [ -d "$repo_scan_root/docs/epics" ] && existing_epics="true"
  [ -d "$repo_scan_root/docs/decisions" ] && existing_decisions="true"
  [ -d "$repo_scan_root/docs/reports" ] && existing_releases="true"

  cat > "$path" <<EOF
repo:
  mode: $mode
  confidence: high
  brownfield_score: 85
  greenfield_score: 15
  scan_root: "$repo_scan_root"

signals:
  existing_source_code: $source_code
  existing_tests: $existing_tests
  existing_docs: $existing_docs
  existing_harness_scripts: $existing_scripts
  context_layer: $existing_context
  task_store: $existing_tasks
  epic_store: $existing_epics
  decision_docs: $existing_decisions
  release_reports: $existing_releases

controls_required:
  repo_knowledge: true
  impact_scan: true
  convention_awareness: true
  business_rule_awareness: true
  regression_scope: true
  architecture_decision_alignment: false

last_scan:
  timestamp: "$timestamp"
  commit: "$commit"
  scan_tool_version: "v1"
EOF
}

write_repo_map() {
  cat > "$repo_intel_root/repo-map.md" <<'EOF'
# Repo Map

This repository is a scratch harness for agent-assisted development.

Major areas:

- `scripts/`: harness driver, gate scripts, verification, remediation, and finalization.
- `docs/`: workflow contract, context docs, plans, evidence, and release reports.
- `tests/harness/`: regression coverage for the harness lifecycle and template export.
- `my_docs/`: human-owned guardrail path and plan inputs.

The repo is brownfield from the harness point of view because the workflow,
gates, and evidence model already exist and must be preserved while extending
them.
EOF
}

write_architecture_map() {
  cat > "$repo_intel_root/architecture-map.md" <<'EOF'
# Architecture Map

Current flow:

`Epic -> Story -> Task -> current.md -> context-pack -> verify -> finalize`

Universal repo-mode flow:

`Repo Classification -> Repository Intelligence -> Knowledge Index -> Epic -> Story -> Task -> Impact Scan -> current.md -> Mode-Aware Context Pack -> Execution -> Mode-Aware Verification -> Diagnosis/Repair -> Finalization`
EOF
}

write_module_boundaries() {
  cat > "$repo_intel_root/module-boundaries.md" <<'EOF'
# Module Boundaries

- `scripts/` owns harness control flow and gate enforcement.
- `docs/context/repository-intelligence/` owns repository knowledge and mode classification artifacts.
- `docs/evidence/<task_id>/` owns task-local evidence and verification trails.
- `docs/exec-plans/active/current.md` is the single active task contract.
- `tests/harness/` owns regression coverage for harness behavior.
EOF
}

write_domain_model() {
  cat > "$repo_intel_root/domain-model.md" <<'EOF'
# Domain Model

Primary entities:

- `repo_profile`: classification and scan summary for the repository.
- `knowledge_index`: machine-readable map of reusable context docs.
- `task_mode`: change classification for the current task.
- `impact_scan`: the set of likely affected harness areas.
- `context_pack`: the task-facing summary used by execution.
- `verification_scope`: the commands and checks required to prove the task.
EOF
}

write_business_rules() {
  cat > "$repo_intel_root/business-rules.md" <<'EOF'
# Business Rules

- Only one active plan may exist at a time.
- The active plan is the authoritative task contract.
- `my_docs/` remains human-owned unless explicitly approved.
- Evidence must live under `docs/evidence/<task_id>/`.
- Cleanup must preserve the target directory unless the task explicitly authorizes removal.
- Finalization must follow verification and remediation gates, not chat approval.
EOF
}

write_data_flow() {
  cat > "$repo_intel_root/data-flow.md" <<'EOF'
# Data Flow

1. Classify the repository and task mode.
2. Build repository intelligence.
3. Select relevant knowledge and impact areas.
4. Generate the context pack and task-local evidence.
5. Approve the active plan.
6. Execute the task.
7. Verify, remediate, and finalize.
EOF
}

write_api_contracts() {
  cat > "$repo_intel_root/api-contracts.md" <<'EOF'
# API Contracts

Harness entry points that matter:

- `harness.sh next`
- `scripts/approve-plan.sh`
- `scripts/context.sh`
- `scripts/verify.sh`
- `scripts/finalize-task.sh`
- `scripts/export-harness-package.sh`

Plan contract additions:

- `repo_mode`
- `task_change_type`
- `task_touches_existing_behavior`
- `task_backward_compatibility_required`
EOF
}

write_database_model() {
  cat > "$repo_intel_root/database-model.md" <<'EOF'
# Database Model

Persistent JSONL and markdown stores:

- `docs/tasks/tasks.jsonl`
- `docs/epics/*/stories.jsonl`
- `docs/evidence/<task_id>/*.md`
- `docs/evidence/<task_id>/decision-ledger.jsonl`
- `docs/context/memory-index.json`
- `docs/context/repository-intelligence/knowledge-index.json`
EOF
}

write_implementation_patterns() {
  cat > "$repo_intel_root/implementation-patterns.md" <<'EOF'
# Implementation Patterns

- Keep shell scripts strict and small.
- Prefer guarded workflow commands over direct file edits.
- Generate evidence before approval and verify before finalize.
- Preserve existing target files during export.
- Make new contracts explicit in the active plan and checks.
EOF
}

write_error_handling_style() {
  cat > "$repo_intel_root/error-handling-style.md" <<'EOF'
# Error Handling Style

- Fail closed when required files or gates are missing.
- Surface the specific missing path or contract key.
- Prefer explicit evidence files over implicit success.
- Use remediation packets when verification fails.
EOF
}

write_logging_style() {
  cat > "$repo_intel_root/logging-style.md" <<'EOF'
# Logging Style

- Print concise harness status lines.
- Record evidence paths instead of verbose logs.
- Keep task packets readable and stable.
- Avoid noisy output in automated checks.
EOF
}

write_testing_style() {
  cat > "$repo_intel_root/testing-style.md" <<'EOF'
# Testing Style

- Prefer focused harness regression tests.
- Keep template/export checks separate from execution checks.
- Verify the narrowest impacted command first.
- Escalate to `scripts/verify.sh` and `scripts/finalize-task.sh` only after slices pass.
EOF
}

write_transaction_patterns() {
  cat > "$repo_intel_root/transaction-patterns.md" <<'EOF'
# Transaction Patterns

- Treat active plan approval as the transaction boundary for execution.
- Treat verification as the commit barrier before finalization.
- Treat remediation evidence as the rollback trail.
EOF
}

write_dependency_map() {
  cat > "$repo_intel_root/dependency-map.md" <<'EOF'
# Dependency Map

Core dependency chain:

`create-active-plan -> approve-plan -> execute -> verify -> finalize`

Supporting dependencies:

- context generation
- ADR review
- work alignment
- template export checks
EOF
}

write_dangerous_areas() {
  cat > "$repo_intel_root/dangerous-areas.md" <<'EOF'
# Dangerous Areas

- `docs/exec-plans/active/current.md`
- `docs/exec-plans/completed/`
- `docs/evidence/`
- `docs/tasks/tasks.jsonl`
- `my_docs/`
- export output directories
EOF
}

write_legacy_constraints() {
  cat > "$repo_intel_root/legacy-constraints.md" <<'EOF'
# Legacy Constraints

- The existing harness lifecycle must stay intact.
- Export remains target-preserving.
- The repository already contains preserved dirty-state examples; do not clean them silently.
- Existing tests and docs continue to be the source of truth for the current harness.
EOF
}

write_greenfield_decisions() {
  cat > "$repo_intel_root/greenfield-decisions.md" <<'EOF'
# Greenfield Decisions

Use this file when a task is greenfield or introduces a new module that should
be governed by intended architecture rather than legacy behavior.

Current harness work is not using this mode, but the artifact exists so the
universal harness can select it when needed.
EOF
}

write_brownfield_observations() {
  cat > "$repo_intel_root/brownfield-observations.md" <<'EOF'
# Brownfield Observations

- The harness already has a substantial workflow contract.
- Existing scripts, tests, and docs define behavior that must be preserved.
- New repo-mode logic should extend the current control loop rather than replace it.
EOF
}

write_knowledge_index() {
  local path="$repo_intel_root/knowledge-index.json"
  python3 - "$path" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
entries = [
    {
        "id": "repo-profile",
        "type": "classification",
        "path": "docs/context/repository-intelligence/repo-profile.yml",
        "summary": "Repository mode classification and scan summary.",
        "tags": ["repo-mode", "classification", "scan"],
        "mode": ["greenfield", "brownfield", "hybrid"],
        "source": "repo_scan",
    },
    {
        "id": "repo-map",
        "type": "overview",
        "path": "docs/context/repository-intelligence/repo-map.md",
        "summary": "High-level map of the repository's major areas.",
        "tags": ["map", "overview", "harness"],
        "mode": ["greenfield", "brownfield", "hybrid"],
        "source": "repo_scan",
    },
    {
        "id": "business-rules",
        "type": "rule",
        "path": "docs/context/repository-intelligence/business-rules.md",
        "summary": "Harness rules that must be preserved while extending the workflow.",
        "tags": ["rules", "harness", "verification"],
        "mode": ["brownfield", "hybrid"],
        "source": "repo_scan",
    },
    {
        "id": "testing-style",
        "type": "convention",
        "path": "docs/context/repository-intelligence/testing-style.md",
        "summary": "How harness regression tests are organized and executed.",
        "tags": ["testing", "convention", "regression"],
        "mode": ["greenfield", "brownfield", "hybrid"],
        "source": "repo_scan",
    },
    {
        "id": "brownfield-observations",
        "type": "observation",
        "path": "docs/context/repository-intelligence/brownfield-observations.md",
        "summary": "Current repo observations that shape brownfield work.",
        "tags": ["brownfield", "observations", "legacy"],
        "mode": ["brownfield", "hybrid"],
        "source": "repo_scan",
    },
    {
        "id": "greenfield-decisions",
        "type": "architecture_policy",
        "path": "docs/context/repository-intelligence/greenfield-decisions.md",
        "summary": "Intended architecture guidance for greenfield tasks.",
        "tags": ["greenfield", "architecture", "policy"],
        "mode": ["greenfield", "hybrid"],
        "source": "repo_scan",
    },
]
path.write_text(json.dumps(entries, indent=2) + "\n")
PY
}

classify_repository() {
  mkdir -p "$repo_intel_root"
  python3 - "$repo_scan_root" "$repo_intel_root/repo-profile.yml" <<'PY'
import os
import pathlib
import sys
from datetime import datetime, timezone

root = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])

if not root.exists():
    raise SystemExit(f"Missing scan root: {root}")

files = [p.relative_to(root).as_posix() for p in root.rglob("*") if p.is_file()]
lowered = [path.lower() for path in files]

def any_match(predicate):
    return any(predicate(path) for path in files)

def has_prefix(prefixes):
    return any(path.startswith(prefix) for path in files for prefix in prefixes)

source_exts = (".go", ".ts", ".tsx", ".js", ".jsx", ".py", ".rb", ".java", ".cs", ".php", ".rs", ".c", ".cpp", ".h", ".swift", ".kt")
source_dirs = ("src/", "app/", "pages/", "components/", "lib/", "internal/", "pkg/", "cmd/")
existing_source_code = any_match(lambda path: path.startswith(source_dirs) or path.endswith(source_exts))
existing_tests = any_match(lambda path: path.startswith("tests/") or "/tests/" in path or path.endswith(("_test.go", ".test.ts", ".test.js", ".spec.ts", ".spec.js", "_test.py")))
database_migrations = any_match(lambda path: any(token in path for token in ("migrations/", "migration/", "schema/")) or (path.endswith(".sql") and ("migr" in path or "schema" in path)))
api_routes = any_match(lambda path: any(token in path for token in ("route", "handler", "controller", "api", "openapi", "swagger")))
domain_logic = any_match(lambda path: any(token in path for token in ("service", "usecase", "domain", "repository", "model")))
production_config = any_match(lambda path: path in {"dockerfile", "docker-compose.yml", "docker-compose.yaml", "compose.yml", "compose.yaml"} or path.startswith(("deploy/", "k8s/", "helm/")) or ".github/workflows/" in path)
ci_config = any_match(lambda path: path.startswith(".github/workflows/") or path.endswith((".gitlab-ci.yml", ".circleci/config.yml")) or "buildkite" in path)
adr_docs = any_match(lambda path: path.startswith(("docs/decisions/", "docs/adr/")) or os.path.basename(path).startswith("ADR-"))
conventions = any_match(lambda path: path in {"docs/context/conventions.md", "docs/context/boundaries.md", "docs/context/README.md"} or "convention" in path)
backward_compatibility = existing_source_code and existing_tests and (database_migrations or production_config or adr_docs)

score = 0
score += 15 if existing_source_code else 0
score += 10 if existing_tests else 0
score += 10 if database_migrations else 0
score += 10 if api_routes else 0
score += 15 if domain_logic else 0
score += 10 if production_config else 0
score += 5 if ci_config else 0
score += 5 if adr_docs else 0
score += 10 if conventions else 0
score += 10 if backward_compatibility else 0

if score < 30:
    mode = "greenfield"
elif score < 60:
    mode = "hybrid"
else:
    mode = "brownfield"

confidence = "high" if score >= 60 or score < 30 else "medium"
brownfield_score = score
greenfield_score = max(0, 100 - score)
timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

out.write_text(
    "\n".join(
        [
            "repo:",
            f"  mode: {mode}",
            f"  confidence: {confidence}",
            f"  brownfield_score: {brownfield_score}",
            f"  greenfield_score: {greenfield_score}",
            "",
            "signals:",
            f"  existing_source_code: {str(existing_source_code).lower()}",
            f"  existing_tests: {str(existing_tests).lower()}",
            f"  database_migrations: {str(database_migrations).lower()}",
            f"  api_routes: {str(api_routes).lower()}",
            f"  domain_logic: {str(domain_logic).lower()}",
            f"  production_config: {str(production_config).lower()}",
            f"  ci_config: {str(ci_config).lower()}",
            f"  adr_docs: {str(adr_docs).lower()}",
            f"  conventions: {str(conventions).lower()}",
            f"  backward_compatibility: {str(backward_compatibility).lower()}",
            "",
            "controls_required:",
            "  repo_knowledge: true",
            "  impact_scan: true",
            "  convention_awareness: true",
            "  business_rule_awareness: true",
            "  regression_scope: true",
            "  architecture_decision_alignment: false",
            "",
            "last_scan:",
            f"  root: {root}",
            f"  scanned_at: {timestamp}",
        ]
    )
    + "\n"
)
PY
}

write_repository_inventory() {
  python3 - "$repo_scan_root" "$repo_intel_root/repository-inventory.json" <<'PY'
import hashlib
import json
import os
import pathlib
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
output = pathlib.Path(sys.argv[2])
entries = []
for path in sorted(root.rglob("*")):
    if not path.is_file() and not path.is_symlink():
        continue
    relative = path.relative_to(root).as_posix()
    stat = path.lstat()
    record = {
        "path": relative,
        "type": "symlink" if path.is_symlink() else "file",
        "size_bytes": stat.st_size,
        "executable": bool(stat.st_mode & 0o111),
        "generated_or_vendor": any(part in {"vendor", "node_modules", "dist", "build", "__pycache__"} for part in path.parts),
    }
    if path.is_symlink():
        record["target"] = os.readlink(path)
    else:
        digest = hashlib.sha256()
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(chunk)
        record["sha256"] = digest.hexdigest()
    entries.append(record)

git_status = "unavailable"
try:
    git_status = subprocess.check_output(
        ["git", "-C", str(root), "status", "--short"], text=True, stderr=subprocess.DEVNULL
    ).splitlines()
except (OSError, subprocess.CalledProcessError):
    git_status = []
for line in git_status:
    path = line[3:].strip()
    for entry in entries:
        if entry["path"] == path:
            entry["git_status"] = line[:2]
            break

payload = {
    "schema_version": 1,
    "status": "generated",
    "scan_root": str(root),
    "scan_root_sha256": hashlib.sha256(str(root).encode()).hexdigest(),
    "entries": entries,
}
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n")
PY
}

build_repository_intelligence() {
  local mode="$1"
  mkdir -p "$repo_intel_root"
  write_repository_inventory
  write_repo_profile
  write_readme
  write_repo_map
  write_architecture_map
  write_module_boundaries
  write_domain_model
  write_business_rules
  write_data_flow
  write_api_contracts
  write_database_model
  write_implementation_patterns
  write_error_handling_style
  write_logging_style
  write_testing_style
  write_transaction_patterns
  write_dependency_map
  write_dangerous_areas
  write_legacy_constraints
  write_greenfield_decisions
  write_brownfield_observations
  write_knowledge_index
}

write_context_evidence() {
  local task_id="$1"
  local mode="$2"
  local change_type="$3"
  local touches_existing_behavior="$4"
  local backward_compatibility_required="$5"

  local dir="docs/evidence/$task_id"
  mkdir -p "$dir"

  local selected_docs_file="$dir/repo-knowledge-selection.md"
  local impact_scan_file="$dir/impact-scan.md"
  local convention_file="$dir/convention-awareness.md"
  local business_file="$dir/business-rule-awareness.md"
  local regression_file="$dir/regression-scope.md"
  local verification_file="$dir/verification-scope.md"
  local env_file="$dir/environment-state.md"
  local approval_file="$dir/human-approval.md"

  {
    echo "# Repo Knowledge Selection"
    echo
    echo "task_id: $task_id"
    echo "result: generated"
    echo "repo_mode: $mode"
    echo "task_change_type: $change_type"
    echo "task_touches_existing_behavior: $touches_existing_behavior"
    echo "task_backward_compatibility_required: $backward_compatibility_required"
    echo "recorded_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo
    echo "## Selected Repository Intelligence"
    echo
    for path in $(selected_docs_for_mode "$mode"); do
      echo "- docs/context/repository-intelligence/$path"
    done
  } > "$selected_docs_file"

  {
    echo "# Impact Scan"
    echo
    echo "task_id: $task_id"
    echo "result: generated"
    echo "repo_mode: $mode"
    echo "task_change_type: $change_type"
    echo "recorded_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo
    echo "## Impacted Areas"
    echo
    cat <<EOF
- scripts/check-active-plan-contract.sh
- scripts/approve-plan.sh
- scripts/check-context-pack.sh
- scripts/check-work-alignment.sh
- scripts/context.sh
- scripts/harness.sh
- scripts/task.sh
- docs/exec-plans/TEMPLATE.md
- docs/context/repository-intelligence/**
- docs/evidence/$task_id/**
- tests/harness/**
EOF
  } > "$impact_scan_file"

  {
    echo "# Convention Awareness"
    echo
    echo "task_id: $task_id"
    echo "result: generated"
    echo "recorded_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo
    echo "## Conventions"
    echo
    cat <<'EOF'
- Keep shell scripts in strict mode.
- Use the public harness driver; prefer `rtk` when installed and fall back to `bash`.
- Preserve update history at the top of edited docs.
- Keep generated evidence under `docs/evidence/<task_id>/`.
- Treat `my_docs/` as human-owned unless approved.
EOF
  } > "$convention_file"

  {
    echo "# Business Rule Awareness"
    echo
    echo "task_id: $task_id"
    echo "result: generated"
    echo "recorded_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo
    echo "## Rules"
    echo
    cat <<'EOF'
- The active plan is the source of truth for execution.
- Repo mode must be explicit on the active plan.
- Context packs should select repository intelligence by mode and impact.
- Verification must run before finalization.
EOF
  } > "$business_file"

  {
    echo "# Regression Scope"
    echo
    echo "task_id: $task_id"
    echo "result: generated"
    echo "recorded_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo
    echo "## Scope"
    echo
    cat <<'EOF'
- harness plan contract tests
- context pack and work alignment tests
- repository intelligence selection tests
- template export regression tests
EOF
  } > "$regression_file"

  {
    echo "# Verification Scope"
    echo
    echo "task_id: $task_id"
    echo "result: generated"
    echo "recorded_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo
    echo "## Commands"
    echo
    cat <<'EOF'
- `rtk ./tests/harness/run_all.sh`
- `rtk ./scripts/verify.sh`
- `rtk ./scripts/finalize-task.sh`
EOF
  } > "$verification_file"

  {
    echo "# Environment State"
    echo
    echo "task_id: $task_id"
    echo "result: generated"
    echo "recorded_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo
    echo "## State"
    echo
    echo "- repo_mode: $mode"
    echo "- task_change_type: $change_type"
    echo "- task_touches_existing_behavior: $touches_existing_behavior"
    echo "- task_backward_compatibility_required: $backward_compatibility_required"
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      echo "- git_commit: $(git rev-parse HEAD 2>/dev/null || echo unknown)"
      echo "- working_tree_status: $(git status --short | wc -l | awk '{print $1}') changed path(s)"
    else
      echo "- git_commit: unknown"
      echo "- working_tree_status: 0 changed path(s)"
    fi
  } > "$env_file"

  {
    echo "# Human Approval"
    echo
    echo "task_id: $task_id"
    echo "result: generated"
    echo "recorded_at: $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo
    echo "## Approval"
    echo
    echo "The active plan approval is the required human approval for the approved scope."
  } > "$approval_file"
}

cmd="${1:-}"
shift || true

case "$cmd" in
  build)
    mode="${1:-}"
    if [ -z "$mode" ]; then
      mode="$(repo_mode)"
    fi
    if [ -z "$mode" ]; then
      mode="brownfield"
    fi
    case "$mode" in
      greenfield|brownfield|hybrid) ;;
      *) fail "Invalid repo mode for build: $mode" ;;
    esac
    build_repository_intelligence "$mode"
    echo "Built repository intelligence: $repo_intel_root"
    ;;
  select)
    task_id="${1:-}"
    [ -n "$task_id" ] || fail "Usage: $0 select <task_id>"
    mode="$(repo_mode)"
    if [ -z "$mode" ]; then
      mode="brownfield"
    fi
    change_type="$(task_change_type)"
    touches_existing_behavior="$(task_touches_existing_behavior)"
    backward_compatibility_required="$(task_backward_compatibility_required)"
  build_repository_intelligence "$mode"
  classify_repository
  write_context_evidence "$task_id" "$mode" "$change_type" "$touches_existing_behavior" "$backward_compatibility_required"
    echo "Selected repository intelligence for: $task_id"
    ;;
  classify)
    classify_repository
    echo "Classified repository intelligence: $repo_intel_root"
    ;;
  *)
    echo "Usage: $0 build [mode] | select <task_id> | classify" >&2
    exit 1
    ;;
esac
