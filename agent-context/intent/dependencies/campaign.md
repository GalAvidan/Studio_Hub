---
dependency: campaign
studio: Studio_Hub
backing: vault                      # vault | github | azure | linear
updated: 2026-06-01
---

# Campaign Dependency — Studio_Hub

## Path Aliases

```
{campaigns}:          Vault/campaigns
{campaigns_glob}:     Vault/campaigns/*/manifest.md
```

## Access Model

- READ ONLY: all campaign content — manifest.md, sub-projects.md, shared/*, handoffs/*
- NEVER WRITE: Hub is read-only for all campaign data (same rule as for studio data)

## Alias Resolution

Hub resolves `{campaigns_glob}` once at query-skill load time to enumerate all campaigns.
No per-project `campaign` field — Hub discovers campaigns via folder glob, not per-project config.

## Backing System Notes

Current: Vault file-based glob. Campaign discovery = read all `manifest.md` files under `Vault/campaigns/`.
To migrate to GitHub Issues: replace glob with GitHub API list-issues call filtered by campaign label.
To migrate to Azure Work Items: replace glob with Azure Boards query.
Hub's campaign query skill is the only consumer of this alias — isolates the migration surface.

## Load Order

Loaded once when Hub agent starts or when a campaign query skill is invoked. No per-project trigger.
