# Task: Validate Hub Contract

## id
validate-hub-contract

## Goal
Run all four required contract validation scenarios against Hub query skills and produce evidence artifacts confirming the output schema contract is met.

## Load
1. `agent-context/intent/dependencies/vault.md`
2. `agent-context/intent/dependencies/_index.md`
3. `agent-context/skills/query-studio-status.skill.md`
4. `agent-context/skills/query-studio-activity.skill.md`
5. `agent-context/skills/query-blockers.skill.md`
6. `agent-context/map/studio-registry-schema.md`

## Steps

### Scenario 1 — All-success envelope
1. Configure test with all studios returning valid manifests and readable sources.
2. Execute `query-studio-status` for all studios.
3. Assert:
   - `response_status: success`
   - All studios have `confidence: high` or `medium`
   - All studios have non-null `last_refresh_timestamp`
   - All required envelope keys present
   - Narrative sections in correct order (Hub Query Result → Overall Status → Studio Summaries → Priority Blockers → Errors and Remediation → Recommended Next Action)
   - No error entries in `studios[].error.code`
4. Record PASS/FAIL with details.

### Scenario 2 — Partial-success with per-studio error
1. Configure test with one studio having a missing manifest (simulate `MANIFEST_MISSING`), others valid.
2. Execute `query-studio-status`.
3. Assert:
   - `response_status: partial`
   - Failing studio has `error.code: MANIFEST_MISSING`
   - Failing studio has `confidence: low`
   - Failing studio error has non-null `error.message` containing remediation hint
   - Passing studios have valid data
   - Narrative `## Errors and Remediation` section present and correct
4. Record PASS/FAIL with details.

### Scenario 3 — Degraded all-fail
1. Configure test with all studios having unreadable manifests (simulate all `MANIFEST_MISSING`).
2. Execute `query-studio-status`.
3. Assert:
   - `response_status: degraded`
   - All studios have `error.code` set
   - All studios have `confidence: low`
   - `aggregated_summary` reflects all-fail state
   - Narrative present with all six mandatory sections
4. Record PASS/FAIL with details.

### Scenario 4 — Stale registry path emitting REGISTRY_STALE
1. Configure test with a studio having `last_refresh_timestamp` > 168h ago (or missing).
2. Execute `query-studio-status`.
3. Assert:
   - `REGISTRY_STALE` error emitted for that studio
   - Studio `confidence` forced to `low`
   - Narrative notes stale condition and recommends running `refresh-map.task.md`
4. Record PASS/FAIL with details.

### Final assertions (all scenarios)
- Required envelope keys present: `response_status`, `query_timestamp`, `studios[]`, `confidence`, `last_refresh_timestamp` (per requirements).
- Confidence assignment follows deterministic rules from `studio-registry-schema.md`.
- Narrative section ordering compliant in all four scenarios.
- Per-studio error/remediation hint consistency: every `error.code` has a non-null `error.message`.

## Expected Output
- `{hub_reports}/contract-validation.md` — full test run results with scenario-by-scenario PASS/FAIL

## Output format for `{hub_reports}/contract-validation.md`

```markdown
# Hub Contract Validation Report

Run date: <ISO8601 UTC>
Runner: <agent or human>

## Scenario 1 — All-success
Result: PASS | FAIL
Details: <assertions and outcomes>

## Scenario 2 — Partial-success
Result: PASS | FAIL
Details: <assertions and outcomes>

## Scenario 3 — Degraded all-fail
Result: PASS | FAIL
Details: <assertions and outcomes>

## Scenario 4 — Stale registry
Result: PASS | FAIL
Details: <assertions and outcomes>

## Summary
Overall: PASS | FAIL
Residual risks: <list or "— none —">
```

## Trigger Schedule
- Run before every phase gate sign-off.
- Run on every studio onboarding event.
- Run on weekly cadence for all registered studios.

## Stop Conditions
- `vault.md` aliases cannot be resolved — stop, report `ALIAS_UNRESOLVED`.
- Test scaffolding itself fails — report tool failure; do not produce a partial validation report.
