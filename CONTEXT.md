# Studio Hub — Current Context

## What We Are Building

Studio Hub is the central coordination brain for the studio ecosystem. It provides agents and humans with cross-studio visibility: what each studio is working on, its current status, and any blockers. The initial version is a pure ALES markdown layer — no code, no dashboards, no push pipelines.

## What Good Looks Like

- A query like "what is each studio working on?" returns a structured envelope plus a clear narrative, or a classified error with a remediation hint.
- Studios self-declare their status signals in `agent-context/plugins/hub/manifest.md` — Hub reads only what studios choose to expose.
- Runtime data (registry, reports, snapshots) is stored in Vault. The Hub repo stays clean with logic only.
- All error cases are named, deterministic, and remediable.

## Current Phase (as of 2026-05-31)

Implementing plan_03 (v4) from initial running condition toward Phase 5 completion. Branch: `galAvidan/ImplementHub`.

## Studios in Scope

| Studio | Status |
|---|---|
| ResearchStudio | Canary — onboard first |
| AnimationStudio | Onboard after canary pass |
| Vault | Onboard after AnimationStudio pass |

## What To Avoid

- Storing operational data in `Studio_Hub/` repo paths.
- Hard-coding per-studio file paths or heuristics in Hub logic.
- Silent failures — every error must be classified and surfaced.
- Writing to studio repos during query execution.
- Skipping vault.md load before any task that uses `{hub_*}` aliases.
