# Skill: Query Studio Activity

## id
query-studio-activity

## applies_to
Answering the question "What is each studio currently working on?" or "What is Studio X working on?"

## Purpose
Read each registered studio's `current_work` and `recent_activity` sources via its plugin manifest, assemble the canonical response envelope, and emit a structured activity narrative.

## When to Use
- User asks "What are the studios working on?" or "What is in progress?"
- User asks for recent activity or work-in-progress items across the ecosystem.
- Triggered by `tasks/cross-studio-report.task.md` as the activity sub-query.

## Load

1. `agent-context/intent/dependencies/vault.md`
2. `agent-context/intent/dependencies/_index.md`
3. `agent-context/map/studio-registry-schema.md`

## Steps

### Step 1 — Resolve studio list
Same as `query-studio-status`: use requested studio or all registered studios.

### Step 2 — For each studio
1. Locate and validate `agent-context/plugins/hub/manifest.md` (same validation as `query-studio-status`).
   - Emit `MANIFEST_MISSING` or `MANIFEST_INVALID` and skip if validation fails.
2. Read `current_work.source_path` respecting `read_mode` and `bounds.max_files_per_query`/`max_lines_per_file`/`max_depth`.
   - `file`: read the single declared file.
   - `directory-index`: list files in the directory up to `max_files_per_query` depth `max_depth`; read each up to `max_lines_per_file`.
3. Read `recent_activity.source_path` with same policy.
4. Check allow/deny policy for both paths. Emit `POLICY_BLOCKED` if violated.
5. Emit `SOURCE_UNREADABLE` for any unreadable path; continue with available data.
6. Compute confidence and `last_refresh_timestamp` per the same deterministic rules.
7. Check stale rule; emit `REGISTRY_STALE` and force `low` confidence if triggered.
8. Write updated record to `{hub_registry}/<studio-id>.md`.

### Step 3 — Determine response_status
Same rules as `query-studio-status`.

### Step 4 — Assemble canonical envelope

```yaml
---
response_status: <value>
query_timestamp: <ISO8601 UTC>
request_id: query-studio-activity-<YYYYMMDD-HHMMSS>
studios:
  - studio_id: <id>
    studio_name: <name>
    data:
      status: null
      current_work:
        - <item>
      blockers: []
      recent_activity:
        - <item>
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
3. `## Studio Summaries` — focus on `current_work` and `recent_activity` per studio
4. `## Priority Blockers` — note "Full blocker triage: run query-blockers skill."
5. `## Errors and Remediation`
6. `## Recommended Next Action`

### Step 6 — Update aggregate registry
Write updated studio entries to `{hub_data}/studio-registry.md`.

## Constraints
- Never read paths outside `security.allow_paths`.
- `security.deny_paths` always wins.
- Never fabricate activity items. `null` or empty list if unreadable.
- Respect `bounds.max_files_per_query` and `max_depth` strictly.

## Verification
- Envelope contains all required keys.
- `current_work` and `recent_activity` are lists (may be empty, not null).
- Narrative sections appear in required order.

## Ask When
- A `directory-index` source has ambiguous root path — stop and report `SOURCE_UNREADABLE` with path details.
