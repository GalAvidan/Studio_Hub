# Glossary

## Hub
Studio Hub — the central coordination layer that reads studio plugin manifests and assembles cross-studio status, activity, and blocker reports. Hub stores logic in this repo and data in Vault.

## Studio
A repository in the ecosystem that participates in Hub coordination by declaring a plugin manifest at `agent-context/plugins/hub/manifest.md`. Current studios: AnimationStudio, ResearchStudio, Vault.

## Plugin Manifest
The file `agent-context/plugins/hub/manifest.md` inside a studio repo. It is the studio's self-declared contract with Hub: it declares where to find status, current work, blocker, and recent-activity signals, along with access bounds and security allowlists.

## ALES
Agent-Layer Execution Specification — the structured knowledge contract that governs how agent context is organized across all studio repos. See `C:/Git/ALES`.

## Pull Model
Hub reads studio data on demand (pull), rather than receiving pushed updates. Each query triggers a fresh read of declared sources.

## Vault
The shared content store at `C:/Git/Vault`. Hub runtime data (registry, reports, snapshots) lives under `Vault/Studio_Hub/knowledge/hub/`.

## Registry
The per-studio record files in `{hub_registry}/<studio>.md` and the aggregate map at `{hub_data}/studio-registry.md`. Contains last-seen status, confidence, and freshness timestamps for each registered studio.

## Confidence
A deterministic quality signal (high/medium/low) assigned per studio per query based on source readability, refresh age, and error presence. See `conventions.md` for assignment rules.

## Response Envelope
The canonical YAML front-matter block that every Hub query skill must produce. Contains `response_status`, `query_timestamp`, `studios[]`, `confidence`, `last_refresh_timestamp`, and related fields.

## Error Class
A named failure category (e.g. `MANIFEST_MISSING`, `SOURCE_UNREADABLE`, `REGISTRY_STALE`) with a deterministic remediation hint. All error classes are defined in the plan and enforced by `tasks/validate-hub-contract.task.md`.

## Canary Studio
The first studio onboarded to Hub — ResearchStudio. Canary validation must pass before rolling out to AnimationStudio and Vault.

## Phase Gate
A formal checkpoint (A, B, C, etc.) where sign-off must be recorded in `{hub_reports}/phase-gates.md` before the next phase begins.

## REGISTRY_STALE
Error class emitted when `query_timestamp - last_refresh_timestamp > 168h` (7 days) or when `last_refresh_timestamp` is missing. Forces confidence to `low`.
