#!/usr/bin/env bash
set -euo pipefail
python3 src/appctl.py deploy service api --env prod >out.txt
grep -q 'deploying service=api env=prod' out.txt
