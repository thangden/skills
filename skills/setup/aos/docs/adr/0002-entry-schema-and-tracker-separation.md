# 0002 — One Entry schema for both Memory locations; Tracker lives outside Memory

aos v1 used three fixed buckets under `.claude/memory/`: `system-knowledge.md` for long-lived facts, `active-context.md` for the sprint tracker, and `episodic/YYYY-MM-DD.md` for per-day logs. Meanwhile, User Memory under `~/.claude/projects/<repo-hash>/memory/` is harness-managed and uses Anthropic's 4-type frontmatter (`user | feedback | project | reference`). v2 needed one canonical Entry shape across both Memory locations, and a decision on where the sprint tracker belongs.

Every Memory Entry — Workspace or User — now uses the Anthropic 4-type schema. One file per Entry. YAML frontmatter with `name`, `description`, `type`, plus optional fields. Markdown body underneath. Team or business facts that don't cleanly fit `user`, `feedback`, or `reference` are filed as `type: project` — the user's organization is the project context.

The sprint tracker moves out of the Memory layer to `.claude/active-context.md`, a sibling of `.claude/memory/`. Janitor doesn't scan the tracker; the Memory Guard hook checks tracker freshness on a separate channel. Treating the tracker as a Memory Entry caused Janitor to flag it stale on every scan in v1 — it's mutable by design — which generated enough noise that users tuned out the report entirely. Separation removes that noise and keeps the conceptual line clean: Memory is knowledge, Tracker is state.

Reusing Anthropic's 4-type taxonomy in Workspace Memory gives one Curator decision matrix, one Janitor scanner, one mental model. Keeping aos v1 buckets in Workspace Memory and using 4-type only in User Memory was rejected because two schemas means two Curator paths, two scanners, two migration scripts, and confused users. Keeping the tracker inside Memory as a `type: project` Entry was rejected because it re-introduces v1's false-positive class.

Workspace Memory may extend the type vocabulary later (e.g. add `domain`) if 4-type proves too tight — the Anthropic harness never reads Workspace Memory, so custom types are non-breaking. C-narrow ships 4-type only; any extension gets its own ADR.

Migration is no longer no-op: `system-knowledge.md` splits per-heading into individual Entries, episodic files become single Entries with the date in their `name`, and the tracker file moves path. Memory Guard now has two checks, one for Entry write recency and one for tracker freshness.
