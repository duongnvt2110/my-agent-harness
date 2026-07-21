#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
import json
import threading
import urllib.error
import urllib.request

from src.url_shortener_api import Handler, ThreadingHTTPServer

server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
port = server.server_address[1]
thread = threading.Thread(target=server.serve_forever, daemon=True)
thread.start()
base = f"http://127.0.0.1:{port}"
try:
    req = urllib.request.Request(
        base + "/shorten",
        data=json.dumps({"url": "https://example.com/a"}).encode(),
        headers={"content-type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=2) as res:
        payload = json.loads(res.read())
    assert payload["short_url"].startswith("/")

    class NoRedirect(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, req, fp, code, msg, headers, newurl):
            return None

    opener = urllib.request.build_opener(NoRedirect)
    try:
        opener.open(base + payload["short_url"], timeout=2)
    except urllib.error.HTTPError as e:
        assert e.code == 302
        assert e.headers["location"] == "https://example.com/a"
    else:
        raise SystemExit("expected 302")
finally:
    server.shutdown()
    server.server_close()
    thread.join(timeout=2)
PY
