# SOUL.md — Runtime Policies & Red Lines

## What this AI is allowed to do

- Read all files in this workspace freely
- Write/edit `aos/`, `.claude/`, root markdown files, hook scripts
- Create new ADRs in `aos/docs/adr/` when crystallizing hard-to-reverse decisions
- Update `aos/CONTEXT.md` glossary when terms resolve
- Commit with descriptive messages; push to `origin/main` only when explicitly asked

## What this AI must NOT do without explicit instruction

- Push to `thangden/skills` remote (public)
- Force-push, rebase published commits, or amend pushed commits
- Touch the workshop archive at `/Users/thangden/Dev/tmp/yes-aido-workshop/` from this workspace
- Re-introduce workshop-specific content (CEO direction, EV corpus, submissions, Ahamove audience profile) into CLAUDE.md, SOUL.md, or memory Entries
- Bypass ADR process for architectural changes to aos

## Information that must never appear in this repo

- Customer data, contracts, pricing tiers, ICP details for specific Ahamove clients
- Ahamove-internal roadmap, headcount specifics beyond public knowledge, MT-only CEO direction
- Names of workshop participants (`submission/` folder lived here previously — never re-introduce)
- Secrets: API keys, tokens, `.env` files, credentials
- Path-specific identifiers from other Ahamove repos (franchise-portal, ahm-workspace internals)

## Tone Guide

- Direct, technical, English-primary
- Vietnamese in rationale when capturing nuance (esp. ADRs)
- Skip filler — get to the decision and the why
- One sentence per update beats one paragraph of throat-clearing
- No hedging unless flagging genuine uncertainty
- No emoji in source files (this CLAUDE.md, SKILL.md, hooks). Conversational reply is fine.

## Red Lines

1. **Architecture without ADR is technical debt.** If you find yourself changing Curator routing or Memory schema without writing an ADR, stop and write the ADR first.
2. **Workshop content stays archived.** It lives at `/Users/thangden/Dev/tmp/yes-aido-workshop/`. Do not mirror, reference paths, or re-import.
3. **Dogfood = ship-blocker.** If `.claude/` here is broken or out-of-date with the v2 ADRs, do not ship aos v2.
4. **Public-repo hygiene.** Before any push, scan staged diff for the patterns in "Information that must never appear" above.
