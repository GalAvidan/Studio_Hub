# Conventions

## Naming

- Files: `kebab-case` for all task, skill, and template files. Suffix: `.task.md`, `.skill.md`, `.template.md`.
- Folders: `kebab-case`. No uppercase. No spaces.
- Branches: `hub/<topic>` for Hub data work in Vault; `galAvidan/ImplementHub` for framework changes in this repo.
- Commits: `<type>(scope): description` — e.g. `feat(skills): add query-studio-status`, `fix(tasks): correct vault alias in refresh-map`.
  - Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`.
- Studio IDs: `kebab-case` (e.g. `animation-studio`, `research-studio`, `vault`).
- Error classes: `UPPER_SNAKE_CASE` (e.g. `MANIFEST_MISSING`, `SOURCE_UNREADABLE`).
- Aliases: `{snake_case}` (e.g. `{hub_data}`, `{hub_registry}`).

## Task and Skill Authoring

- Every task file must list `agent-context/intent/dependencies/vault.md` as its first `Load` entry if it reads or writes any `{hub_*}` alias path.
- Every skill file must declare `## id`, `## applies_to`, `## Purpose`, `## When to Use`, `## Steps`, `## Constraints`, `## Verification`, `## Ask When`.
- Every task file must declare `## id`, `## Goal`, `## Load`, `## Steps`, `## Expected Output`, `## Stop Conditions`.
- Output paths in tasks must use Vault aliases — never bare `knowledge/`, `hub/`, or `reports/` paths.

## Query Response Format

- All query skills must emit the canonical YAML envelope followed by the mandatory narrative sections in this order: Hub Query Result → Overall Status → Studio Summaries → Priority Blockers → Errors and Remediation → Recommended Next Action.
- Envelope keys `response_status`, `query_timestamp`, `studios[]`, `confidence`, and `last_refresh_timestamp` are always required.

## Manifest Versioning

- `manifest_version` uses semantic versioning (`MAJOR.MINOR.PATCH`).
- Hub accepts only same-major manifests. Breaking changes require a new major version and a migration note.

## Process

- Phase gates require sign-off recorded in `{hub_reports}/phase-gates.md`.
- Canary validation (ResearchStudio) must pass before rolling out to other studios.
- Never commit runtime data files to the Studio_Hub repo.
