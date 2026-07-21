"""Protected control-plane provenance helpers."""
from __future__ import annotations

import hashlib
import hmac
import json
import os
import pathlib


def canonical(value: dict) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()


def mac(value: dict) -> str | None:
    key_path = os.environ.get("HARNESS_PROVENANCE_KEY_FILE", "")
    if not key_path:
        return None
    path = pathlib.Path(key_path)
    if not path.is_file():
        return None
    key = path.read_bytes()
    if len(key) < 32:
        return None
    return hmac.new(key, canonical(value), hashlib.sha256).hexdigest()


def verify(value: dict) -> bool:
    supplied = value.get("issuer_mac")
    if not isinstance(supplied, str):
        return False
    unsigned = dict(value)
    unsigned.pop("issuer_mac", None)
    unsigned.pop("approval_hash", None)
    unsigned.pop("capability_hash", None)
    unsigned.pop("verdict_hash", None)
    expected = mac(unsigned)
    return expected is not None and hmac.compare_digest(supplied, expected)
