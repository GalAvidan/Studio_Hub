# Task: Onboard Studio

## id
onboard-studio

## Goal
Orchestrate the full studio onboarding flow: ensure ALES is complete on the studio, create the Hub plugin manifest, register the studio with Hub, and validate connectivity.

## Load
1. `agent-context/intent/dependencies/vault.md`
2. `agent-context/intent/dependencies/_index.md`
3. `agent-context/skills/integrate-ales.skill.md`
4. `agent-context/skills/connect-studio.skill.md`
5. `agent-context/map/workflow.md`

## Steps

1. **Pre-check**: Confirm `validate-hub-contract.task.md` has been run recently (< 7 days). If not, run it first. Hub contract must pass before onboarding any studio.
2. **Identify studio**: Confirm `studio_id`, `studio_name`, and repo root path.
3. **Integrate ALES** (`integrate-ales` skill):
   - Apply/update ALES on the target studio repo.
   - Confirm all canonical ALES files exist.
   - Confirm `agent-context/plugins/` folder is ready.
4. **Connect studio** (`connect-studio` skill):
   - Create plugin manifest in studio repo.
   - Run manifest validation checklist (all 5 checks must pass).
   - Create Hub registry entry in `{hub_registry}/<studio-id>.md`.
   - Update aggregate map in `{hub_data}/studio-registry.md`.
5. **Canary validation** (ResearchStudio only, or first studio of each new onboarding batch):
   - Execute `query-studio-status` for the newly connected studio.
   - Assert response envelope is valid and confidence ≥ `medium`.
   - Record canary result in `{hub_reports}/query-dry-runs.md`.
   - **If canary fails: STOP. Do not onboard additional studios until canary passes.**
6. **Post-onboarding validation**:
   - Run `validate-hub-contract.task.md` for all currently registered studios.
   - Confirm all existing studios still return valid envelopes after the new studio was added.
7. **Record evidence**:
   - Update `{hub_reports}/phase-gates.md` with onboarding result.

## Expected Output
- `<studio-repo>/agent-context/plugins/hub/manifest.md` — validated and written
- `{hub_registry}/<studio-id>.md` — created with initial confidence `low` and current timestamp
- `{hub_data}/studio-registry.md` — updated with new studio entry
- `{hub_reports}/query-dry-runs.md` — canary result recorded
- `{hub_reports}/phase-gates.md` — gate progress updated

## Stop Conditions
- Hub contract validation (Step 1) fails — fix contract issues before onboarding.
- ALES integration (Step 3) leaves structural gaps — do not proceed until all gaps are resolved.
- Manifest validation checklist fails (Step 4) — fix manifest before creating registry entry.
- Canary fails (Step 5) — halt all further onboarding; record failure in reports.
- `vault.md` aliases cannot be resolved — stop, report `ALIAS_UNRESOLVED`.

## Rollout Order
The active rollout sequence is recorded in `Vault/Studio_Hub/`. Consult that file before onboarding any new studio.
