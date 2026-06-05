---
skill: query-commissions
version: 1
studio: Studio_Hub
plugin: commissions
updated: 2026-06-05
---

# Skill: query-commissions

## Purpose

Query the central commission registry and return a filtered view of commissions by status, studio, or attention signal.

## Trigger

Invoke when asked questions like:

- "Show all open commissions."
- "What commissions are blocked?"
- "Which commissions belong to ResearchStudio?"
- "What commissions need attention?"
- "Show non-closed commissions."
- "What commissions are related to project X?"

## Inputs

| Input | Source |
|---|---|
| Commission files | `Vault/commissions/cmsn-*.md` (glob via `{commissions_glob}`) |
| Commission index | `Vault/commissions/index.md` (quick scan; frontmatter is source of truth) |
| commission.md dependency | `Studio_Hub/agent-context/intent/dependencies/commission.md` |

## Filters

| Query | Condition |
|---|---|
| All open | `status` ∈ {proposed, committed, active, blocked} |
| Non-closed | `status` ∉ {closed, cancelled} |
| Blocked | `status == blocked` |
| By studio | `studio == <studio-id>` |
| By project | `project` contains `<path>` |
| Needs attention | `blocked` OR `open-issues > 0` OR `done` OR (`proposed` AND `updated` > 7 days ago) |

## Output Format

```
COMMISSION QUERY — <date>  [filter: <applied filter>]

┌──────────────────────────────────────────────────────────────────────────┐
│ <cmsn-id>                                    status: <status>            │
│ <title>                                                                  │
│ Studio: <studio>   Kind: <kind>   Priority: <priority>                  │
│ Project: <project or "—">                                               │
│ Updated: <date>                                                          │
│ [Blocked reason: <reason>]                 [Open issues: <N>]           │
└──────────────────────────────────────────────────────────────────────────┘

Total matching: <N>  (open: <N>, blocked: <N>, needs-attention: <N>)
```

## Skill Steps

1. Load `commission.md` dependency (resolves `{commissions_glob}`).
2. Read `Vault/commissions/index.md` for a quick snapshot; use it to detect obvious staleness.
3. Glob `Vault/commissions/cmsn-*.md` — emit "No commissions found." and stop if glob returns empty.
4. Parse frontmatter from each matching file; apply the requested filter.
5. For blocked commissions: include `blocked-reason` in the output block.
6. For needs-attention: include the attention signal (blocked / open-issues / done / stale).
7. Sort by priority (high → medium → low), then by `updated` descending.
8. Assemble output envelope and emit.
9. Partial failures (one commission file unreadable): log `COMMISSION_UNREADABLE` error with ID and continue.

## Guard Rules

- Do not error if `Vault/commissions/` does not exist — emit "No commissions found."
- Do not infer status from project state — read only what the commission frontmatter declares.
- If `index.md` is missing or stale, continue using glob — index is a convenience, not the source of truth.
- Never write to any commission file — Hub is strictly read-only.
