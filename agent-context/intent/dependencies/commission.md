---
dependency: commission
studio: Studio_Hub
backing: vault
updated: 2026-06-05
---

# Commission Dependency — Studio_Hub

## Path Aliases

```
{commissions}:       Vault/commissions
{commissions_glob}:  Vault/commissions/cmsn-*.md
```

## Access Model

- READ ONLY: all commission content — `cmsn-*.md` files and `index.md`
- NEVER WRITE: Hub is read-only for all commission data (same rule as for studio and campaign data)

## Alias Resolution

Hub resolves `{commissions_glob}` once at query-skill load time to enumerate all commissions.
Ownership is determined by the `studio:` frontmatter field — no per-studio sub-folders to traverse.

## Backing System Notes

Current: Vault file-based glob. Commission discovery = read all `cmsn-*.md` files under `Vault/commissions/`.
To migrate to GitHub Issues: replace glob with GitHub API list-issues call filtered by a commission label.
Hub's commission query skill is the only consumer of this alias — isolates the migration surface.

## Load Order

Loaded once when Hub agent starts or when a commission query skill is invoked. No per-project trigger.
