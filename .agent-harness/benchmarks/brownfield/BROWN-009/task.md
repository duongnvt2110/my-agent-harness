# BROWN-009 Benchmark report history comparison

Existing benchmark report CLI renders one run only. Add optional `--previous` support and show `delta_score` plus trend compared with the previous run.

## Agent task

Fix the existing repository without changing unrelated behavior. Keep edits inside the allowed files listed in `metadata.json`. The fail-to-pass tests describe the new required behavior. The pass-to-pass tests describe behavior that must keep working.
