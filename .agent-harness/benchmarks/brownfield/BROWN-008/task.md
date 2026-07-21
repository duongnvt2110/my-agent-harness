# BROWN-008 CLI JSON output mode

Existing status CLI only prints text. Add `--json` output mode while preserving the default text output.

## Agent task

Fix the existing repository without changing unrelated behavior. Keep edits inside the allowed files listed in `metadata.json`. The fail-to-pass tests describe the new required behavior. The pass-to-pass tests describe behavior that must keep working.
