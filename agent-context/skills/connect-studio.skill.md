# Skill: Connect Studio

## id
connect-studio

## applies_to
Creating a studio's Hub plugin manifest and creating the corresponding Hub registry entry in Vault. This is the second step of the `onboard-studio` orchestration.

## Purpose
Establish the bidirectional contract between a studio and Hub: the studio self-declares its signal sources (plugin manifest), and Hub records the studio in its registry.

## When to Use
- Running `tasks/onboard-studio.task.md` — this skill is invoked in Step 2.
- A studio already has ALES (integrate-ales has passed) and is ready to join Hub.
- Updating an existing plugin manifest after a studio's source paths have changed.

## Load
1. `agent-context/intent/dependencies/vault.md`
2. `agent-context/intent/dependencies/_index.md`
3. `agent-context/templates/hub-plugin-manifest.template.md`
4. `agent-context/templates/studio-registration.template.md`
5. `<studio-repo>/agent-context/intent/overview.md`

## Steps

### Step 1 — Gather studio information
Read or ask for:
- `studio_id` (kebab-case, e.g. `research-studio`)
- `studio_name` (display name, e.g. `ResearchStudio`)
- Studio repo root path (e.g. `C:/Git/ResearchStudio`)
- `project_root_alias` (from studio's vault.md, e.g. `{projects}`)
- Status, current_work, blockers, recent_activity source paths (from studio's existing structure)
- Security allow_paths and deny_paths

### Step 2 — Create plugin manifest in studio repo
1. Create folder `<studio-repo>/agent-context/plugins/hub/` if absent.
2. Fill `templates/hub-plugin-manifest.template.md` with studio-specific values.
3. Write to `<studio-repo>/agent-context/plugins/hub/manifest.md`.
4. Run manifest validation checklist:
   - All required keys present?
   - All source_paths resolve?
   - bounds values positive?
   - allow_paths and deny_paths non-empty?
   - At least one source readable?
5. If any check fails → fix the manifest before proceeding.

### Step 3 — Create Hub registry entry
1. Fill `templates/studio-registration.template.md` with studio info.
2. Set `last_refresh_timestamp` = current time.
3. Set `confidence` = `low` (initial; will rise after first successful query).
4. Write to `{hub_registry}/<studio-id>.md`.

### Step 4 — Update aggregate registry
1. Add or update studio entry in `{hub_data}/studio-registry.md`.
2. Set `generated_at` = current time.

### Step 5 — Canary check (ResearchStudio only)
If this is the canary studio:
1. Execute `query-studio-status` for this studio.
2. Assert the response envelope is valid (not `error`).
3. Record canary result in `{hub_reports}/query-dry-runs.md`.
4. If canary fails → halt; do not proceed to other studio onboardings until canary passes.

### Step 6 — Report
Record:
- Manifest path created.
- Registry entry path created.
- Validation checklist result.
- Canary result (if applicable).

## Constraints
- Never overwrite an existing manifest without explicit approval.
- Never read studio source paths that are outside the manifest's `security.allow_paths`.
- All registry writes must use `{hub_registry}` and `{hub_data}` aliases — never bare paths.
- Canary must pass before connecting AnimationStudio or Vault.

## Verification
- `<studio-repo>/agent-context/plugins/hub/manifest.md` exists and passes validation checklist.
- `{hub_registry}/<studio-id>.md` exists.
- `{hub_data}/studio-registry.md` contains the new studio entry.
- No operational data written to Studio_Hub repo paths.

## Ask When
- Source paths for a studio cannot be inferred from its existing structure — ask before creating manifest.
- An existing manifest already exists — confirm whether to update or skip.
