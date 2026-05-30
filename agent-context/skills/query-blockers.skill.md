# Skill: Query Blockers

## id
query-blockers

## applies_to
Answering "What are the blockers across the system?" or "What is blocking Studio X?" or requesting a blocker triage.

## Purpose
Read each registered studio's `blockers` source via its plugin manifest, aggregate blockers by impact level, assemble the canonical response envelope, and emit a prioritized blocker triage narrative.

## When to Use
- User asks about blockers, impediments, risks, or anything blocking progress.
- Incident responder asks "What failed right now and what is the safest next step?"
- Triggered by `tasks/cross-studio-report.task.md` as the blockers sub-query.

## Load

1. `agent-context/intent/dependencies/vault.md`
2. `agent-context/intent/dependencies/_index.md`
3. `agent-context/map/studio-registry-schema.md`

## Steps

### Step 1 — Resolve studio list
Use requested studio or all registered studios.

### Step 2 — For each studio
1. Validate manifest (same as `query-studio-status`). Emit errors and skip if invalid.
2. Read `blockers.source_path` respecting `read_mode` and bounds.
3. Enforce allow/deny policy. Emit `POLICY_BLOCKED` if violated.
4. Parse blockers. Each blocker should have: description, impact level (critical/high/medium/low), and optionally owner and last-updated.
   - If the source does not use structured format, treat the full text as a single `medium`-impact blocker.
5. Emit `SOURCE_UNREADABLE` if path is unreadable.
6. Compute confidence and `last_refresh_timestamp`. Check stale rule.
7. Write updated record to `{hub_registry}/<studio-id>.md`.

### Step 3 — Determine response_status
Same rules as `query-studio-status`.

### Step 4 — Assemble canonical envelope

```yaml
---
response_status: <value>
query_timestamp: <ISO8601 UTC>
request_id: query-blockers-<YYYYMMDD-HHMMSS>
studios:
  - studio_id: <id>
    studio_name: <name>
    data:
      status: null
      current_work: []
      blockers:
        - <item>
      recent_activity: []
    confidence: <high|medium|low>
    last_refresh_timestamp: <ISO8601 UTC or null>
    error:
      code: <ERROR_CLASS or null>
      message: <remediation hint or null>
      path_attempted: <path or alias or null>
aggregated_summary: <one paragraph>
recommendation: <next action or null>
---
```

### Step 5 — Emit narrative in mandatory section order
1. `# Hub Query Result`
2. `## Overall Status`
3. `## Studio Summaries` — per studio: confidence, freshness, blocker count
4. `## Priority Blockers` — sorted by impact: critical first, then high, medium, low. Format:
   ```
   ### Critical
   - [StudioName] <blocker description>
   ### High
   - ...
   ```
   If no blockers in a category, omit that sub-heading.
5. `## Errors and Remediation`
6. `## Recommended Next Action` — prioritize unblocking the highest-impact blocker or remediate the most severe error first

### Step 6 — Update aggregate registry
Write updated studio entries to `{hub_data}/studio-registry.md`.

## Constraints
- Never read paths outside `security.allow_paths`.
- `security.deny_paths` always wins.
- Never fabricate blocker items.
- When blocker impact level cannot be determined from source format, assign `medium`.
- Redact any sensitive tokens or credentials found in blocker descriptions.

## Verification
- `blockers` list populated per studio where source was readable.
- Priority Blockers section sorted by impact level.
- Error classes and remediation hints present for each failing studio.

## Ask When
- Blocker source contains what appears to be sensitive credentials — stop, redact, and report the incident before continuing.
- Impact levels are entirely absent from source format — surface ambiguity and apply `medium` default; note in narrative.
