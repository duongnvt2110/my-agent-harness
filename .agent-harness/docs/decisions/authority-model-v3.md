# V3 Authority Model

## Update History

Updated: 2026-07-15 21:18

The v3 lifecycle is authoritative in `state.json`; `current.md` is a generated
read-only projection and `events.jsonl` is an immutable hash-chained audit log.
All lifecycle transitions and event appends use the canonical event-store
implementation and journaled transition path.

Approvals, actor functions, verification evidence, risk classification,
enforcement mode, and acceptance-criterion evidence require protected
provenance in v3. Caller JSON, CLI flags, repository instructions, and
generated content cannot grant authority. Missing or unverifiable provenance
fails closed. Verification and finalization are harness-controlled functions,
not agent authority roles.

The public dispatcher accepts v3 metadata only. Mixed, missing, ambiguous,
legacy, or incompatible metadata fails closed; there is no v2 authority,
migration runtime, or legacy fallback. Historical v2 artifacts may remain as
non-authoritative evidence only. High-risk mutation is denied when mandatory
repository-local controls are not available; human approval cannot substitute
for those controls.

This repository-local kernel does not provide sandboxing, network restriction,
external identity, signed releases, deployment control, or agent-specific
adapters. Its assurance boundary is repository-local governance and does not
claim OS-level isolation or external release trust.
