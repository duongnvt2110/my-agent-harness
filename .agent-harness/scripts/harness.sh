#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

TASK_STORE="${TASK_STORE:-docs/tasks/tasks.jsonl}"

task_implementation_plan_path() {
  local task_id="$1"
  python3 - "$TASK_STORE" "$task_id" <<'PY'
import json
import pathlib
import sys

store = pathlib.Path(sys.argv[1])
task_id = sys.argv[2]
if not store.exists():
    raise SystemExit(0)
for line in store.read_text().splitlines():
    if not line.strip():
        continue
    record = json.loads(line)
    if record.get("id") == task_id:
        print(record.get("implementation_plan_path", ""))
        raise SystemExit(0)
raise SystemExit(0)
PY
}

actionable_intake_count() {
  python3 - "$TASK_STORE" "docs/intake" <<'PY'
import json
import pathlib
import sys

task_store = pathlib.Path(sys.argv[1])
intake_dir = pathlib.Path(sys.argv[2])
if not intake_dir.is_dir():
    print(0)
    raise SystemExit(0)

rows = []
if task_store.is_file():
    rows = [json.loads(line) for line in task_store.read_text().splitlines() if line.strip()]

count = 0
for intake_path in intake_dir.glob("*.md"):
    resolved = intake_path.resolve()
    references = []
    for row in rows:
        source = row.get("source_plan_path")
        if not source:
            continue
        source_path = pathlib.Path(source)
        if not source_path.is_absolute():
            source_path = pathlib.Path.cwd() / source_path
        if source_path.resolve() == resolved:
            references.append(row)
    if not references or any(row.get("status") != "DONE" for row in references):
        count += 1
print(count)
PY
}

cmd="${1:-next}"

script_runner() {
  if command -v rtk >/dev/null 2>&1; then
    printf '%s' "rtk"
  else
    printf '%s' "bash"
  fi
}

runner="$(script_runner)"

# Stable commands use the repository's v3 metadata as the only authority.
# Missing, mixed, or invalid metadata is handled by the dispatcher; no v3
# artifact is silently interpreted by a legacy path.
if [[ "$cmd" =~ ^(status|next|verify|finalize)$ ]] && [ "${HARNESS_V3_DISPATCHED:-0}" != "1" ]; then
  HARNESS_WORKFLOW_METADATA="${HARNESS_WORKFLOW_METADATA:-$HARNESS_ROOT/runtime/v3-workflow.json}"
  [ -f "$HARNESS_WORKFLOW_METADATA" ] || { echo "missing v3 workflow metadata: $HARNESS_WORKFLOW_METADATA" >&2; exit 78; }
  exec "$HARNESS_SCRIPTS_DIR/workflow-dispatch.sh" run "$HARNESS_WORKFLOW_METADATA" "$cmd" "${@:2}"
fi

runtime_header() {
  if [ "${HARNESS_V3_DISPATCHED:-0}" = "1" ]; then
    local metadata="${HARNESS_WORKFLOW_METADATA:-$HARNESS_ROOT/runtime/v3-workflow.json}"
    [ -f "$metadata" ] || fail "Missing authoritative workflow metadata: $metadata"
    python3 - "$metadata" <<'HEADER_PY'
import json
import pathlib
import sys

data = json.loads(pathlib.Path(sys.argv[1]).read_text())
print(f"workflow_version: {data['workflow_version']}")
print(f"implementation_version: {data['implementation_version']}")
print(f"enforcement_mode: {data['enforcement_mode']}")
limitations = data.get("assurance_limitations", [])
print("assurance_limitations: " + ("; ".join(limitations) if limitations else "none"))
HEADER_PY
  fi
}

case "$cmd" in
  audit)
    exec "$HARNESS_SCRIPTS_DIR/audit.sh" "${@:2}"
    ;;
  status)
    runtime_header
    if [ ! -f "$PLAN_PATH" ]; then
      echo "HARNESS STATUS"
      echo "active_plan: missing"
      exit 0
    fi
    echo "HARNESS STATUS"
    echo "active_plan: $PLAN_PATH"
    echo "task_id: $(fm_value "$PLAN_PATH" "task_id")"
    echo "status: $(fm_value "$PLAN_PATH" "status")"
    echo "lifecycle_phase: $(fm_value "$PLAN_PATH" "lifecycle_phase")"
    echo "repo_mode: $(fm_value "$PLAN_PATH" "repo_mode")"
    ;;
  next)
    runtime_header
    if [ ! -f "$PLAN_PATH" ]; then
      intake_count=0
      ready_count=0
      if [ -d docs/intake ]; then
        intake_count="$(actionable_intake_count)"
      fi
      if [ -f "$TASK_STORE" ]; then
        ready_count="$(grep -c '"status":"READY"' "$TASK_STORE" 2>/dev/null || true)"
      fi
      cat <<EOF
HARNESS TASK PACKET

Current lifecycle phase: PLAN
Active plan: missing
Long-plan intake files: $intake_count
Ready backlog tasks: $ready_count

Next allowed action:
- If you have a long implementation plan, classify and decompose it first:
  $runner .agent-harness/scripts/classify-plan-size.sh <implementation-plan.md>
  $runner .agent-harness/scripts/decompose-plan.sh <implementation-plan.md>
  $runner .agent-harness/scripts/approve-decomposition.sh

- If READY tasks already exist, activate exactly one task:
  $runner .agent-harness/scripts/task.sh ready
  $runner .agent-harness/scripts/task.sh activate <task_id>
  $runner .agent-harness/scripts/approve-active-task.sh

- If this is a legacy single-task plan, create one active plan manually:
  $runner .agent-harness/scripts/create-active-plan.sh <task_id> "<title>"

Forbidden:
- Do not implement without an active plan.
- Do not put a full epic/story/task roadmap into current.md.
- Do not create docs/exec-plans/active/current.md manually.
- Do not edit files without an active plan.
- Do not edit outside the intended harness scope.
EOF
      if [ -f "$TASK_STORE" ] && [ "$ready_count" != "0" ]; then
        echo
        echo "Ready tasks:"
        ./scripts/task.sh ready --limit 5 || true
      fi
      echo "active_plan_guard: Active plan: missing; Do not implement without an active plan"
      exit 1
    fi

    approved_scopes="$(fm_list "$PLAN_PATH" "approved_scopes" | sed 's/^/- /')"
    [ -n "$approved_scopes" ] || approved_scopes="- (none)"
    approved_files="$(fm_list "$PLAN_PATH" "approved_files" | sed 's/^/- /')"
    [ -n "$approved_files" ] || approved_files="- (none)"
    approved_deletions="$(fm_list "$PLAN_PATH" "approved_deletions" | sed 's/^/- /')"
    [ -n "$approved_deletions" ] || approved_deletions="- (none)"
    task_id="$(fm_value "$PLAN_PATH" "task_id")"
    repo_mode="$(fm_value "$PLAN_PATH" "repo_mode")"
    task_change_type="$(fm_value "$PLAN_PATH" "task_change_type")"
    task_touches_existing_behavior="$(fm_value "$PLAN_PATH" "task_touches_existing_behavior")"
    task_backward_compatibility_required="$(fm_value "$PLAN_PATH" "task_backward_compatibility_required")"
    parent_epic_id="$(fm_value "$PLAN_PATH" "parent_epic_id")"
    parent_story_id="$(fm_value "$PLAN_PATH" "parent_story_id")"
    implementation_plan_path="$(task_implementation_plan_path "$task_id")"
    epic_path="$(fm_value "$PLAN_PATH" "epic_path")"
    story_registry="$(fm_value "$PLAN_PATH" "story_registry")"
    epic_memory="$(fm_value "$PLAN_PATH" "epic_memory")"
    epic_progress="$(fm_value "$PLAN_PATH" "epic_progress")"
    epic_clarifications="$(fm_value "$PLAN_PATH" "epic_clarifications")"
    work_alignment_evidence="$(fm_value "$PLAN_PATH" "work_alignment_evidence")"
    spec_clarification_evidence="$(fm_value "$PLAN_PATH" "spec_clarification_evidence")"
    adr_file="$(evidence_dir)/adr-review.md"
    context_pack="$(evidence_dir)/context-pack.md"
    working_memory="$(evidence_dir)/working-memory.md"
    full_context="$(full_context_file)"
    verification_mode="$(fm_value "$PLAN_PATH" "verification_mode")"
    testing_required="$(fm_value "$PLAN_PATH" "testing_required")"
    decision_policy_allow_safe_revert="$(fm_value "$PLAN_PATH" "decision_policy_allow_safe_revert")"
    decision_policy_allow_test_fix="$(fm_value "$PLAN_PATH" "decision_policy_allow_test_fix")"
    decision_policy_allow_source_fix="$(fm_value "$PLAN_PATH" "decision_policy_allow_source_fix")"
    decision_policy_allow_scope_expansion="$(fm_value "$PLAN_PATH" "decision_policy_allow_scope_expansion")"
    decision_policy_allow_dependency_change="$(fm_value "$PLAN_PATH" "decision_policy_allow_dependency_change")"
    decision_policy_allow_environment_change="$(fm_value "$PLAN_PATH" "decision_policy_allow_environment_change")"
    decision_policy_allow_test_skip="$(fm_value "$PLAN_PATH" "decision_policy_allow_test_skip")"
    decision_policy_allow_timeout_increase="$(fm_value "$PLAN_PATH" "decision_policy_allow_timeout_increase")"

    phase="$(fm_value "$PLAN_PATH" "lifecycle_phase")"
    case "$phase" in
      PLAN)
        next_action="Approve the plan with $runner .agent-harness/scripts/approve-plan.sh."
        ;;
      EXECUTE)
        next_action="Implement only approved scopes and keep edits inside the active plan."
        ;;
      SCOPE_REMEDIATION)
        next_action="Resolve the file-map violation with $runner .agent-harness/scripts/resolve-file-map-violation.sh and an exact path."
        ;;
      DIAGNOSE)
        next_action="Diagnose the latest failure with $runner .agent-harness/scripts/diagnose-failure.sh."
        ;;
      REPAIR_PLAN)
        next_action="Create the repair plan with $runner .agent-harness/scripts/create-repair-plan.sh."
        ;;
      PATCH)
        next_action="Patch only approved files, then run $runner .agent-harness/scripts/run-targeted-checks.sh."
        ;;
      VERIFY)
        next_action="Run $runner .agent-harness/scripts/verify.sh."
        ;;
      REVIEW)
        next_action="Prepare review evidence and wait for the review gate."
        ;;
      FINALIZE)
        next_action="Run $runner .agent-harness/scripts/finalize-task.sh."
        ;;
      BLOCKED)
        next_action="Resolve the blocker or request human approval before continuing."
        ;;
      COMPLETED)
        next_action="No action; the task is completed."
        ;;
      *)
        next_action="Follow the active plan lifecycle phase."
        ;;
    esac

    parent_epic_block=""
    if [ -n "$parent_epic_id" ] && [ "$parent_epic_id" != "null" ]; then
      parent_epic_block="$(cat <<PARENT_EOF
Parent epic:
- parent_epic_id: $parent_epic_id
- parent_story_id: $parent_story_id
- epic_path: $epic_path
- story_registry: $story_registry
- epic_memory: $epic_memory
- epic_progress: $epic_progress
- epic_clarifications: $epic_clarifications
- spec_clarification_evidence: $spec_clarification_evidence
- work_alignment_evidence: $work_alignment_evidence

PARENT_EOF
)"
    fi

    cat <<EOF
HARNESS TASK PACKET

Task ID: $(fm_value "$PLAN_PATH" "task_id")
Status: $(fm_value "$PLAN_PATH" "status")
Lifecycle phase: $(fm_value "$PLAN_PATH" "lifecycle_phase")
Lane: $(fm_value "$PLAN_PATH" "lane")
Repo mode: $repo_mode
Task mode:
- change_type: $task_change_type
- touches_existing_behavior: $task_touches_existing_behavior
- backward_compatibility_required: $task_backward_compatibility_required
Active plan: $PLAN_PATH

Active plan lock:
- current.md exists and is authoritative.
- Do not create another active plan.
- Continue this task only until it is verified and finalized.

Implementation plan snapshot:
- ${implementation_plan_path:-not yet consumed}

Next allowed action:
$next_action

Approved scopes:
$approved_scopes

Approved file exceptions:
$approved_files

Approved deletions:
$approved_deletions

$parent_epic_block

Relevant ADRs:
$(if [ -f "$adr_file" ]; then awk '
  /^result:/ {sub(/^result:[[:space:]]*/, "", $0); print "- result: " $0; next}
  /^relevant_adrs:/ {in_list=1; next}
  /^## / {in_list=0}
  in_list && /^[[:space:]]*-[[:space:]]+/ {sub(/^[[:space:]]*-[[:space:]]+/, "", $0); print "- " $0}
' "$adr_file"; else echo "- (missing)"; fi)

Context pack:
- $context_pack

Working memory:
- $working_memory

Full context:
- $full_context

Verification mode: $verification_mode
Testing required: $testing_required

Decision policy:
- allow_safe_revert: $decision_policy_allow_safe_revert
- allow_test_fix: $decision_policy_allow_test_fix
- allow_source_fix: $decision_policy_allow_source_fix
- allow_scope_expansion: $decision_policy_allow_scope_expansion
- allow_dependency_change: $decision_policy_allow_dependency_change
- allow_environment_change: $decision_policy_allow_environment_change
- allow_test_skip: $decision_policy_allow_test_skip
- allow_timeout_increase: $decision_policy_allow_timeout_increase

Required checks:
$(required_check_rows "$PLAN_PATH" | awk -F '\t' '{print "- " $1 ": " $3 " (timeout: " $5 ")" }')

Do-not-read:
- docs/exec-plans/completed/*
- docs/evidence/*/autonomous-run-report.md unless it belongs to this task
- docs/evidence/*/verification-pass.md unless it belongs to this task
- docs/evidence/*/test-report.md unless it belongs to this task

Forbidden:
- Do not change files outside approved scopes or approved file exceptions.
- Do not delete files outside approved scopes or approved deletions.
- Do not mark completion manually.
- Do not skip required checks.
- Do not treat direct chat as approval to bypass the harness lifecycle.
EOF
    ;;
  verify)
    profile="full"
    if [ "${2:-}" = "--profile" ]; then
      profile="${3:-}"
      case "$profile" in
        targeted|full|release) ;;
        *) fail "Unsupported verification profile: $profile" ;;
      esac
      if [ "$profile" = "release" ]; then
        "$HARNESS_SCRIPTS_DIR/verify.sh"
        exec "$HARNESS_SCRIPTS_DIR/release-check.sh" "${@:4}"
      fi
      shift 3
    fi
    runtime_header
    export HARNESS_VERIFY_PROFILE="$profile"
    exec "$HARNESS_SCRIPTS_DIR/verify.sh" "$@"
    ;;
  finalize)
    runtime_header
    HARNESS_WORKFLOW_VERSION=v3 HARNESS_V3_DISPATCHED=1 exec "$HARNESS_SCRIPTS_DIR/finalize-task.sh"
    ;;
  finalize-task)
    runtime_header
    HARNESS_WORKFLOW_VERSION=v3 HARNESS_V3_DISPATCHED=1 exec "$HARNESS_SCRIPTS_DIR/finalize-task.sh"
    ;;
  batch-control)
    exec "$HARNESS_SCRIPTS_DIR/batch-control.sh" "${@:2}"
    ;;
  score)
    exec "$HARNESS_SCRIPTS_DIR/score-harness.sh" "${@:2}"
    ;;
  benchmark)
    exec "$HARNESS_SCRIPTS_DIR/benchmark.sh" "${@:2}"
    ;;
  validate-state)
    exec "$HARNESS_SCRIPTS_DIR/validate-current-state.sh" "${@:2}"
    ;;
  transition-state)
    exec "$HARNESS_SCRIPTS_DIR/transition-state" "${@:2}"
    ;;
    check-state-schema)
    exec "$HARNESS_SCRIPTS_DIR/check-state-schema.sh" "${@:2}"
    ;;
  check-task-schema)
    exec "$HARNESS_SCRIPTS_DIR/check-task-schema.sh" "${@:2}"
    ;;
  check-test-report)
    exec "$HARNESS_SCRIPTS_DIR/check-test-report.sh" "${@:2}"
    ;;
  check-final-report)
    exec "$HARNESS_SCRIPTS_DIR/check-final-report.sh" "${@:2}"
    ;;
  check-rollup-projection)
    exec "$HARNESS_SCRIPTS_DIR/check-rollup-projection.sh" "${@:2}"
    ;;
  check-task-plan-consistency)
    exec "$HARNESS_SCRIPTS_DIR/check-task-plan-consistency.sh" "${@:2}"
    ;;
  classify-risk)
    exec "$HARNESS_SCRIPTS_DIR/classify-risk.sh" "${@:2}"
    ;;
  bind-policy)
    exec "$HARNESS_SCRIPTS_DIR/bind-policy.sh" "${@:2}"
    ;;
  create-checkpoint)
    exec "$HARNESS_SCRIPTS_DIR/create-checkpoint.sh" "${@:2}"
    ;;
  verify-checkpoint)
    exec "$HARNESS_SCRIPTS_DIR/verify-checkpoint.sh" "${@:2}"
    ;;
  restore-checkpoint)
    exec "$HARNESS_SCRIPTS_DIR/restore-checkpoint.sh" "${@:2}"
    ;;
  check-ac-coverage)
    exec "$HARNESS_SCRIPTS_DIR/check-ac-coverage.sh" "${@:2}"
    ;;
  check-ac-evidence)
    exec "$HARNESS_SCRIPTS_DIR/check-ac-evidence.sh" "${@:2}"
    ;;
  check-verifier-verdict)
    exec "$HARNESS_SCRIPTS_DIR/check-verifier-verdict.sh" "${@:2}"
    ;;
  check-completion-judge)
    exec "$HARNESS_SCRIPTS_DIR/check-completion-judge.sh" "${@:2}"
    ;;
  record-failure)
    exec "$HARNESS_SCRIPTS_DIR/record-failure.sh" "${@:2}"
    ;;
  check-failure-history)
    exec "$HARNESS_SCRIPTS_DIR/check-failure-history.sh" "${@:2}"
    ;;
  rethink)
    exec "$HARNESS_SCRIPTS_DIR/rethink.sh" "${@:2}"
    ;;
  spec-lock)
    fail "Public spec-lock authority is retired in v3; use intake create/approve/bind"
    ;;
  lock-spec)
    fail "Public spec-lock authority is retired in v3; use intake create/approve/bind"
    ;;
  run-events)
    exec "$HARNESS_SCRIPTS_DIR/run-events.sh" "${@:2}"
    ;;
  events)
    exec "$HARNESS_SCRIPTS_DIR/run-events.sh" "${@:2}"
    ;;
  approve-plan)
    exec "$HARNESS_SCRIPTS_DIR/approve-plan.sh" "${@:2}"
    ;;
  break-task)
    fail "Public intake-graph authority is retired in v3; use the locked Change Package"
    ;;
  intake)
    exec "$HARNESS_SCRIPTS_DIR/intake-control.sh" "${@:2}"
    ;;
  readiness)
    exec "$HARNESS_SCRIPTS_DIR/readiness-control.sh" "${@:2}"
    ;;
  understand|clarify|answer)
    exec "$HARNESS_SCRIPTS_DIR/intake-control.sh" "$cmd" "${@:2}"
    ;;
  pause|resume|rollback)
    fail "Public command '$cmd' is outside the autonomous v3 control plane"
    ;;
  dispatch)
    exec "$HARNESS_SCRIPTS_DIR/workflow-dispatch.sh" "${@:2}"
    ;;
  intake-graph)
    fail "Public intake-graph authority is retired in v3; use the locked Change Package"
    ;;
  writer-lease)
    exec "$HARNESS_SCRIPTS_DIR/writer-lease.sh" "${@:2}"
    ;;
  capability)
    exec "$HARNESS_SCRIPTS_DIR/capability.sh" "${@:2}"
    ;;
  approval)
    exec "$HARNESS_SCRIPTS_DIR/approval.sh" "${@:2}"
    ;;
  workspace-guard)
    exec "$HARNESS_SCRIPTS_DIR/workspace-guard.sh" "${@:2}"
    ;;
  create-worktree)
    exec "$HARNESS_SCRIPTS_DIR/create-worktree" "${@:2}"
    ;;
  enforcement-gate)
    exec "$HARNESS_SCRIPTS_DIR/enforcement-gate.sh" "${@:2}"
    ;;
  trusted-time)
    exec "$HARNESS_SCRIPTS_DIR/trusted-time.sh" "${@:2}"
    ;;
  budget-guard)
    exec "$HARNESS_SCRIPTS_DIR/budget-guard.sh" "${@:2}"
    ;;
  remediation-epoch)
    exec "$HARNESS_SCRIPTS_DIR/remediation-epoch.sh" "${@:2}"
    ;;
  check-remediation-epochs)
    exec "$HARNESS_SCRIPTS_DIR/check-remediation-epochs.sh" "${@:2}"
    ;;
  release-check)
    exec "$HARNESS_SCRIPTS_DIR/release-check.sh" "${@:2}"
    ;;
  load-recipe)
    exec "$HARNESS_SCRIPTS_DIR/load-recipe" "${@:2}"
    ;;
    calculate-run-budget)
      exec "$HARNESS_SCRIPTS_DIR/calculate-run-budget" "${@:2}"
      ;;
    check-v3-projections)
      exec "$HARNESS_SCRIPTS_DIR/check-v3-projections" "${@:2}"
      ;;
    check-template-cleanliness)
      exec "$HARNESS_SCRIPTS_DIR/check-template-cleanliness" "${@:2}"
      ;;
    finalize-v3-run)
      HARNESS_WORKFLOW_VERSION=v3 HARNESS_V3_DISPATCHED=1 exec "$HARNESS_SCRIPTS_DIR/finalize-v3-run" "${@:2}"
      ;;
    check-release-fixtures)
      exec "$HARNESS_SCRIPTS_DIR/check-release-fixtures" "${@:2}"
      ;;
    offline-capability)
      exec "$HARNESS_SCRIPTS_DIR/offline-capability" "${@:2}"
      ;;
    emergency-revoke)
      exec "$HARNESS_SCRIPTS_DIR/emergency-revoke" "${@:2}"
      ;;
    recover-finalization)
      exec "$HARNESS_SCRIPTS_DIR/recover-finalization.sh" "${@:2}"
      ;;
  test)
    exec "$HARNESS_TESTS_DIR/harness/run_all.sh" "${@:2}"
    ;;
  install)
    exec "$HARNESS_SCRIPTS_DIR/install-harness.sh" "${@:2}"
    ;;
  export)
    exec "$HARNESS_SCRIPTS_DIR/export-harness-package.sh" "${@:2}"
    ;;
  *)
    fail "Usage: $0 [audit|status|next|verify|finalize|test|score|benchmark|validate-state|transition-state|check-state-schema|check-task-schema|check-test-report|check-final-report|check-rollup-projection|check-task-plan-consistency|classify-risk|bind-policy|create-checkpoint|verify-checkpoint|restore-checkpoint|check-ac-coverage|check-ac-evidence|check-verifier-verdict|record-failure|check-failure-history|rethink|spec-lock|lock-spec|run-events|events|approve-plan|break-task|intake|readiness|understand|clarify|answer|pause|resume|rollback|dispatch|intake-graph|writer-lease|capability|approval|workspace-guard|create-worktree|enforcement-gate|trusted-time|budget-guard|remediation-epoch|check-remediation-epochs|install|release-check|load-recipe|calculate-run-budget|check-v3-projections|check-template-cleanliness|finalize-v3-run|check-release-fixtures|offline-capability|emergency-revoke|recover-finalization|export]"
    ;;
esac
