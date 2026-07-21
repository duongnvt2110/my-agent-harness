#!/usr/bin/env bash
set -euo pipefail

root="."
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root)
      root="${2:-}"
      [ -n "$root" ] || fail "--root requires a directory"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--root <dir>]" >&2
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

fail() {
  echo "$*" >&2
  exit 1
}

[ -d "$root/.agent-harness" ] || fail "Missing .agent-harness directory: $root/.agent-harness"
[ -f "$root/.agent-harness/harness.sh" ] || fail "Missing public harness wrapper: $root/.agent-harness/harness.sh"
[ -x "$root/.agent-harness/harness.sh" ] || fail "Public harness wrapper is not executable: $root/.agent-harness/harness.sh"
[ -d "$root/.agent-harness/scripts" ] || fail "Missing harness scripts directory: $root/.agent-harness/scripts"
[ -d "$root/.agent-harness/docs" ] || fail "Missing harness docs directory: $root/.agent-harness/docs"
[ -d "$root/.agent-harness/docs/intake" ] || fail "Missing plan intake directory: $root/.agent-harness/docs/intake"
[ -d "$root/.agent-harness/tests" ] || fail "Missing harness tests directory: $root/.agent-harness/tests"
[ -d "$root/.agent-harness/benchmarks" ] || fail "Missing harness benchmarks directory: $root/.agent-harness/benchmarks"
[ -f "$root/.agent-harness/benchmarks/result-schema.json" ] || fail "Missing benchmark result schema: $root/.agent-harness/benchmarks/result-schema.json"
[ -d "$root/.agent-harness/benchmarks/project-build" ] || fail "Missing project-build benchmark suite: $root/.agent-harness/benchmarks/project-build"

for file in AGENTS.md README.md WORKFLOW.md CONTEXT.md .gitignore; do
  [ -f "$root/$file" ] || fail "Missing package root file: $root/$file"
done
[ -f "$root/manifest.json" ] || fail "Missing package manifest: $root/manifest.json"

python3 - "$root/manifest.json" "$root" <<'PY'
import hashlib, json, pathlib, sys
manifest = pathlib.Path(sys.argv[1]); root = pathlib.Path(sys.argv[2]); data = json.loads(manifest.read_text())
if data.get("manifest_schema_version") != 1 or data.get("canonicalization_version") != 1:
    raise SystemExit("unsupported package manifest schema")
files = data.get("files", [])
if not files or not data.get("package_hash"):
    raise SystemExit("package manifest missing file identity")
actual = []
for row in files:
    path = root / row.get("path", "")
    if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != row.get("sha256"):
        raise SystemExit(f"package file hash mismatch: {path}")
    actual.append({"path": path.relative_to(root).as_posix(), "sha256": row["sha256"]})
if actual != files:
    raise SystemExit("package manifest file ordering or set mismatch")
if hashlib.sha256(json.dumps(files, sort_keys=True, separators=(",", ":")).encode()).hexdigest() != data["package_hash"]:
    raise SystemExit("package hash mismatch")
PY

[ ! -d "$root/scripts" ] || fail "Flattened scripts directory must not exist at $root/scripts"
[ ! -d "$root/docs" ] || fail "Flattened docs directory must not exist at $root/docs"
[ ! -d "$root/tests" ] || fail "Flattened tests directory must not exist at $root/tests"

[ ! -f "$root/.agent-harness/docs/exec-plans/active/current.md" ] || fail "Active plan must not be packaged: $root/.agent-harness/docs/exec-plans/active/current.md"
[ -f "$root/.agent-harness/docs/exec-plans/active/.gitkeep" ] || fail "Missing active plan placeholder: $root/.agent-harness/docs/exec-plans/active/.gitkeep"
[ -f "$root/.agent-harness/docs/exec-plans/completed/.gitkeep" ] || fail "Missing completed plan placeholder: $root/.agent-harness/docs/exec-plans/completed/.gitkeep"
[ -f "$root/.agent-harness/docs/evidence/README.md" ] || fail "Missing evidence README: $root/.agent-harness/docs/evidence/README.md"
[ -f "$root/.agent-harness/docs/reviews/TEMPLATE.md" ] || fail "Missing review template: $root/.agent-harness/docs/reviews/TEMPLATE.md"
[ -f "$root/.agent-harness/docs/epics/README.md" ] || fail "Missing epics README: $root/.agent-harness/docs/epics/README.md"
[ -f "$root/.agent-harness/docs/exec-plans/TEMPLATE.md" ] || fail "Missing exec-plan template: $root/.agent-harness/docs/exec-plans/TEMPLATE.md"
[ -f "$root/.agent-harness/docs/tasks/tasks.jsonl" ] || fail "Missing task store: $root/.agent-harness/docs/tasks/tasks.jsonl"
[ -f "$root/.agent-harness/docs/intake/.gitkeep" ] || fail "Missing intake placeholder: $root/.agent-harness/docs/intake/.gitkeep"
if find "$root/.agent-harness/docs/exec-plans/completed" -maxdepth 1 -type f -name '*.md' ! -name '.gitkeep' -print -quit | grep -q .; then
  fail "Completed plans must not be packaged under $root/.agent-harness/docs/exec-plans/completed"
fi
if find "$root/.agent-harness/docs/intake" -maxdepth 1 -type f -name '*.md' -print -quit | grep -q .; then
  fail "Concrete intake plans must not be packaged under $root/.agent-harness/docs/intake"
fi
if find "$root/.agent-harness/docs/evidence" -mindepth 1 -maxdepth 1 -type d -print -quit | grep -q .; then
  fail "Evidence task directories must not be packaged under $root/.agent-harness/docs/evidence"
fi
if find "$root/.agent-harness/docs/reviews" -maxdepth 1 -type f -name '*.md' ! -name 'TEMPLATE.md' -print -quit | grep -q .; then
  fail "Concrete reviews must not be packaged under $root/.agent-harness/docs/reviews"
fi
if [ -f "$root/.agent-harness/docs/tasks/tasks.jsonl" ] && grep -q '[^[:space:]]' "$root/.agent-harness/docs/tasks/tasks.jsonl"; then
  fail "Task store must be empty in package: $root/.agent-harness/docs/tasks/tasks.jsonl"
fi
if find "$root" -name .DS_Store -type f -print -quit | grep -q .; then
  fail ".DS_Store files must not exist in package: $root"
fi
if find "$root" -path '*/__MACOSX*' -print -quit | grep -q .; then
  fail "__MACOSX metadata must not exist in package: $root"
fi
if find "$root" -path '*/__pycache__/*' -o -name '__pycache__' -o -name '*.pyc' | grep -q .; then
  fail "Python cache files must not exist in package: $root"
fi

echo "Package integrity checks passed."
