# Skill: Query Studio Status

## id
query-studio-status

## applies_to
Answering the question "What is the status of all studios?" or "What is the status of <studio>?"

## Purpose
Read each registered studio's plugin manifest, fetch its declared status source, assemble a canonical response envelope, and emit a structured narrative summary.

## When to Use
- User asks for system-wide or per-studio status.
- User asks "Is the system healthy?" or "What is Studio X working on?"
- Triggered by `tasks/cross-studio-report.task.md` as the status sub-query.

## Load

1. `agent-context/intent/dependencies/vault.md`
2. `agent-context/intent/dependencies/_index.md`
3. `agent-context/map/studio-registry-schema.md`
4. `agent-context/templates/hub-plugin-manifest.template.md` (for manifest validation reference)

## Steps

### Step 0 — Verify alias resolution
After loading `vault.md`, confirm `{hub_data}` and `{hub_registry}` resolve to reachable paths.
If either alias is unresolvable:
- Set `response_status: error`; emit envelope with `error.code: ALIAS_UNRESOLVED`.
- `error.message`: `"Reload agent-context/intent/dependencies/vault.md, confirm alias mapping, and rerun query."`
- Halt — do not proceed to per-studio reads.

### Step 1 — Resolve studio list
If a specific studio was requested, use only that studio. Otherwise use all registered studios from `{hub_data}/studio-registry.md`. If the registry file is missing or unreadable, emit `REGISTRY_STALE` and set `response_status: error` — do not enumerate or guess studio names.

### Step 2 — For each studio
1. Locate `<studio-repo>/agent-context/plugins/hub/manifest.md`.
2. If missing → record error `MANIFEST_MISSING` for this studio; skip to next studio.
3. Parse manifest YAML. Run manifest validation checklist:
   - All required keys present?
   - `manifest_version` major version compatible (1.x)?
   - All declared `source_path` values resolve?
   - `bounds` values present and positive?
   - `security.allow_paths` and `security.deny_paths` non-empty?
   - If any check fails → record error `MANIFEST_INVALID` with failed check details; skip to next studio.
4. Verify `status.source_path` is under `security.allow_paths` and not under `security.deny_paths`.
   - If policy violation → record error `POLICY_BLOCKED`; skip source.
5. Read `status.source_path` respecting `bounds.max_lines_per_file`.
   - If unreadable → record error `SOURCE_UNREADABLE`; confidence degrades.
6. Compute confidence:
   - `high`: all 4 sources readable, refresh age ≤ 24h, no errors.
   - `medium`: ≥ 2 sources readable, refresh age ≤ 72h, no blocking policy error.
   - `low`: < 2 sources readable, refresh age > 72h, or any `SOURCE_UNREADABLE`/`ALIAS_UNRESOLVED`/`POLICY_BLOCKED` error.
7. Compute `last_refresh_timestamp` = current query execution time (ISO8601 UTC).
8. Check stale rule: if previous `last_refresh_timestamp` in registry is > 168h old or missing → emit `REGISTRY_STALE`; force confidence to `low`.
9. Write updated record to `{hub_registry}/<studio-id>.md`.

### Step 3 — Determine response_status
- `success`: all studios produced valid data, no errors.
- `partial`: at least one studio succeeded, at least one had errors.
- `degraded`: all studios failed.
- `error`: execution-level failure (e.g. vault.md unresolvable).

### Step 4 — Assemble canonical envelope
Emit YAML front-matter block exactly as specified:

```yaml
---
response_status: <value>
query_timestamp: <ISO8601 UTC>
request_id: query-studio-status-<YYYYMMDD-HHMMSS>
studios:
  - studio_id: <id>
    studio_name: <name>
    data:
      status: <summary or null>
      current_work: []
      blockers: []
      recent_activity: []
    confidence: <high|medium|low>
    last_refresh_timestamp: <ISO8601 UTC or null>
    error:
      code: <ERROR_CLASS or null>
      message: <remediation hint or null>
      path_attempted: <path or alias or null>
aggregated_summary: <one paragraph summary>
recommendation: <next action or null>
---
```

### Step 5 — Emit narrative in mandatory section order
Emit exactly these sections in this order:

1. `# Hub Query Result`
2. `## Overall Status` — maps to `response_status` and `aggregated_summary`
3. `## Studio Summaries` — one subsection per studio with status/confidence/freshness
4. `## Priority Blockers` — cross-studio blocker rollup (critical, high, medium, low). If status-only query, note "Full blocker triage: run query-blockers skill."
5. `## Errors and Remediation` — per-studio error class + remediation hint (omit section if no errors)
6. `## Recommended Next Action` — maps to `recommendation`

### Step 6 — Update aggregate registry
Write updated studio entries to `{hub_data}/studio-registry.md`.

## Constraints
- Never read paths outside `security.allow_paths` for any studio.
- `security.deny_paths` always wins over `security.allow_paths`.
- Never fabricate status values. If source is unreadable, the status field must be `null`.
- Narrative must not contradict the envelope.
- All `{hub_*}` output paths must be resolved via vault.md aliases.

## Verification
- If `{hub_data}` or `{hub_registry}` alias is unresolvable, `response_status: error` and `error.code: ALIAS_UNRESOLVED` are emitted and execution halts before the per-studio loop.
- Envelope contains all required keys.
- `response_status` is one of the four valid values.
- Each studio entry has `confidence` and `last_refresh_timestamp`.
- Narrative sections appear in the required order.
- No operational data written to `Studio_Hub/` repo paths.

## Ask When
- A studio is registered but its repo root path cannot be resolved — stop and report the studio as `MANIFEST_MISSING` with path details.
- Two studios have conflicting manifest versions outside the compatible major range — surface the conflict before reading.
