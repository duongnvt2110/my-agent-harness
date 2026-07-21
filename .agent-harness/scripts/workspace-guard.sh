#!/usr/bin/env bash
set -euo pipefail
cmd="${1:-}"; root="${2:-}"; record="${3:-}"; run="${4:-}"; session="${5:-}"; token="${6:-}"
[ -n "$root" ] && [ -n "$record" ] || exit 2
hash="$(cd "$root" && { git rev-parse HEAD 2>/dev/null || printf 'not-available'; git status --porcelain=v1 2>/dev/null || true; git ls-files -s 2>/dev/null || find . -type f -not -path './.agent-harness/*' -print | sort; } | shasum -a 256 | awk '{print $1}')"
base="$(cd "$root" && git rev-parse HEAD 2>/dev/null || printf 'not-available')"
if [ "$cmd" = "acquire" ]; then
  [ -n "$run" ] && [ -n "$session" ] || exit 2
  [ ! -f "$record" ] || [ "$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("status"))' "$record")" != ACTIVE ] || { echo 'workspace already has an active writer' >&2; exit 1; }
  python3 -c 'import json,sys,uuid,time,pathlib; p=pathlib.Path(sys.argv[1]); d={"schema_version":1,"workspace_id":str(uuid.uuid4()),"root":str(pathlib.Path(sys.argv[2]).resolve()),"run_id":sys.argv[3],"session_id":sys.argv[4],"base_commit":sys.argv[5],"snapshot_hash":sys.argv[6],"status":"ACTIVE","writer_token":str(uuid.uuid4()),"acquired_epoch":time.time()}; p.parent.mkdir(parents=True,exist_ok=True); p.write_text(json.dumps(d,sort_keys=True,indent=2)+"\n"); print(d["writer_token"])' "$record" "$root" "$run" "$session" "$base" "$hash"
elif [ "$cmd" = "validate" ]; then
  [ -f "$record" ] && [ -n "$run" ] && [ -n "$session" ] && [ -n "$token" ] || exit 2
  python3 -c 'import json,sys,pathlib; d=json.load(open(sys.argv[1])); ok=d.get("status")=="ACTIVE" and d.get("root")==str(pathlib.Path(sys.argv[2]).resolve()) and d.get("run_id")==sys.argv[3] and d.get("session_id")==sys.argv[4] and d.get("writer_token")==sys.argv[5] and d.get("base_commit")==sys.argv[6] and d.get("snapshot_hash")==sys.argv[7]; print(json.dumps({"valid":ok,"workspace_id":d.get("workspace_id")},sort_keys=True)); raise SystemExit(0 if ok else 1)' "$record" "$root" "$run" "$session" "$token" "$base" "$hash"
elif [ "$cmd" = "release" ]; then
  [ -f "$record" ] && [ -n "$run" ] && [ -n "$session" ] && [ -n "$token" ] || exit 2
  python3 -c 'import json,sys,pathlib; p=pathlib.Path(sys.argv[1]); d=json.loads(p.read_text()); ok=d.get("run_id")==sys.argv[2] and d.get("session_id")==sys.argv[3] and d.get("writer_token")==sys.argv[4];
if not ok: raise SystemExit("stale workspace writer")
d["status"]="RELEASED"; p.write_text(json.dumps(d,sort_keys=True,indent=2)+"\n")' "$record" "$run" "$session" "$token"
else exit 2
fi
