---
plugin: campaigns
version: 1
source: vault
initiative: campaign-infra-v1
updated: 2026-06-01
---

# Campaign Plugin

## Discovery

```
glob: Vault/campaigns/*/manifest.md
dependency: campaign.md
```

This plugin is discovered automatically by the Hub dependency loader scanning
`Studio_Hub/agent-context/plugins/*/manifest.md`. No explicit registration in
`hub/manifest.md` is required.

## Skills

- `skills/campaigns/query-campaigns.skill.md`
- `skills/campaigns/query-campaign-status.skill.md`

## Error Classes

| Code | Meaning | Remediation |
|---|---|---|
| `CAMPAIGN_NOT_FOUND` | Campaign slug resolves to non-existent Vault folder | Check `Vault/campaigns/<slug>/` exists; degrade to standalone mode |
| `CAMPAIGN_MANIFEST_MISSING` | `manifest.md` not found for slug | Check `Vault/campaigns/<slug>/` exists and contains `manifest.md` |
| `CAMPAIGN_MANIFEST_INVALID` | Required field missing in manifest | Validate frontmatter: `campaign`, `status`, `goal` |
| `SUBPROJECTS_MISSING` | `sub-projects.md` not found | Create `sub-projects.md` in campaign root |
| `HANDOFF_UNREADABLE` | Handoff artifact cannot be read | Check `handoffs/` folder and file permissions |
| `MANIFEST_UNREADABLE` | A campaign manifest cannot be read during glob query | Log with slug and continue — do not abort full query |
