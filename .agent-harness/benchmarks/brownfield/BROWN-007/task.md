# BROWN-007 Nested command required-flag validation

Existing deployment CLI has nested commands but runs `deploy service` without the required `--env` flag. Enforce the required flag only for the nested deploy command.

## Agent task

Fix the existing repository without changing unrelated behavior. Keep edits inside the allowed files listed in `metadata.json`. The fail-to-pass tests describe the new required behavior. The pass-to-pass tests describe behavior that must keep working.
