---
name: <feature-slug>
description: <one line — what this feature delivers>
state: not_started        # not_started | active | blocked | passing
owner: <agent-or-person>
depends_on: []            # other feature slugs that must be `passing` first
created: <YYYY-MM-DD>
target: <YYYY-MM-DD>
---

<!--
aos feature work-unit (ADR-0009). Lives in .claude/features/, NOT in Memory:
a feature is work-unit STATE, not knowledge (Memory keeps the 4 Anthropic types
per ADR-0002). Sized to be completable in one session. The HARNESS — not the
implementing agent — flips `state` to `passing` (see feature-evaluator skill).
Once `passing`, it must not silently revert.
-->

## Behavior
As a <role>, I can <capability>, so that <value>.
(Exactly one demoable behavior.)

## Verification
Deterministic checks the harness runs to confirm done. The agent *requests*
verification; the evaluator *decides*.
- [ ] L1 static:  <command, e.g. `npx tsc --noEmit`>
- [ ] L2 test:    <command, e.g. `vitest run path/to.test.ts`>
- [ ] L3 e2e:     <command or `n/a`>

## Definition of Done (weighted rubric)
| # | Criterion | Weight | Check | Status |
|---|---|---|---|---|
| 1 | behavior works end-to-end | 40 | <cmd> | not_started |
| 2 | tests green | 30 | <cmd> | not_started |
| 3 | guard/RBAC present (if applicable) | 20 | <grep or `n/a`> | not_started |
| 4 | clean-state: build green, no TODO/debug left | 10 | <cmd> | not_started |

Score = Σ(weight × status), where done=1.0 · in_progress=0.5 · blocked/not_started=0.
Flip to `passing` ONLY when score = 100 **and** every Verification check passes.

## Evidence
(Recorded by the harness as work lands — not asserted by the agent.)
- commit: <sha>
- test run: <log path / CI link>

## Notes / rationale
<why this feature; key decisions; links to ADR / PRD / Memory entries>
