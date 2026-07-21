#!/usr/bin/env bash
set -euo pipefail
cmd="${1:-}"; file="${2:-}"; observed="${3:-}"
[ -n "$file" ] || { echo "Usage: trusted-time.sh observe|check|decision FILE [OBSERVED_EPOCH]" >&2; exit 2; }
python3 - "$cmd" "$file" "$observed" <<'PY'
import json,pathlib,sys,time
from datetime import datetime,timezone
cmd,path,obs=sys.argv[1:]; p=pathlib.Path(path); now=time.time(); monotonic=time.monotonic(); data=json.loads(p.read_text()) if p.exists() else {"schema_version":1,"sequence":0,"valid":True}
candidate=float(obs) if obs else now; source="untrusted_observation" if obs else "control_plane_clock"; errors=[]
if candidate < float(data.get("wall_epoch",candidate))-2: errors.append("clock rollback exceeds skew tolerance")
if cmd == "observe":
    data.update({"sequence":int(data.get("sequence",0))+1,"wall_epoch":candidate,"monotonic_observed":monotonic,"observed_at":datetime.now(timezone.utc).isoformat(),"time_source":source,"valid":not errors,"errors":errors}); p.parent.mkdir(parents=True,exist_ok=True); p.write_text(json.dumps(data,sort_keys=True,indent=2)+"\n"); print(json.dumps({"valid":data["valid"],"sequence":data["sequence"],"time_source":source,"errors":errors},sort_keys=True)); raise SystemExit(0 if data["valid"] else 1)
valid=bool(data.get("valid")) and not errors and data.get("time_source")=="control_plane_clock"
if cmd == "check":
    print(json.dumps({"valid":valid,"sequence":data.get("sequence",0),"time_source":data.get("time_source"),"errors":errors},sort_keys=True)); raise SystemExit(0 if valid else 1)
if cmd == "decision":
    result={"authority_allowed":valid,"time_valid":valid,"errors":errors or ([] if valid else ["trusted time unavailable"]),"time_source":data.get("time_source")}; print(json.dumps(result,sort_keys=True)); raise SystemExit(0 if valid else 1)
raise SystemExit("unsupported trusted-time command")
PY
