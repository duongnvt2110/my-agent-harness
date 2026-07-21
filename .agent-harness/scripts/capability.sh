#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cmd="${1:-}"; shift || true
usage(){ echo "Usage: capability.sh issue|validate ..." >&2; exit 2; }
if [ "$cmd" = "issue" ]; then
  out="${1:-}"; intake="${2:-}"; task="${3:-}"; run="${4:-}"; spec="${5:-}"; policy="${6:-}"; snapshot="${7:-}"; role="${8:-}"; session="${9:-}"; ops="${10:-}"; mode="${11:-}"; ttl="${12:-60}"
  [ -n "$out" ] && [ -n "$intake" ] && [ -n "$task" ] && [ -n "$run" ] && [ -n "$spec" ] && [ -n "$policy" ] && [ -n "$snapshot" ] && [ -n "$role" ] && [ -n "$session" ] && [ -n "$ops" ] && [ -n "$mode" ] || usage
  python3 - "$out" "$intake" "$task" "$run" "$spec" "$policy" "$snapshot" "$role" "$session" "$ops" "$mode" "$ttl" "$script_dir" <<'PY'
import hashlib, json, pathlib, sys, time, uuid, os
sys.path.insert(0, sys.argv[13])
from provenance import mac
from datetime import datetime, timezone
out=pathlib.Path(sys.argv[1])
if out.exists(): raise SystemExit("capability is immutable")
if os.environ.get("HARNESS_WORKFLOW_VERSION") == "v3":
    context=pathlib.Path(os.environ.get("HARNESS_AUTHORITY_CONTEXT", ""))
    if not context.is_file(): raise SystemExit("v3 capability requires protected authority context")
    authority=json.loads(context.read_text())
    expected={"intake_id":sys.argv[2],"task_id":sys.argv[3],"run_id":sys.argv[4],"spec_hash":sys.argv[5],"policy_hash":sys.argv[6],"snapshot_hash":sys.argv[7],"role":sys.argv[8],"session_id":sys.argv[9],"enforcement_mode":sys.argv[11]}
    if any(authority.get(k) != v for k,v in expected.items()) or authority.get("authority_status") != "PROTECTED": raise SystemExit("capability context is not authoritative")
operations=sorted(set(filter(None,sys.argv[10].split(","))))
if not operations: raise SystemExit("capability operation set cannot be empty")
if sys.argv[11] not in {"ENFORCED","AUDIT_ONLY"}: raise SystemExit("unsupported enforcement mode")
record={"schema_version":1,"canonicalization_version":1,"capability_id":str(uuid.uuid4()),"intake_id":sys.argv[2],"task_id":sys.argv[3],"run_id":sys.argv[4],"spec_hash":sys.argv[5],"policy_hash":sys.argv[6],"snapshot_hash":sys.argv[7],"role":sys.argv[8],"session_id":sys.argv[9],"operations":operations,"enforcement_mode":sys.argv[11],"binding":"TECHNICAL" if sys.argv[11]=="ENFORCED" else "ADVISORY_AUDIT_ONLY","issued_epoch":time.time(),"expires_epoch":time.time()+int(sys.argv[12]),"issued_at":datetime.now(timezone.utc).isoformat()}
if sys.argv[11] == "ENFORCED" and mac(record) is None: raise SystemExit("protected provenance key is required for enforced capability")
record["authority_status"] = "PROTECTED" if mac(record) else "UNTRUSTED_PROVISIONAL"
record["issuer_mac"] = mac(record)
canonical=json.dumps(record,sort_keys=True,separators=(",",":")); record["capability_hash"]=hashlib.sha256(canonical.encode()).hexdigest()
out.parent.mkdir(parents=True,exist_ok=True); out.write_text(json.dumps(record,sort_keys=True,indent=2)+"\n"); print(json.dumps(record,sort_keys=True))
PY
elif [ "$cmd" = "validate" ]; then
  file="${1:-}"; role="${2:-}"; session="${3:-}"; op="${4:-}"; revocation="${5:-${EMERGENCY_REVOCATION_FILE:-}}"; [ -f "$file" ] && [ -n "$role" ] && [ -n "$session" ] && [ -n "$op" ] || usage
  python3 - "$file" "$role" "$session" "$op" "$revocation" "$script_dir" <<'PY'
import hashlib,json,pathlib,sys,time
sys.path.insert(0, sys.argv[6])
from provenance import verify
data=json.loads(pathlib.Path(sys.argv[1]).read_text()); expected=data.get("capability_hash"); copy=dict(data); copy.pop("capability_hash",None); actual=hashlib.sha256(json.dumps(copy,sort_keys=True,separators=(",",":")).encode()).hexdigest()
if data.get("schema_version")!=1 or expected!=actual: raise SystemExit("capability integrity mismatch")
if data.get("enforcement_mode") == "ENFORCED" and not verify(data): raise SystemExit("capability lacks protected issuer provenance")
if data.get("role")!=sys.argv[2] or data.get("session_id")!=sys.argv[3] or sys.argv[4] not in data.get("operations",[]): raise SystemExit("capability context or operation mismatch")
if float(data.get("expires_epoch",0))<=time.time(): raise SystemExit("capability expired")
if sys.argv[5]:
    import subprocess
    if subprocess.run(["bash","scripts/emergency-revoke","check",sys.argv[5],sys.argv[1],str(int(time.time()))],capture_output=True).returncode==0: raise SystemExit("capability revoked by emergency policy")
print(json.dumps({"valid":True,"capability_id":data["capability_id"],"role":data["role"],"operation":sys.argv[4],"binding":data["binding"],"assurance_limitations":["role binding advisory in AUDIT_ONLY"] if data["binding"]=="ADVISORY_AUDIT_ONLY" else []},sort_keys=True))
PY
else usage
fi
