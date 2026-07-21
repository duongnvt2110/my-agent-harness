#!/usr/bin/env bash
set -euo pipefail
cat > sample.md <<'MD'
# Title
- alpha
- beta
Done
MD
python3 src/md2html.py sample.md out.html
grep -q '<h1>Title</h1>' out.html
grep -q '<li>alpha</li>' out.html
grep -q '<p>Done</p>' out.html
