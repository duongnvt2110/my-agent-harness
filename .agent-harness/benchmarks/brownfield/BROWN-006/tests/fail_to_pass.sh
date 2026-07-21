#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PYINNER'
import sys
sys.path.insert(0, 'src')
from url_store import Shortener
clock = {'now': 100.0}
shortener = Shortener(now=lambda: clock['now'])
code = shortener.create('https://example.com/ttl', ttl_seconds=5)
clock['now'] = 106.0
try:
    shortener.resolve(code)
except KeyError as exc:
    assert exc.args[0] == 'expired'
else:
    raise SystemExit('expected expired link')
PYINNER
