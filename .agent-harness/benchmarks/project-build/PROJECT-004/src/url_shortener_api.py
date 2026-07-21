#!/usr/bin/env python3
import hashlib
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

STORE = {}


def make_code(url: str) -> str:
    return hashlib.sha1(url.encode()).hexdigest()[:7]


class Handler(BaseHTTPRequestHandler):
    def _json(self, status: int, payload: dict) -> None:
        body = json.dumps(payload, sort_keys=True).encode()
        self.send_response(status)
        self.send_header("content-type", "application/json")
        self.send_header("content-length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        return

    def do_POST(self):
        if self.path != "/shorten":
            self._json(404, {"error": "not_found"})
            return
        length = int(self.headers.get("content-length", "0"))
        payload = json.loads(self.rfile.read(length) or b"{}")
        url = payload.get("url")
        if not isinstance(url, str) or not url.startswith(("http://", "https://")):
            self._json(400, {"error": "invalid_url"})
            return
        code = make_code(url)
        STORE[code] = url
        self._json(201, {"code": code, "short_url": f"/{code}"})

    def do_GET(self):
        code = urlparse(self.path).path.strip("/")
        if code not in STORE:
            self._json(404, {"error": "not_found"})
            return
        self.send_response(302)
        self.send_header("location", STORE[code])
        self.end_headers()


def serve(port: int) -> None:
    ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    serve(args.port)
