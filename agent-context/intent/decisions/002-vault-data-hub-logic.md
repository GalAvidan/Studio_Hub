# Decision: Vault as data store, Hub repo as logic store

## Status
Accepted

## Context
Hub generates runtime data artifacts: registry records per studio, aggregated studio maps, query reports, and phase-gate evidence. These could live in the Hub repo itself or in a shared Vault.

## Decision
All Hub runtime data artifacts are stored in Vault under `Vault/studios/Studio_Hub/knowledge/hub/`. The Hub repo (`Studio_Hub`) stores only logic: agent-context files, skills, tasks, templates, and schema documentation.

## Consequences
- Vault is the authoritative storage layer for all generated content — consistent with how AnimationStudio and ResearchStudio handle their content.
- The Hub repo stays clean and version-controlled for logic changes only.
- Vault's migrate-studio skill and alias conventions apply to Hub data paths.
- Any task that reads/writes Hub data must load `agent-context/intent/dependencies/vault.md` first and use `{hub_*}` aliases exclusively.

