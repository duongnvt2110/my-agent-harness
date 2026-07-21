#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-}"
file="${2:-}"
session="${3:-}"
token="${4:-}"
run_id="${5:-}"
checkout_id="${6:-}"
ttl="${7:-30}"

if [ "$cmd" = "acquire" ] || [ "$cmd" = "recover" ]; then
  token=""
  run_id="${4:-}"
  checkout_id="${5:-}"
  ttl="${6:-30}"
fi

[ -n "$file" ] && [ -n "$session" ] && [ -n "$run_id" ] && [ -n "$checkout_id" ] || {
  echo "usage: writer-lease.sh acquire|recover FILE SESSION RUN_ID CHECKOUT_ID [TTL]; validate|heartbeat|release FILE SESSION TOKEN RUN_ID CHECKOUT_ID [TTL]" >&2
  exit 2
}
case "$ttl" in ''|*[!0-9]*) echo "ttl must be a positive integer" >&2; exit 2;; esac
[ "$ttl" -gt 0 ] || { echo "ttl must be positive" >&2; exit 2; }

lock="$file.lock"
mkdir "$lock" 2>/dev/null || { echo "lease record busy" >&2; exit 75; }
trap 'rmdir "$lock" 2>/dev/null || true' EXIT

python3 - "$cmd" "$file" "$session" "$token" "$run_id" "$checkout_id" "$ttl" <<'PY'
import json, pathlib, sys, time, uuid
from datetime import datetime, timezone, timedelta

cmd, name, session, token, run_id, checkout_id, ttl = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6], int(sys.argv[7])
path = pathlib.Path(name)
now_wall = time.time()
now_mono = time.monotonic()
data = json.loads(path.read_text()) if path.exists() else None

def bound(record):
    return (record.get("session_id") == session and record.get("run_id") == run_id and
            record.get("checkout_id") == checkout_id and str(record.get("fencing_token")) == token)

def check_clock(record):
    if now_wall < float(record.get("last_seen_epoch", record.get("issued_epoch", now_wall))):
        raise SystemExit("trusted UTC clock rollback detected; recovery required")
    if now_mono < float(record.get("issued_monotonic", now_mono)):
        raise SystemExit("monotonic clock reboot boundary detected; recovery required")

def expired(record):
    check_clock(record)
    return (now_mono >= float(record.get("issued_monotonic", now_mono)) + float(record.get("duration_seconds", 0))
            or now_wall >= float(record.get("expires_epoch", 0)))

if cmd in ("acquire", "recover"):
    if data and data.get("status") == "ACTIVE" and not expired(data):
        raise SystemExit("writer lease already active")
    if data and data.get("status") == "ACTIVE" and cmd == "acquire":
        raise SystemExit("writer lease expired; recovery required")
    fencing = int(data.get("fencing_token", 0)) + 1 if data else 1
    record = {
        "schema_version": 2, "lease_id": str(uuid.uuid4()), "session_id": session,
        "run_id": run_id, "checkout_id": checkout_id, "fencing_token": fencing,
        "status": "ACTIVE", "issued_epoch": now_wall, "last_seen_epoch": now_wall,
        "expires_epoch": now_wall + ttl, "issued_monotonic": now_mono,
        "duration_seconds": ttl, "issued_at": datetime.now(timezone.utc).isoformat(),
        "expires_at": (datetime.now(timezone.utc) + timedelta(seconds=ttl)).isoformat(),
        "time_source": "persisted_utc_and_monotonic_control_plane", "recovery": cmd == "recover",
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(record, sort_keys=True, indent=2) + "\n")
    print(json.dumps(record, sort_keys=True))
    raise SystemExit(0)

if not data or not bound(data):
    raise SystemExit("stale writer lease binding")
if data.get("status") != "ACTIVE":
    raise SystemExit("writer lease is not active")
if expired(data):
    raise SystemExit("invalid or expired writer lease")

if cmd == "validate":
    print(json.dumps({"valid": True, "session_id": session, "run_id": run_id, "checkout_id": checkout_id,
                      "fencing_token": data["fencing_token"]}, sort_keys=True))
elif cmd == "heartbeat":
    data["last_seen_epoch"] = now_wall
    data["expires_epoch"] = now_wall + ttl
    data["duration_seconds"] = ttl
    data["expires_at"] = (datetime.now(timezone.utc) + timedelta(seconds=ttl)).isoformat()
    path.write_text(json.dumps(data, sort_keys=True, indent=2) + "\n")
elif cmd == "release":
    data["status"] = "RELEASED"
    data["last_seen_epoch"] = now_wall
    path.write_text(json.dumps(data, sort_keys=True, indent=2) + "\n")
else:
    raise SystemExit("unsupported lease command")
PY
