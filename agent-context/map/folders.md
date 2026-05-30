# Folder Map

## Root

- `README.md`: Human-readable introduction to Studio Hub.
- `AGENTS.md`: Agent entry point — load order and operating rules for agents working in this repo.
- `CONTEXT.md`: Current operational context snapshot for agents and humans.
- `agent-context/`: Full ALES agent-context layer (intent, map, skills, tasks, templates).

## agent-context/intent/

- `overview.md`: Purpose, core workflow, principles, and agent behavior rules.
- `conventions.md`: Naming, authoring, and process conventions.
- `anti-goals.md`: Explicit non-goals and scope boundaries.
- `glossary.md`: Domain terms defined for this repo.
- `decisions/`: ADR-style records for significant architectural and workflow decisions.
- `dependencies/_index.md`: Dependency index — load before any cross-repo task.
- `dependencies/vault.md`: Vault alias contract — load before any task that reads/writes `{hub_*}` paths.

## agent-context/map/

- `folders.md`: This file — canonical folder map for the Hub repo.
- `workflow.md`: Core Hub query workflow and task routing.
- `studio-registry-schema.md`: Schema documentation for the studio registry (runtime data lives in Vault).

## agent-context/skills/

- `query-studio-status.skill.md`: How to query and report studio status across the ecosystem.
- `query-studio-activity.skill.md`: How to query current work across all studios.
- `query-blockers.skill.md`: How to surface and triage blockers across all studios.
- `integrate-ales.skill.md`: How to apply/update ALES on a studio repo as part of onboarding.
- `connect-studio.skill.md`: How to create a studio plugin manifest and register the studio with Hub.

## agent-context/tasks/

- `refresh-map.task.md`: Re-derive map/ files when the repo structure changes; bulk registry refresh.
- `cross-studio-report.task.md`: Execute a full cross-studio status/activity/blockers report to Vault.
- `onboard-studio.task.md`: Orchestrate the full studio onboarding flow (integrate-ales + connect-studio).
- `validate-hub-contract.task.md`: Run all four contract validation scenarios and produce evidence.

## agent-context/templates/

- `hub-plugin-manifest.template.md`: Starter manifest for studios joining Hub.
- `studio-registration.template.md`: Starter registry entry for a newly connected studio.

## Vault data paths (runtime, not stored here)

- `{hub_registry}/`: Per-studio registry records — `<studio>.md` per registered studio.
- `{hub_reports}/`: Phase-gate evidence, query dry-runs, validation reports.
- `{hub_snapshots}/`: Point-in-time studio state snapshots.
- `{hub_data}/studio-registry.md`: Aggregated operational map snapshot.
