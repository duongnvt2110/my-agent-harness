#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cmd="${1:-}"; shift || true
usage(){ echo "Usage: approval.sh issue|validate|consume ..." >&2; exit 2; }
if [ "$cmd" = "issue" ]; then
  out="${1:-}"; human="${2:-}"; assurance="${3:-}"; spec="${4:-}"; task="${5:-}"; run="${6:-}"; action="${7:-}"; target="${8:-}"; risk="${9:-}"; mode="${10:-}"; ttl="${11:-3600}"
  [ -n "$out" ] && [ -n "$human" ] && [ -n "$assurance" ] && [ -n "$spec" ] && [ -n "$task" ] && [ -n "$run" ] && [ -n "$action" ] && [ -n "$target" ] && [ -n "$risk" ] && [ -n "$mode" ] || usage
  python3 - "$out" "$human" "$assurance" "$spec" "$task" "$run" "$action" "$target" "$risk" "$mode" "$ttl" "$script_dir" <<'PY'
import hashlib,json,pathlib,sys,time,uuid,os
sys.path.insert(0, sys.argv[12])
from provenance import mac
from datetime import datetime,timezone,timedelta
out=pathlib.Path(sys.argv[1]); assurance=sys.argv[3]; risk=sys.argv[9]
if out.exists(): raise SystemExit("approval is immutable")
levels={"local_assertion":0,"authenticated":1,"phishing_resistant":2,"enterprise_two_person":3}; required={"tiny":0,"normal":1,"high_risk":2}
if assurance not in levels or risk not in required or levels[assurance] < required[risk]: raise SystemExit("assurance level is insufficient")
if os.environ.get("HARNESS_WORKFLOW_VERSION") == "v3":
    context=pathlib.Path(os.environ.get("HARNESS_AUTHORITY_CONTEXT", ""))
    if not context.is_file(): raise SystemExit("v3 approval requires protected authority context")
    authority=json.loads(context.read_text())
    expected={"spec_hash":sys.argv[4],"task_id":sys.argv[5],"run_id":sys.argv[6],"action":sys.argv[7],"target":sys.argv[8],"risk":risk,"enforcement_mode":sys.argv[10]}
    if any(authority.get(k) != v for k,v in expected.items()) or authority.get("authority_status") != "PROTECTED": raise SystemExit("approval context is not authoritative")
now=time.time(); record={"schema_version":1,"approval_id":str(uuid.uuid4()),"human_id":sys.argv[2],"assurance_level":assurance,"spec_hash":sys.argv[4],"task_id":sys.argv[5],"run_id":sys.argv[6],"action":sys.argv[7],"target":sys.argv[8],"risk":risk,"enforcement_mode":sys.argv[10],"issued_epoch":now,"expires_epoch":now+int(sys.argv[11]),"issued_at":datetime.now(timezone.utc).isoformat(),"expires_at":(datetime.now(timezone.utc)+timedelta(seconds=int(sys.argv[11]))).isoformat(),"single_use":True}
if risk == "high_risk" and mac(record) is None: raise SystemExit("protected provenance key is required for high-risk approval")
record["authority_status"] = "PROTECTED" if mac(record) else "UNTRUSTED_PROVISIONAL"
record["issuer_mac"] = mac(record)
record["approval_hash"]=hashlib.sha256(json.dumps(record,sort_keys=True,separators=(",",":")).encode()).hexdigest(); out.parent.mkdir(parents=True,exist_ok=True); out.write_text(json.dumps(record,sort_keys=True,indent=2)+"\n")
PY
elif [ "$cmd" = "validate" ]; then
  file="${1:-}"; spec="${2:-}"; task="${3:-}"; run="${4:-}"; action="${5:-}"; target="${6:-}"; risk="${7:-}"; mode="${8:-}"; revocation="${9:-${EMERGENCY_REVOCATION_FILE:-}}"; [ -f "$file" ] && [ -n "$mode" ] || usage
  python3 - "$file" "$spec" "$task" "$run" "$action" "$target" "$risk" "$mode" "$revocation" "$script_dir" <<'PY'
import hashlib,json,pathlib,sys,time
sys.path.insert(0, sys.argv[10])
from provenance import verify
data=json.loads(pathlib.Path(sys.argv[1]).read_text()); expected=data.get("approval_hash"); copy=dict(data); copy.pop("approval_hash",None)
if hashlib.sha256(json.dumps(copy,sort_keys=True,separators=(",",":")).encode()).hexdigest()!=expected: raise SystemExit("approval integrity mismatch")
if [data.get("spec_hash"),data.get("task_id"),data.get("run_id"),data.get("action"),data.get("target"),data.get("risk"),data.get("enforcement_mode")] != list(sys.argv[2:9]): raise SystemExit("approval context mismatch")
if float(data.get("expires_epoch",0))<=time.time(): raise SystemExit("approval expired")
if data.get("risk") == "high_risk" or data.get("enforcement_mode") == "ENFORCED":
    if not verify(data): raise SystemExit("approval lacks protected issuer provenance")
if sys.argv[9]:
    import subprocess
    if subprocess.run(["bash","scripts/emergency-revoke","check",sys.argv[9],sys.argv[1],str(int(time.time()))],capture_output=True).returncode==0: raise SystemExit("approval revoked by emergency policy")
print(json.dumps({"valid":True,"approval_id":data["approval_id"],"human_id":data["human_id"],"assurance_level":data["assurance_level"]},sort_keys=True))
PY
elif [ "$cmd" = "consume" ]; then
  file="${1:-}"; ledger="${2:-}"; [ -f "$file" ] && [ -n "$ledger" ] || usage
  hash="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["approval_hash"])' "$file")"; marker="$ledger/$hash"
  [ ! -e "$marker" ] || { echo "approval already consumed" >&2; exit 1; }; mkdir -p "$ledger"; printf '%s\n' "$hash" > "$marker"
else usage
fi
