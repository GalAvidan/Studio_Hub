# Workflow

## Core Lifecycle

```
Query received  →  Load vault.md  →  Resolve studio list  →  Read manifest  →  Fetch sources  →  Assemble envelope  →  Emit narrative
```

The order is fixed. Manifest validation precedes every source read. Per-studio failures do not abort the full query — they produce per-studio error entries.

## Stage Routing

| Stage | Task / Skill file | Entry condition |
|---|---|---|
| Query studio status | `skills/query-studio-status.skill.md` | User asks about system-wide or per-studio status |
| Query current activity | `skills/query-studio-activity.skill.md` | User asks what studios are working on |
| Query blockers | `skills/query-blockers.skill.md` | User asks about blockers, impediments, or risks |
| Cross-studio report | `tasks/cross-studio-report.task.md` | Full ecosystem report requested |
| Onboard a studio | `tasks/onboard-studio.task.md` | New studio being added to Hub |
| Refresh Hub map | `tasks/refresh-map.task.md` | Hub repo structure has changed |
| Validate Hub contract | `tasks/validate-hub-contract.task.md` | Phase gate validation or weekly cadence |
| Refresh registry data | `tasks/refresh-map.task.md` | Studio registry data is stale |

## Decision Points

- **Manifest missing**: emit `MANIFEST_MISSING` for that studio; continue with remaining studios.
- **Manifest invalid**: emit `MANIFEST_INVALID` with checklist failure details; continue with remaining studios.
- **Source unreadable**: emit `SOURCE_UNREADABLE` for the affected source; record partial confidence.
- **All studios fail**: set `response_status: degraded`; still emit full envelope with per-studio errors.
- **Registry stale** (>168h): downgrade confidence to `low`; emit `REGISTRY_STALE`; recommend running `refresh-map.task.md`.

## Load Order Rule

Every Hub skill or task that reads or writes Hub data must load these files first:
1. `agent-context/intent/dependencies/vault.md`
2. `agent-context/intent/dependencies/_index.md`
3. The specific task or skill file
4. Any referenced template or schema files
