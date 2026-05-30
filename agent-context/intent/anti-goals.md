# Anti-Goals

## No visual dashboard or UI
> Rationale: The initial version is ALES markdown only. A coded dashboard/UI is a future concern tracked in AgenticAI-Blueprint.

## No push-based status pipelines or event triggers
> Rationale: Hub uses a PULL model — it reads studios on demand. Push infrastructure (webhooks, event queues) is out of scope for the markdown layer.

## No hard-coded per-studio heuristics in Hub logic
> Rationale: Hub must never embed studio-specific knowledge outside of the plugin manifest contract. All studio-specific paths and signals must be declared in each studio's own `agent-context/plugins/hub/manifest.md`.

## No coded agents, MCP servers, or RAG pipelines
> Rationale: This is a markdown-only coordination layer. Coded automation is a future phase tracked separately.

## No direct writes to studio repos
> Rationale: Hub is read-only toward all studios. It never modifies files in studio repos during query execution.

## No operational data stored in Studio_Hub repo
> Rationale: Runtime registry records, reports, and snapshots belong in Vault under `{hub_data}`. Storing them in this repo would blur the logic/data boundary and complicate Vault migration patterns.

## No silent partial failures
> Rationale: Every failure must be classified, named, and surfaced in the query response envelope with a deterministic remediation hint.

## No speculative context loading
> Rationale: Agents load only what the current task's `Load:` block specifies. Pre-loading unrelated files wastes context and risks stale reads.
