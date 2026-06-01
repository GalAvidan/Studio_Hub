---
skill: query-campaign-status
version: 1
studio: Studio_Hub
plugin: campaigns
initiative: campaign-infra-v1
updated: 2026-06-01
---

# Skill: query-campaign-status

## Purpose

Return detailed status for a single named campaign — useful when drilling into the
result of `query-campaigns`.

## Trigger

Invoke when asked questions like:

- "What is the status of campaign `<slug>`?"
- "What's next for the `agentic-ai` campaign?"
- "Show me the handoffs for `math-for-kids`."

## Inputs

| Input | Source |
|---|---|
| Campaign slug | provided by the user or from `query-campaigns` output |
| Campaign manifest | `Vault/campaigns/<slug>/manifest.md` |
| Sub-project registry | `Vault/campaigns/<slug>/sub-projects.md` |
| Handoff artifacts | `Vault/campaigns/<slug>/handoffs/*.md` |
| campaign.md dependency | `Studio_Hub/agent-context/intent/dependencies/campaign.md` |

## Output Format

Detailed report for one campaign containing:

- Full sub-project list with status and notes
- Full handoff log with artifact paths and status
- Shared resource versions currently in use
- Open questions from manifest notes
- A "next action" recommendation based on current state

## Next Action Logic

| Condition | Recommended Next Action |
|---|---|
| All sub-projects planned, no handoffs | Start ResearchStudio sub-project |
| Research complete, no handoff | Invoke `handoff-research-to-animation` skill |
| Handoff ready, animation sub-project planned | Start AnimationStudio sub-project, consume handoff |
| Animation in-progress | No action; check back via `query-studio-activity` |
| All sub-projects complete | Propose updating campaign `status` to `complete` |

## Skill Steps

1. Load `campaign.md` dependency.
2. Resolve `{campaign_root}` = `Vault/campaigns/<slug>/`.
3. Check manifest.md exists — emit `CAMPAIGN_NOT_FOUND` if not.
4. Read manifest, sub-projects.md, and all handoff artifacts.
5. Derive next action from the next action logic table above.
6. Emit detailed report.

## Guard Rules

- Emit `CAMPAIGN_NOT_FOUND` (not an exception) if the slug folder does not exist.
- Do not synthesize status — always read what the files say.
- If `sub-projects.md` is missing, report `sub-projects: unknown` and continue.
