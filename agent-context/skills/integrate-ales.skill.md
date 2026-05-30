# Skill: Integrate ALES

## id
integrate-ales

## applies_to
Applying or updating the ALES agent-context layer on a studio repo as part of Hub onboarding.

## Purpose
Ensure the target studio has a complete, canonical ALES agent-context structure before its plugin manifest is created. This is the first step of the `onboard-studio` orchestration.

## When to Use
- A studio has no `agent-context/` or an incomplete one.
- Running `tasks/onboard-studio.task.md` — this skill is invoked in Step 1.
- After `ales-audit` identifies structural gaps in a studio repo.

## Load
1. `C:/Git/ALES/skills/ales-apply/SKILL.md`
2. `C:/Git/ALES/skills/ales-apply/ales-update.skill.md`
3. `C:/Git/ALES/skills/ales-apply/ales-audit.skill.md`
4. `C:/Git/ALES/skills/ales-apply/reference/folder-structure.md`

## Steps

### Step 1 — Determine ALES state
1. Check if `<studio-repo>/agent-context/` exists.
2. If absent → route to `ales-bootstrap` for a greenfield install.
3. If present → route to `ales-update` for an additive update.

### Step 2 — Run ales-update (or ales-bootstrap)
1. Follow the steps in `ales-update.skill.md` (or `ales-bootstrap.skill.md`).
2. Key constraint for onboarding: use **additive update semantics only** — never overwrite existing intent files.
3. Ensure these canonical files exist after the update:
   - `intent/overview.md`
   - `intent/conventions.md`
   - `intent/anti-goals.md`
   - `intent/glossary.md`
   - `intent/dependencies/_index.md`
   - `intent/dependencies/vault.md` (if studio uses Vault)
   - `map/folders.md`
   - `map/workflow.md`
   - `tasks/refresh-map.task.md`

### Step 3 — Verify plugin folder readiness
1. Check if `<studio-repo>/agent-context/plugins/` exists.
2. If absent, create `agent-context/plugins/` folder (empty, ready for manifest installation).
3. Do not create the `hub/` subfolder or manifest — that is done by `connect-studio`.

### Step 4 — Run ales-audit
Run `ales-audit` on the studio and confirm:
- No MISSING items in structural scan.
- Hub readiness check rows for `intent/overview.md`, `intent/dependencies/_index.md`, `map/folders.md`, `map/workflow.md` all show ✓.
- Plugin manifest check shows ABSENT (expected at this stage — will be created in `connect-studio`).

### Step 5 — Report
Record findings:
- Which files were created or updated.
- Audit result summary (ALIGNED / NEEDS UPDATE).
- Confirm plugin folder ready for manifest installation.

## Constraints
- Never overwrite human-authored intent files.
- Never install the hub plugin manifest — that is `connect-studio`'s responsibility.
- Always run audit after update and surface any gaps before proceeding.

## Verification
- All canonical ALES files exist in the studio.
- `agent-context/plugins/` folder exists.
- ALES audit shows no structural gaps.

## Ask When
- The studio has an existing `agent-context/` with content that appears contradicted by the current project — surface the conflict and ask before proceeding.
- The studio's vault.md path differs from the ecosystem standard — surface for confirmation.
