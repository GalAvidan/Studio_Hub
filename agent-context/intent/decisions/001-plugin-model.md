# Decision: Plugin model over hard-coded studio adapters

## Status
Accepted

## Context
Hub needs to query multiple studios for status, current work, and blockers. The naive approach is to hard-code per-studio heuristics (file paths, formats) directly in Hub skills. This creates tight coupling: every new studio requires modifying Hub logic files.

## Decision
Use a decoupled plugin model. Each studio declares a `agent-context/plugins/hub/manifest.md` that specifies its own signal sources, bounds, and security policy. Hub logic reads only this manifest and never embeds studio-specific knowledge.

## Consequences
- Adding a new studio requires only creating a manifest in that studio's repo — no Hub code changes.
- Manifest versioning governs compatibility. Breaking changes require a major version bump.
- Hub behavior is predictable and auditable: all per-studio configuration is in one file per studio.
- Studios that do not provide a manifest receive `MANIFEST_MISSING` error with a remediation hint.
