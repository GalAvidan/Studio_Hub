# Decision: Option B for ALES plugin install (fold into ales-update)

## Status
Accepted

## Context
Phase 0 required deciding how to handle plugin manifest installation within the ALES tooling: either a new standalone `ales-plugin-install.skill.md` (Option A) or folding the install flow into `ales-update.skill.md` (Option B). Decision was due before Phase 1; the plan specified defaulting to Option B if the deadline was missed.

## Decision
Option B: plugin install behavior is folded into `ales-update.skill.md`. A dedicated `ales-plugin-install.skill.md` is not created at this time.

## Consequences
- `ales-update` handles both ALES structural updates and plugin manifest installation when requested.
- Simpler tooling surface — no new skill file to maintain.
- A follow-up ADR should evaluate Option A if install complexity grows (e.g. manifest validation, canary checks, rollback).
- Escalation owner for any future Option A evaluation: Hub maintainer.
