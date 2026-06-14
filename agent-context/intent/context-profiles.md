# Context Profiles

Use the minimal profile by default. Escalate only when you confirm a gap.

Hub is a coordination layer, not a content studio. It has no projects of its own.
See `ALES/token-efficiency-playbook.md` for the full repo-wide rules.

---

## minimal (~200 tokens, 2 files)

**When:** First message in a session, orientation, quick status lookup.

Load in order:
1. `agent-context/intent/dependencies/vault.md` — alias resolution (`{hub_data}`, `{hub_registry}`)
2. `agent-context/intent/overview.md` — coordination purpose and query model

Do **not** load skills or tasks until the specific query type is confirmed.

---

## query (~500 tokens, 4 files)

**When:** Running a studio query (status, activity, blockers) or cross-studio report.

Load in order:
1. Everything from `minimal`
2. `agent-context/map/workflow.md` — query routing
3. The matching skill file for the query type (see quick-select table)

Stop here for most Hub work.

---

## full (~2 000 tokens, all agent-context)

**When:** Onboarding a new studio, auditing Hub contracts, updating the studio registry.

Load all `agent-context/`. Hub's `agent-context/` is small; the main cost is reading studio manifests across repos.

---

## Quick-select table

| Request | Profile | File to load |
|---|---|---|
| Status of one studio | query | `query-studio-status.skill.md` + studio's `manifest.md` |
| Activity across all studios | query | `query-studio-activity.skill.md` |
| Blockers across all studios | query | `query-blockers.skill.md` |
| Cross-studio report | query | `cross-studio-report.task.md` |
| Onboard a new studio | full | `onboard-studio.task.md` + `validate-hub-contract.task.md` |
| Validate a hub contract | full | `validate-hub-contract.task.md` + studio's `manifest.md` |
