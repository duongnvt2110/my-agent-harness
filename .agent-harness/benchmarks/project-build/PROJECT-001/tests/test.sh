#!/usr/bin/env bash
set -euo pipefail
mkdir -p content
cat > content/hello.md <<'MD'
# Hello Harness
This is a generated blog post.
MD
python3 src/bloggen.py --content content --output public
grep -q '<h1>Hello Harness</h1>' public/hello.html
grep -q 'hello.html' public/index.html
