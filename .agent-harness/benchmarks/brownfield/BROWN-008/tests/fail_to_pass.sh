#!/usr/bin/env bash
set -euo pipefail
python3 src/statusctl.py api --json >out.json
python3 - <<'PYINNER'
import json
row=json.load(open('out.json'))
assert row == {'name':'api','replicas':3,'status':'ok'}, row
PYINNER
