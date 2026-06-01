---
skill: query-campaigns
version: 1
studio: Studio_Hub
plugin: campaigns
initiative: campaign-infra-v1
updated: 2026-06-01
---

# Skill: query-campaigns

## Purpose

Return a summary of all campaigns: their status, participating studios,
sub-project progress, and whether any handoffs are ready but not yet consumed.

## Trigger

Invoke when asked questions like:

- "What campaigns are active?"
- "Show me the status of all campaigns."
- "Which campaigns have a ready handoff waiting?"

## Inputs

| Input | Source |
|---|---|
| Campaign manifests | `Vault/campaigns/*/manifest.md` (glob via `{campaigns_glob}` alias) |
| Sub-project registries | `Vault/campaigns/*/sub-projects.md` |
| campaign.md dependency | `Studio_Hub/agent-context/intent/dependencies/campaign.md` |

## Output Format

```
CAMPAIGN SUMMARY — <date>

┌─────────────────────────────────────────────────────────────────────┐
│ <slug>                                      status: <status>        │
│ Goal: <goal>                                                        │
│                                                                     │
│ Sub-projects:                                                       │
│   <id>   <studio>   <status>                                        │
│                                                                     │
│ Handoffs:                                                           │
│   <id>  <from> → <to>  status: <status>                            │
│                                                                     │
│ Shared resources: <N> character(s), <N> voice(s), <N> style guide  │
└─────────────────────────────────────────────────────────────────────┘

Total: <N> campaigns (<N> active, <N> planning, <N> complete)
Ready handoffs awaiting consumption: <N>
```

## Skill Steps

1. Load `campaign.md` dependency (resolves `{campaigns_glob}`).
2. Glob `Vault/campaigns/*/manifest.md` — emit "No campaigns found." and stop if glob returns empty.
3. For each manifest: read `status`, `goal`, `studios`, shared resources table row count.
4. For each campaign: read `sub-projects.md` to count rows by status.
5. For each campaign: scan `handoffs/` — count ready vs. consumed vs. superseded.
6. Assemble summary envelope and emit narrative.
7. Partial failures (one campaign manifest unreadable): log `MANIFEST_UNREADABLE` error
   with campaign slug and continue — do not abort the full query.

## Guard Rules

- Do not error if `Vault/campaigns/` does not exist — emit "No campaigns found."
- Do not synthesize campaign status from sub-project status — read only what `manifest.md` declares.
- If `sub-projects.md` is missing for a campaign, report `sub-projects: unknown` and continue.
