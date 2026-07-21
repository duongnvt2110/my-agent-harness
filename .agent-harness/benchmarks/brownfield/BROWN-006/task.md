# BROWN-006 URL shortener TTL expiration behavior

Existing URL shortener storage accepts links but ignores `ttl_seconds`. Add deterministic TTL support so expired short links raise `KeyError("expired")` while non-expired links continue to resolve.

## Agent task

Fix the existing repository without changing unrelated behavior. Keep edits inside the allowed files listed in `metadata.json`. The fail-to-pass tests describe the new required behavior. The pass-to-pass tests describe behavior that must keep working.
