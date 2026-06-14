# Copilot Instructions

Studio_Hub is a read-only coordination layer for the studio network. It queries studios on demand — it never writes to studio repos, never stores operational data here, and never embeds studio-specific logic outside of plugin manifests.

Use `agent-context/` as the canonical context. This file is only a VS Code Copilot adapter.

Before implementing a request, read:

- `agent-context/intent/dependencies/vault.md`
- `agent-context/intent/overview.md`
- The matching skill in `agent-context/skills/` (use `agent-context/map/skills-index.md` to find it)
- The matching task in `agent-context/tasks/` if a structured task applies (use `agent-context/map/tasks-index.md`)

**Load minimal context first** — see `agent-context/intent/context-profiles.md`.

Respect manifest read bounds: `max_files_per_query: 5`, `max_lines_per_file: 100`, `max_depth: 1`.

For terminal commands, use `rtk` as prefix: `rtk git status`.
