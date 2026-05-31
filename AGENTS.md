# Studio Hub Agent Guide

Studio Hub is the central coordination layer for the studio ecosystem. It answers cross-studio queries about status, current work, and blockers by reading each studio's self-declared plugin manifest. This is not a general-purpose repo — it is the ecosystem coordination brain.

## First Read

Before any Hub work, load these files in order:

1. `agent-context/intent/dependencies/vault.md` — alias contract for all Hub data paths
2. `agent-context/intent/dependencies/_index.md` — dependency index
3. `agent-context/intent/overview.md` — purpose, principles, and agent behavior
4. `agent-context/map/workflow.md` — routing and load-order rules
5. The specific skill or task file matching the user's request

## Operating Rules

- **Logic lives here; data lives in Vault.** Never write operational data to `Studio_Hub/` paths. All runtime outputs go to `{hub_registry}`, `{hub_reports}`, or `{hub_snapshots}`.
- **Load vault.md first** for any task that reads or writes `{hub_*}` alias paths.
- **Never hard-code per-studio logic.** All studio-specific knowledge must come from `agent-context/plugins/hub/manifest.md` in the studio's own repo.
- **Deterministic errors.** When a studio manifest is missing, invalid, or a source is unreadable, emit the exact error class (`MANIFEST_MISSING`, `MANIFEST_INVALID`, `SOURCE_UNREADABLE`, etc.) with a remediation hint — do not guess at studio state.
- **Partial failures are allowed.** A single studio failure must not abort the full query. Aggregate what is available and surface errors per studio.
- **Canary first.** ResearchStudio is the canary studio. Always validate canary results before rolling out to AnimationStudio and Vault.

## Query Skills

- `agent-context/skills/query-studio-status.skill.md` — status across all studios
- `agent-context/skills/query-studio-activity.skill.md` — current work across all studios
- `agent-context/skills/query-blockers.skill.md` — blockers and triage

## Onboarding

- `agent-context/tasks/onboard-studio.task.md` — full studio onboarding orchestration

## Validation

- `agent-context/tasks/validate-hub-contract.task.md` — run all four contract scenarios before any phase gate sign-off

## Data Locations (Vault)

- Registry records: `{hub_registry}/<studio>.md`
- Reports and evidence: `{hub_reports}/`
- Snapshots: `{hub_snapshots}/`
- Aggregate map: `{hub_data}/studio-registry.md`
