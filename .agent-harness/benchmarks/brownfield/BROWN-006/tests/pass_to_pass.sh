#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PYINNER'
import sys
sys.path.insert(0, 'src')
from url_store import Shortener
shortener = Shortener()
code = shortener.create('https://example.com/still-ok')
assert shortener.resolve(code) == 'https://example.com/still-ok'
try:
    shortener.create('ftp://bad')
except ValueError as exc:
    assert str(exc) == 'invalid_url'
else:
    raise SystemExit('expected invalid_url')
PYINNER
