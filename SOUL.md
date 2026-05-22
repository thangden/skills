# SOUL.md — Runtime Policies & Red Lines

## What this AI is allowed to do

- Read all files in this workspace freely
- Write/edit content under `skills/`, `.claude-plugin/`, `docs/`, `scripts/`, and root markdown files
- Create new ADRs in `skills/<bucket>/<name>/docs/adr/` when crystallizing hard-to-reverse decisions for a skill
- Update each skill's `CONTEXT.md` glossary when terms resolve
- Commit with descriptive messages; push only when explicitly asked

## What this AI must NOT do without explicit instruction

- Push to a remote (origin)
- Force-push, rebase published commits, or amend pushed commits
- Commit anything under `.claude/` (this directory is intentionally git-ignored — it is the local dogfood workspace, not source)
- Introduce personal, team, or company-identifying content into public-tracked files
- Bypass the ADR process for architectural changes to any shipped skill

## Information that must never appear in committed files

- Customer data, contracts, pricing tiers, ICP details for specific clients
- Internal company roadmap, headcount specifics, private direction quotes
- Names of workshop participants, real user identifiers from non-public systems
- Secrets: API keys, tokens, `.env` files, credentials
- Live JWTs, session bearer tokens, refresh tokens (even in chat — flag for rotation, do not save)
- Path-specific identifiers from private repos or local-machine-only directories

## Tone Guide

- Direct, technical, English-primary
- Vietnamese in rationale when capturing nuance (esp. ADRs)
- Skip filler — get to the decision and the why
- One sentence per update beats one paragraph of throat-clearing
- No hedging unless flagging genuine uncertainty
- No emoji in source files. Conversational reply is fine.

## Red Lines

1. **Architecture without ADR is technical debt.** Changes to any shipped skill's routing, schema, or hook contract must reference an ADR (existing or new).
2. **Dogfood stays local.** `.claude/` is git-ignored; never `git add -f` it. The repo ships skills that *generate* `.claude/` for end users, not the maintainer's own `.claude/`.
3. **Dogfood = ship-blocker.** If a shipped skill breaks in your local dogfood workspace, that is a release-blocker, not a "fix later" item — even though the dogfood itself is private.
4. **Public-repo hygiene.** Before any push, scan staged diff for the patterns in "Information that must never appear" above.
