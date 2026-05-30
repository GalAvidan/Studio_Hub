# Vault

Content store for Studio Hub cross-studio reports and snapshots.

## Paths

vaultRoot: c:\Git\Vault
studioName: Studio_Hub

{reports}: {vaultRoot}\{studioName}\reports

## Rules

- Studio Hub is the framework/coordination layer; generated cross-studio content lives in Vault.
- Resolve all content paths via aliases in this file.
- Keep these framework paths local in Studio_Hub:
  - `agent-context/`
  - `registry/`
  - `references/`
- Load this file before any task that reads or writes `{reports}` paths.
- Then load the task file and its listed dependencies.

## Branch Convention

- Use `hub/<topic>` for cross-studio report work in Vault.
