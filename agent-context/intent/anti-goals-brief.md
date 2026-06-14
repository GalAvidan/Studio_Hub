# Anti-Goals (brief)

Five bullets. Load this at session start. See `anti-goals.md` for full rationale.

- **No writes to studio repos** — Hub is strictly read-only toward all studios during queries.
- **No push-based pipelines** — Hub is pull-only; no webhooks, event queues, or real-time triggers.
- **No studio-specific heuristics in Hub logic** — all studio-specific paths live in each studio's own `manifest.md`.
- **No speculative context loading** — load only what the current task's `Load:` block specifies; pre-loading wastes tokens and risks stale reads.
- **No silent partial failures** — every failure is classified, named, and surfaced with a deterministic remediation hint.
