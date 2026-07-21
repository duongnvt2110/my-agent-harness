#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness_root="$(cd "$script_dir/../.." && pwd)"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
root="$tmp/canonical"
mkdir -p "$root"
git -C "$root" init -q
git -C "$root" config user.email harness@example.test
git -C "$root" config user.name harness
printf 'baseline\n' > "$root/file.txt"
git -C "$root" add file.txt
git -C "$root" commit -qm baseline

record="$tmp/record.json"
created="$("$harness_root/scripts/create-worktree" create "$root" "$record" task-1 run-1 spec-hash policy-hash snapshot-hash primary verifier-1 evidence-hash ENFORCED)"
printf '%s\n' "$created" | grep -q '"enforcement_mode": "ENFORCED"'
worktree="$(printf '%s\n' "$created" | python3 -c 'import json,sys; print(json.load(sys.stdin)["worktree"])')"
if "$harness_root/scripts/create-worktree" create "$root" "$tmp/second.json" task-2 run-2 spec policy snap primary verifier evidence ENFORCED >/dev/null 2>&1; then
  echo "concurrent canonical writer was accepted" >&2
  exit 1
fi
inspect="$("$harness_root/scripts/create-worktree" inspect "$record")"
patch_hash="$(printf '%s\n' "$inspect" | python3 -c 'import json,sys; print(json.load(sys.stdin)["patch_hash"])')"
printf 'change\n' >> "$worktree/file.txt"
changed="$("$harness_root/scripts/create-worktree" inspect "$record")"
changed_patch="$(printf '%s\n' "$changed" | python3 -c 'import json,sys; print(json.load(sys.stdin)["patch_hash"])')"
[ "$changed_patch" != "$patch_hash" ]

revalidated="$("$harness_root/scripts/create-worktree" revalidate "$record" "$changed_patch" verifier-1 evidence-hash)"
printf '%s\n' "$revalidated" | grep -q '"valid": true'
if "$harness_root/scripts/create-worktree" revalidate "$record" "$patch_hash" verifier-1 evidence-hash >/dev/null 2>&1; then
  echo "stale patch was accepted" >&2
  exit 1
fi

cleaned="$("$harness_root/scripts/create-worktree" cleanup "$record")"
printf '%s\n' "$cleaned" | grep -q '"status": "CLEANED"'
"$harness_root/scripts/create-worktree" cleanup "$record" >/dev/null
[ ! -e "$worktree" ]

if "$harness_root/scripts/create-worktree" create "$root" "$tmp/audit.json" task-1 run-2 spec policy snap primary verifier evidence AUDIT_ONLY >/dev/null 2>&1; then
  echo "AUDIT_ONLY worktree mutation was accepted" >&2
  exit 1
fi
echo "Worktree isolation and canonical revalidation regression passed."
