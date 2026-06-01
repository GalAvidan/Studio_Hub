---
skill: handoff-research-to-animation
version: 1
studio: Studio_Hub
scope: cross-repo
initiative: campaign-infra-v1
updated: 2026-06-01
---

# Skill: handoff-research-to-animation

## Purpose

Formally promote a completed ResearchStudio research project into the AnimationStudio pipeline
by producing a structured handoff artifact in the campaign's `handoffs/` folder.

This is not a data copy — it is a **semantic translation**: research concepts → animation beats,
audience profile → animation tone and style, open questions → animation scope constraints.

## Trigger

Invoke this skill when:

1. ResearchStudio project `status: complete` (research spec is approved)
2. A `campaign` field is declared in the project's `brief.md`
3. The target AnimationStudio sub-project is `planned` or not yet created

## I/O Contract

### Input Schema

| Field | Type | Required | Source |
|---|---|---|---|
| `campaign_slug` | string | yes | project `brief.md` `campaign` field |
| `research_project_path` | string | yes | Vault-relative path to research project folder |
| `handoff_sequence_hint` | number | no | Override auto-numbering (default: auto-increment) |

### Result Schema — Success

| Field | Type | Description |
|---|---|---|
| `status` | `"ok"` | Indicates success |
| `handoff_artifact_path` | string | Vault-relative path to the created handoff artifact |
| `concept_count` | number | Number of wiki concepts mapped to beat suggestions |
| `beat_suggestion_count` | number | Total beat suggestion rows in the concept map table |
| `next_action` | string | Human-readable suggestion for the animation author |

### Result Schema — Error

| Field | Type | Description |
|---|---|---|
| `status` | `"error"` | Indicates failure |
| `error_code` | string | One of: `RESEARCH_SPEC_NOT_APPROVED`, `CAMPAIGN_NOT_FOUND`, `HANDOFF_WRITE_FAILED`, `MANIFEST_UPDATE_FAILED` |
| `message` | string | Human-readable error detail |

## Inputs

| Input | Source | Required |
|---|---|---|
| Research brief | `{projects}/<slug>/brief.md` | yes |
| Research spec (approved) | `{projects}/<slug>/output/research-spec.md` | yes |
| Wiki synthesis | `{projects}/<slug>/wiki/synthesis.md` | yes |
| Wiki concepts | `{projects}/<slug>/wiki/concepts/*.md` | yes |
| Campaign manifest | `{campaigns}/<campaign-slug>/manifest.md` | yes |
| Campaign style guide | `{campaign_shared}/style/v*/style-guide.md` | recommended |
| Existing handoffs | `{campaign_handoffs}/*.md` | for numbering |

## Outputs

1. **Handoff artifact**: `Vault/campaigns/<campaign-slug>/handoffs/NNN-research-to-animation.md`
2. **sub-projects.md update**: register or update the animation sub-project entry
3. **manifest.md handoffs table**: add a row for the new handoff (status: ready)

The skill does **not** create the AnimationStudio project — it produces the input document
for the `create-project` task in AnimationStudio to consume.

## Handoff Artifact Schema

```markdown
---
handoff-id: NNN
campaign: <campaign-slug>
from-studio: ResearchStudio
from-project: <research-project-vault-path>
to-studio: AnimationStudio
to-project: <animation-project-vault-path or "TBD">
status: ready                        # ready | consumed | superseded
research-spec-approved: YYYY-MM-DD
created: YYYY-MM-DD
---

# Handoff: <Campaign Title> — Episode <N> / <topic>

## Summary

<2-3 sentences: what was researched, what the animation should explain, for whom>

## Audience Profile

- **Primary audience**: <age range, knowledge level>
- **Assumed prior knowledge**: <what they already know>
- **Goal for viewer**: <what they should understand after watching>

## Animation Scope

- **Recommended duration**: <X–Y minutes>
- **Variant suggestion**: <general | simplified | advanced>
- **Format**: explainer / story / demonstration

## Concept Map → Beat Suggestions

| Wiki Concept | Suggested Beat ID | Suggested Narration Direction | Visual Direction |
|---|---|---|---|
| <concept from wiki/concepts/> | beat-001 | <what to say> | <what to show> |

## Key Takeaways (from synthesis.md)

<bullet list of the 3-5 most important points to communicate>

## Tone and Style Guidance

- **Tone**: <playful / serious / calm / energetic>
- **Character suggestion**: <which campaign character(s) to use>
- **Voice suggestion**: <which campaign voice>
- **Pacing**: <fast / measured / slow>

## Constraints and Scope Limits

<things the animation should NOT cover in this episode>
<open questions from research that remain unresolved>

## Source References

- Research spec: `<research-project-path>/output/research-spec.md`
- Wiki synthesis: `<research-project-path>/wiki/synthesis.md`
- Corpus sources: <list key source IDs>

## Notes for Animation Author

<any freeform guidance not captured above>
```

## Skill Steps

1. Load `campaign.md` dependency to resolve `{campaigns}` and `{campaign_handoffs}` aliases.
2. Load and validate ResearchStudio inputs (brief, approved spec, synthesis, concepts).
3. Determine next handoff sequence number by counting existing files in `{campaign_handoffs}/`.
4. Map wiki concepts to beat suggestions (one row per concept in the concept map table).
5. Derive tone and style from campaign style guide + audience profile in brief.
6. Draft handoff artifact and write to `{campaign_handoffs}/NNN-research-to-animation.md`.
7. Update `sub-projects.md`: if animation sub-project entry exists, set status → `ready`;
   if not, add a new row with status `planned`.
8. Update `manifest.md` handoffs table: add row for the new handoff.
9. Report: handoff artifact path, concept count, beat suggestions count, next action.

## Guard Rules

- Do not invoke if research spec status is not `Approved`.
- Do not overwrite an existing handoff artifact — increment the sequence number.
- Do not infer tone without a style guide; default to "clear and neutral" with a warning.
- Do not include contested or low-confidence research findings without flagging them
  in the "Constraints and Scope Limits" section.
- Only this skill (or a future designated Hub skill) writes to `sub-projects.md`. See
  locked decision #8 in the campaign plan.

## Future Extensions

- `handoff-animation-to-research` — feed animation audience questions back into a new research brief
- `handoff-research-to-research` — chain research projects within a campaign for deeper dives
