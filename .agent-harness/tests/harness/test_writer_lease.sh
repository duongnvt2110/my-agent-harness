#!/usr/bin/env bash
set -euo pipefail
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
lease="$tmp/lease.json"
token="$(scripts/writer-lease.sh acquire "$lease" session-a run-1 checkout-a 30 | python3 -c 'import json,sys; print(json.load(sys.stdin)["fencing_token"])')"
scripts/writer-lease.sh validate "$lease" session-a "$token" run-1 checkout-a >/dev/null
if scripts/writer-lease.sh validate "$lease" session-b "$token" run-1 checkout-a >/dev/null 2>&1; then exit 1; fi
if scripts/writer-lease.sh validate "$lease" session-a "$token" run-2 checkout-a >/dev/null 2>&1; then exit 1; fi
if scripts/writer-lease.sh validate "$lease" session-a "$token" run-1 checkout-b >/dev/null 2>&1; then exit 1; fi
python3 - "$lease" <<'PY_EXPIRE'
import json, pathlib, sys, time
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["last_seen_epoch"] = time.time() - 60
data["expires_epoch"] = time.time() - 1
path.write_text(json.dumps(data))
PY_EXPIRE
if scripts/writer-lease.sh acquire "$lease" session-b run-1 checkout-a 30 >/dev/null 2>&1; then exit 1; fi
new_token="$(scripts/writer-lease.sh recover "$lease" session-b run-1 checkout-a 30 | python3 -c 'import json,sys; print(json.load(sys.stdin)["fencing_token"])')"
[ "$new_token" -gt "$token" ]
if scripts/writer-lease.sh validate "$lease" session-a "$token" run-1 checkout-a >/dev/null 2>&1; then exit 1; fi
if scripts/writer-lease.sh heartbeat "$lease" session-a "$token" run-1 checkout-a >/dev/null 2>&1; then exit 1; fi
python3 - "$lease" <<'PY'
import json, pathlib, sys, time
path = pathlib.Path(sys.argv[1]); data = json.loads(path.read_text())
data["last_seen_epoch"] = time.time() + 60
path.write_text(json.dumps(data))
PY
if scripts/writer-lease.sh validate "$lease" session-b "$new_token" run-1 checkout-a >/dev/null 2>&1; then exit 1; fi
echo "Writer lease regression passed."
