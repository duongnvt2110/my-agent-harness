#!/usr/bin/env bash
set -euo pipefail
set +e
python3 src/appctl.py deploy service api >out.txt 2>err.txt
code=$?
set -e
[ "$code" -ne 0 ]
grep -q 'required: --env' err.txt
