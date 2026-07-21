#!/usr/bin/env python3
import hashlib

class Shortener:
    def __init__(self, now=None):
        self.now = now or (lambda: 0.0)
        self.store = {}

    def _code(self, url: str) -> str:
        return hashlib.sha1(url.encode()).hexdigest()[:7]

    def create(self, url: str, ttl_seconds=None) -> str:
        if not isinstance(url, str) or not url.startswith(("http://", "https://")):
            raise ValueError("invalid_url")
        code = self._code(url)
        self.store[code] = {"url": url}
        return code

    def resolve(self, code: str) -> str:
        if code not in self.store:
            raise KeyError("not_found")
        return self.store[code]["url"]
