# Hub Plugin Manifest Template

Fill all `<placeholder>` values. Remove this header comment before saving.

Required: all fields below `---` are required unless marked Optional.
See `Studio_Hub/agent-context/map/studio-registry-schema.md` for field definitions.
Validation checklist in `connect-studio.skill.md` Step 2.

---
```yaml
---
plugin_id: hub
manifest_version: 1.0.0
studio_id: <kebab-case-studio-id>
studio_name: <Display Name>
project_root_alias: <alias-token>

status:
  source_path: <path-or-alias/status.md>
  read_mode: file

current_work:
  source_path: <path-or-alias/current-work/>
  read_mode: directory-index

blockers:
  source_path: <path-or-alias/blockers.md>
  read_mode: file

recent_activity:
  source_path: <path-or-alias/activity/>
  read_mode: directory-index

bounds:
  max_files_per_query: 20
  max_lines_per_file: 200
  max_depth: 3

security:
  allow_paths:
    - <studio-root>/agent-context/
    - <vault-alias-path>/
  deny_paths:
    - <studio-root>/agent-context/intent/dependencies/
    - .git/
    - <studio-root>/.env
    - <studio-root>/*.key
    - <studio-root>/*.secret

# Optional fields
confidence_rules:
  status_confidence: medium

notes: <Optional: free-text notes about this studio's signal sources>

# custom_extractors:
#   - name: <extractor-name>
#     description: <when-to-use>
---
```

## Validation Checklist

Before finalizing this manifest, confirm all items:

- [ ] All required keys are present
- [ ] All declared `source_path` values resolve under the repo root or a known alias
- [ ] `bounds` values are present and positive (> 0)
- [ ] `security.allow_paths` is non-empty
- [ ] `security.deny_paths` is non-empty
- [ ] At least one of `status`, `current_work`, `blockers`, `recent_activity` source paths is readable
- [ ] `manifest_version` is `1.x.x` (major version 1 for initial installs)
- [ ] `studio_id` is kebab-case and unique in the Hub registry
