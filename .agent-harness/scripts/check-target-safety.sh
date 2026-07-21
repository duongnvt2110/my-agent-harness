#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/harness-lib.sh"
resolve_harness_paths
cd "$HARNESS_ROOT"

target=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      target="${2:-}"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 --target <dir>" >&2
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[ -n "$target" ] || fail "Missing --target <dir>"
case "$target" in
  ""|"/"|"$HOME")
    fail "Refusing unsafe target path: $target"
    ;;
esac

abs_target="$(python3 - "$target" <<'PY'
import os, sys
print(os.path.abspath(sys.argv[1]))
PY
)"

case "$abs_target" in
  "/"|"$HOME")
    fail "Refusing unsafe target path: $abs_target"
    ;;
esac

echo "$abs_target"
