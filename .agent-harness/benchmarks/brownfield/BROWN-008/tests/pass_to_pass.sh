#!/usr/bin/env bash
set -euo pipefail
python3 src/statusctl.py api >out.txt
grep -q '^api ok replicas=3$' out.txt
