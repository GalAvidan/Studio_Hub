# Task: Refresh Map

## id
refresh-map

## Goal
Re-derive all `map/` files in Studio_Hub from current project source and keep them current. Also perform a bulk registry refresh for all registered studios.

## Load
1. `agent-context/intent/dependencies/vault.md`
2. `agent-context/intent/overview.md`
3. `agent-context/map/folders.md`

## Steps

1. Scan the Studio_Hub repo root for added, renamed, or deleted top-level files and folders.
2. Update `agent-context/map/folders.md` entries to reflect current state. Add new entries; mark removed entries as deprecated.
3. Check `agent-context/map/workflow.md` — if the lifecycle, skill, or task set has changed, update routing table.
4. Check `agent-context/map/studio-registry-schema.md` — update if schema fields have changed.
5. For each registered studio in `{hub_data}/studio-registry.md`:
   a. Re-read studio manifest at `<studio-repo>/agent-context/plugins/hub/manifest.md`.
   b. If manifest missing or invalid, record error in `{hub_registry}/<studio-id>.md`.
   c. If valid, update `last_refresh_timestamp` in `{hub_registry}/<studio-id>.md`.
6. Update `{hub_data}/studio-registry.md` with all refreshed studio entries.
7. Report which map files were changed and which studios were refreshed/errored.

## Expected Output
- All `agent-context/map/*.md` files accurately describe the current project structure.
- `{hub_data}/studio-registry.md` updated with current refresh timestamps.
- `{hub_registry}/<studio-id>.md` updated per studio.

## Stop Conditions
- A folder's purpose is ambiguous — stop and ask before updating map.
- A task file referenced in `workflow.md` no longer exists — stop and report.
- `vault.md` aliases cannot be resolved — stop and report `ALIAS_UNRESOLVED`.
