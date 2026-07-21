#!/usr/bin/env bash
set -euo pipefail

HARNESS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export HARNESS_ROOT
export HARNESS_REPO_ROOT="$(cd "$HARNESS_ROOT/.." && pwd)"
export HARNESS_SCRIPT_DIR="$HARNESS_ROOT/scripts"
export HARNESS_SCRIPTS_DIR="$HARNESS_ROOT/scripts"
export HARNESS_DOCS_DIR="$HARNESS_ROOT/docs"
export HARNESS_TESTS_DIR="$HARNESS_ROOT/tests"

exec bash "$HARNESS_SCRIPT_DIR/harness.sh" "$@"
