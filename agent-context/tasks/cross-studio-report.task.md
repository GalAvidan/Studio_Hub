# Task: Cross-Studio Report

## id
cross-studio-report

## Goal
Execute a full cross-studio status, activity, and blocker report for all registered studios and write the consolidated output to Vault.

## Load
1. `agent-context/intent/dependencies/vault.md`
2. `agent-context/intent/dependencies/_index.md`
3. `agent-context/map/studio-registry-schema.md`
4. `agent-context/skills/query-studio-status.skill.md`
5. `agent-context/skills/query-studio-activity.skill.md`
6. `agent-context/skills/query-blockers.skill.md`

## Steps

1. Set `report_timestamp` = current time (ISO8601 UTC).
2. Execute `query-studio-status` for all registered studios. Capture envelope and narrative.
3. Execute `query-studio-activity` for all registered studios. Capture envelope and narrative.
4. Execute `query-blockers` for all registered studios. Capture envelope and narrative.
5. Merge all three envelopes:
   - `response_status` = most severe of the three (error > degraded > partial > success).
   - Per-studio `data`: merge status/current_work/blockers/recent_activity from respective envelopes.
   - Per-studio `confidence` = lowest of the three per-studio confidence values.
   - Per-studio `error`: include all distinct error codes from all three queries.
6. Assemble consolidated narrative with all six mandatory sections.
7. Write report to `{hub_reports}/cross-studio-report-<YYYYMMDD>.md`.
8. Update `{hub_data}/studio-registry.md` with merged per-studio records.

## Expected Output

- `{hub_reports}/cross-studio-report-<YYYYMMDD>.md` — full report with YAML envelope and narrative
- `{hub_data}/studio-registry.md` — updated aggregate registry
- `{hub_registry}/<studio-id>.md` — updated per-studio records (written by individual skills)

## Stop Conditions
- `vault.md` aliases cannot be resolved — stop, report `ALIAS_UNRESOLVED`, and provide remediation.
- All three query skills fail for all studios — emit `degraded` envelope and stop before writing reports.
- Output path write fails — report the failure; do not silently omit the report.
