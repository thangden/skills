# Cold-Start Test — <Workspace>

A fresh Claude session, given only this repo, must be able to answer these 5
questions. If any is unanswerable from repo state, the harness is leaking context
into people's heads — fix it (the `cold-start.sh` SessionStart hook warns on the
structural ones).

1. **What is this?** → `CLAUDE.md` (Mission) + `README`.
2. **How is it organized?** → `CLAUDE.md` (Architecture) + folder layout.
3. **How do I run it?** → `README` / `CLAUDE.md`; commands in `.claude/hooks/config.env`.
4. **How do I verify a change?** → `make check` (or `.claude/hooks/config.env`: `COMPILE_CMD` / `TEST_CMD`); the Stop verify-gate runs the same.
5. **What's the current state?** → `.claude/active-context.md` (Tracker) + `.claude/memory/MEMORY.md` (decisions).

> Rule of thumb: a new teammate (or a fresh agent) should need **nothing outside the repo** to start contributing.
