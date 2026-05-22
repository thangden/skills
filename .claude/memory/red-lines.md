---
name: red-lines
description: Non-negotiable rules for this workspace; violating them is a deliberate decision, not a default
type: feedback
scope: team
---

**Rule 1: Architecture without ADR is technical debt.**

**Why:** aos v1 accumulated implicit design (3 buckets, 30-min hook, single Memory layer) with no documented rationale. Re-deriving the why during v2 design took weeks. Future maintainers should not pay that tax again.

**How to apply:** Any change touching Curator routing, Memory schema, Hook contract, Entry shape, or Migration mechanism requires either citing an existing ADR or writing a new one. Pure bug fixes and documentation updates do not.

---

**Rule 2: Workshop content stays archived.**

**Why:** This repo is now public (thangden/skills). The previous workshop content — CEO direction, EV corpus, 55 employee submissions, Ahamove audience profile — is private MT-only material. It lives at `/Users/thangden/Dev/tmp/yes-aido-workshop/` (local archive).

**How to apply:** Never reference paths into the archive from this workspace's source files. Never re-import. If you find yourself reaching for a workshop file, you are almost certainly working on the wrong thing here.

---

**Rule 3: Dogfood = ship-blocker.**

**Why:** This workspace is itself an aos v2 workspace. If `.claude/` here is out of sync with the ADRs, or hooks misbehave, or Curator/Janitor don't work — that is a release-blocker, not a "fix later" item.

**How to apply:** Before shipping aos v2, this workspace must pass the same acceptance criteria as a freshly-generated one. If a test fails here, the bug ships everywhere.
