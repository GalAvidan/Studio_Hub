# Vault

Content store for Studio Hub cross-studio data, registry, and generated reports.

## Paths

vaultRoot: Vault
studioName: Studio_Hub

{knowledge}: {vaultRoot}\{studioName}\knowledge
{hub_data}: {knowledge}\hub
{hub_registry}: {hub_data}\registry
{hub_reports}: {hub_data}\reports
{hub_snapshots}: {hub_data}\snapshots

## Rules

- Studio Hub is the logic/framework layer; all runtime data, registry records, and generated reports live in Vault.
- Resolve all content paths via aliases in this file.
- Keep these framework paths local in Studio_Hub:
  - `agent-context/`
  - `references/`
  - `projects/_template/`
- Load this file before any task that reads or writes `{hub_data}`, `{hub_registry}`, `{hub_reports}`, or `{hub_snapshots}` paths.
- Then load the task file and its listed dependencies.
- Never store operational data under `Studio_Hub/` repo paths outside of `agent-context/` logic scaffolding.
- Path rewrite compatibility: rewrite bare `knowledge/` and bare `hub/` to `{knowledge}/` in tasks and skills.

## Branch Convention

- Use `hub/<topic>` for Hub data work in Vault.
- Use `feat/<topic>` or `fix/<topic>` for Hub framework/logic changes in Studio_Hub repo.
