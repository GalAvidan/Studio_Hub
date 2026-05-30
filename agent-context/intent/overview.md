# Overview

## Purpose

Studio Hub is the central coordination layer and single source of truth across all studios (AnimationStudio, ResearchStudio, Vault, and future studios). It answers conversational queries about system-wide status, current work, and blockers — by reading each studio's self-declared plugin manifest on demand. Studio Hub stores only logic, templates, and framework; all runtime data artifacts are stored in Vault.

## Core Workflow

```
Query received  →  Load vault.md  →  Read studio plugin manifest  →  Fetch declared sources  →  Assemble envelope  →  Emit narrative
```

The order is fixed. Manifest validation precedes every source read. Partial failures per studio do not fail the global query.

## Principles

1. **Pull-based, read-only.** Hub never writes to studio repos. It reads only what studios declare in their plugin manifests.
2. **Plugin-first.** Hub never hard-codes per-studio heuristics. All studio-specific knowledge comes from `agent-context/plugins/hub/manifest.md` in each studio repo.
3. **Vault for data, Hub for logic.** Runtime data (registry records, reports, snapshots) lives in Vault under `{hub_data}`. Framework logic, skills, tasks, and templates live in this repo.
4. **Deterministic errors.** Every failure mode has a named error class and a remediation hint. No silent failures.
5. **Additive evolution.** New studios are onboarded without modifying existing files. New manifest fields are additive under semantic versioning.
6. **Least privilege.** Hub reads only paths explicitly declared in `security.allow_paths` in each studio's manifest.
7. **Confidence is earned, not assumed.** Confidence levels (high/medium/low) are assigned deterministically based on source readability and freshness.

## Agent Behavior

- Always load `agent-context/intent/dependencies/vault.md` before any task that reads or writes Hub data paths.
- Load `agent-context/intent/dependencies/_index.md` before any cross-repo task.
- Do not preload all context — load only what the current task's `Load:` block specifies.
- When a manifest is missing or invalid, return the appropriate error class and remediation hint; do not guess at studio state.
- When a source path is unreadable, record `SOURCE_UNREADABLE` per studio and continue aggregating other studios.
- Never write operational data to `Studio_Hub/` repo paths (outside `agent-context/` logic scaffolding).

## Relationship to the Studio Ecosystem

Studio Hub sits above all studios and reads from them. It does not replace studio-level coordination (that stays in each studio's `agent-context/`). The Hub is the ecosystem-level view. The Vault is the shared storage layer.
