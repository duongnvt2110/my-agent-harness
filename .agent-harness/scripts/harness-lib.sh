#!/usr/bin/env bash

resolve_harness_paths() {
  local caller="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
  local caller_dir
  caller_dir="$(cd "$(dirname "$caller")" && pwd)"

  if [ -z "${HARNESS_ROOT:-}" ]; then
    if [ "$(basename "$caller_dir")" = "scripts" ]; then
      HARNESS_ROOT="$(cd "$caller_dir/.." && pwd)"
    else
      HARNESS_ROOT="$(pwd)"
    fi
  fi
  if [ -z "${HARNESS_REPO_ROOT:-}" ]; then
    HARNESS_REPO_ROOT="$(cd "$HARNESS_ROOT/.." && pwd)"
  fi
  if [ -z "${HARNESS_SCRIPT_DIR:-}" ]; then
    HARNESS_SCRIPT_DIR="$HARNESS_ROOT/scripts"
  fi
  if [ -z "${HARNESS_SCRIPTS_DIR:-}" ]; then
    HARNESS_SCRIPTS_DIR="$HARNESS_ROOT/scripts"
  fi
  if [ -z "${HARNESS_DOCS_DIR:-}" ]; then
    HARNESS_DOCS_DIR="$HARNESS_ROOT/docs"
  fi
  if [ -z "${HARNESS_TESTS_DIR:-}" ]; then
    HARNESS_TESTS_DIR="$HARNESS_ROOT/tests"
  fi
  if [ -n "${HARNESS_STATE_DIR:-}" ] && [ -z "${PLAN_PATH:-}" ]; then
    PLAN_PATH="$HARNESS_STATE_DIR/exec-plans/active/current.md"
  elif [ -z "${PLAN_PATH:-}" ]; then
    PLAN_PATH="$HARNESS_DOCS_DIR/exec-plans/active/current.md"
  fi

  export HARNESS_ROOT
  export HARNESS_REPO_ROOT
  export HARNESS_SCRIPT_DIR
  export HARNESS_SCRIPTS_DIR
  export HARNESS_DOCS_DIR
  export HARNESS_TESTS_DIR
  export PLAN_PATH
}

resolve_harness_paths

fail() {
  echo "$*" >&2
  exit 1
}

fm_value() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    BEGIN {in_fm=0}
    /^---$/ {if (!in_fm) {in_fm=1; next} else {exit}}
    in_fm && $0 ~ "^" key ":[[:space:]]*" {
      line=$0
      sub("^" key ":[[:space:]]*", "", line)
      gsub(/^"|"$/, "", line)
      gsub(/^'\''|'\''$/, "", line)
      print line
      exit
    }
  ' "$file"
}

fm_has_key() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    BEGIN {in_fm=0; found=0}
    /^---$/ {if (!in_fm) {in_fm=1; next} else {exit}}
    in_fm && $0 ~ "^" key ":[[:space:]]*" {found=1; exit}
    END {exit(found?0:1)}
  ' "$file"
}

fm_list() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    BEGIN {in_fm=0; in_list=0}
    /^---$/ {
      if (!in_fm) {in_fm=1; next}
      else {exit}
    }
    !in_fm {next}
    $0 ~ "^" key ":[[:space:]]*\\[\\][[:space:]]*$" {exit}
    $0 ~ "^" key ":[[:space:]]*$" {in_list=1; next}
    in_list {
      if ($0 ~ /^[[:space:]]*-[[:space:]]+/) {
        line=$0
        sub(/^[[:space:]]*-[[:space:]]+/, "", line)
        gsub(/^"|"$/, "", line)
        print line
        next
      }
      if ($0 ~ /^[[:space:]]*$/) {next}
      if ($0 ~ /^[^[:space:]]/) {exit}
    }
  ' "$file"
}

fm_list_count() {
  fm_list "$1" "$2" | awk 'END {print NR+0}'
}

plan_uses_state_root() {
  [ -n "${HARNESS_STATE_DIR:-}" ] || return 1
  case "$PLAN_PATH" in
    "$HARNESS_STATE_DIR"/*) return 0 ;;
    *) return 1 ;;
  esac
}

context_doc="CON""TEXT.md"

scope_patterns() {
  local scope="$1"
  local task_id
  task_id="$(fm_value "$PLAN_PATH" "task_id")"

  case "$scope" in
    harness_core)
      printf '%s\n' \
        AGENTS.md \
        README.md \
        WORKFLOW.md \
        harness.sh \
        "$context_doc" \
        'scripts/**' \
        'policies/**'
      ;;
    harness_docs)
      printf '%s\n' \
        'docs/context/**' \
        'docs/TEST_MATRIX.md' \
        'docs/reports/**' \
        'docs/PLANS.md' \
        'docs/prompts/**' \
        'docs/adr/**' \
        'docs/decisions/**' \
        'docs/epics/**' \
        'docs/tasks/**' \
        'docs/exec-plans/**' \
        'docs/evidence/**' \
        'docs/design-docs/**' \
        'docs/product-contracts/**' \
        'docs/product-specs/**' \
        'docs/specifications/**' \
        'docs/reference/**' \
        'docs/reviews/**'
      ;;
    harness_state)
      printf '%s\n' \
        'docs/exec-plans/**' \
        'docs/evidence/**' \
        'docs/reviews/**' \
        'docs/epics/**' \
        'docs/tasks/**'
      ;;
    app_source)
      printf '%s\n' \
        'src/**' \
        'app/**' \
        'pages/**' \
        'components/**' \
        'lib/**' \
        'internal/**' \
        'pkg/**' \
        'cmd/**'
      ;;
    app_tests)
      printf '%s\n' \
        'tests/**' \
        'test/**' \
        '__tests__/**' \
        '**/*_test.*' \
        '**/*.test.*' \
        'tests/harness/**'
      ;;
    app_config)
      printf '%s\n' \
        package.json \
        package-lock.json \
        pnpm-lock.yaml \
        yarn.lock \
        tsconfig.json \
        tsconfig.*.json \
        go.mod \
        go.sum \
        Cargo.toml \
        pyproject.toml \
        Makefile \
        .env.example \
        next.config.* \
        vite.config.* \
        astro.config.*
      ;;
    app_docs)
      printf '%s\n' \
        README.md \
        'docs/**' \
        CHANGELOG.md \
        CONTRIBUTING.md
      ;;
    task_evidence)
      if plan_uses_state_root; then
        printf '%s\n' "$HARNESS_STATE_DIR/evidence/$task_id/**"
      else
        printf '%s\n' ".agent-harness/docs/evidence/$task_id/**"
      fi
      ;;
    *)
      return 1
      ;;
  esac
}

expand_scopes() {
  local scope
  for scope in "$@"; do
    scope_patterns "$scope"
  done
}

has_active_plan() {
  [ -f "$PLAN_PATH" ]
}

full_context_file() {
  echo "$(evidence_dir)/full-context.md"
}

require_full_context() {
  local file
  file="$(full_context_file)"
  [ -f "$file" ] || fail "Missing full context evidence: $file"
}

run_cmd() {
  if command -v rtk >/dev/null 2>&1; then
    rtk "$@"
  else
    "$@"
  fi
}

set_fm_value() {
  local file="$1"
  local key="$2"
  local value="$3"
  local tmp
  tmp="$(mktemp)"
  awk -v key="$key" -v value="$value" '
    BEGIN {in_fm=0; done=0}
    NR==1 && $0=="---" {in_fm=1; print; next}
    in_fm && $0=="---" {
      if (!done) {
        print key ": " value
      }
      in_fm=0
      print
      next
    }
    in_fm && $0 ~ "^" key ":[[:space:]]*" {
      print key ": " value
      done=1
      next
    }
    {print}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

required_check_rows() {
  local file="$1"
  awk '
    function clean(v) {
      sub(/^[[:space:]]+/, "", v)
      sub(/[[:space:]]+$/, "", v)
      gsub(/^"|"$/, "", v)
      return v
    }
    function emit() {
      if (id != "") {
        if (blocking == "") {blocking="true"}
        print id "\t" type "\t" command "\t" blocking "\t" timeout_seconds "\t" evidence "\t" allow_raw_command "\t" raw_command_reason "\t" reason
      }
      id=""; type=""; command=""; blocking=""; evidence=""; allow_raw_command=""; raw_command_reason=""; reason=""; timeout_seconds=""
    }
    BEGIN {in_fm=0; in_checks=0}
    /^---$/ {
      if (!in_fm) {in_fm=1; next}
      emit()
      exit
    }
    !in_fm {next}
    /^required_checks:[[:space:]]*$/ {in_checks=1; next}
    in_checks && /^[^[:space:]]/ {emit(); exit}
    in_checks && /^[[:space:]]*-[[:space:]]id:/ {
      emit()
      line=$0
      sub(/^[[:space:]]*-[[:space:]]id:[[:space:]]*/, "", line)
      id=clean(line)
      next
    }
    in_checks && /^[[:space:]]+[A-Za-z_]+:/ {
      line=$0
      key=line
      sub(/^[[:space:]]+/, "", key)
      sub(/:.*/, "", key)
      sub(/^[[:space:]]+[A-Za-z_]+:[[:space:]]*/, "", line)
      value=clean(line)
      if (key == "type") {type=value}
      else if (key == "command") {command=value}
      else if (key == "blocking") {blocking=value}
      else if (key == "evidence") {evidence=value}
      else if (key == "allow_raw_command") {allow_raw_command=value}
      else if (key == "raw_command_reason") {raw_command_reason=value}
      else if (key == "reason") {reason=value}
      else if (key == "timeout_seconds") {timeout_seconds=value}
    }
  ' "$file"
}

matches_any_pattern() {
  local path="$1"
  shift
  local pattern
  for pattern in "$@"; do
    if [[ "$path" == $pattern ]]; then
      return 0
    fi
  done
  return 1
}

evidence_dir() {
  local task_id
  task_id="$(fm_value "$PLAN_PATH" "task_id")"
  if plan_uses_state_root; then
    echo "$HARNESS_STATE_DIR/evidence/$task_id"
  else
    echo "docs/evidence/$task_id"
  fi
}

write_failure_packet() {
  local failed_check="$1"
  local command="$2"
  local exit_code="$3"
  local output_file="$4"
  local dir packet
  dir="$(evidence_dir)"
  mkdir -p "$dir"
  packet="$dir/failure-packet.md"
  {
    echo "# Failure Packet"
    echo
    echo "## Task ID"
    echo
    fm_value "$PLAN_PATH" "task_id"
    echo
    echo "## Failed Check"
    echo
    echo "$failed_check"
    echo
    echo "## Command"
    echo
    echo '```text'
    echo "$command"
    echo '```'
    echo
    echo "## Exit Code"
    echo
    echo "$exit_code"
    echo
    echo "## Relevant Output"
    echo
    echo '```text'
    head -c 6000 "$output_file" 2>/dev/null || true
    echo
    echo '```'
    echo
    echo "## Approved Fix Scope"
    echo
    echo '```text'
    fm_list "$PLAN_PATH" "approved_files"
    echo '```'
    echo
    echo "## Next Allowed Action"
    echo
    echo "Fix the failed check inside the approved file map, then rerun verification."
  } > "$packet"
}
