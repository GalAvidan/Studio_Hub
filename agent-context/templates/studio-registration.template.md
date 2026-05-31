# Studio Registration Template

Fill all `<placeholder>` values. This file is written to `{hub_registry}/<studio-id>.md` by `connect-studio.skill.md`.

---
```yaml
---
studio_id: <kebab-case-studio-id>
studio_name: <Display Name>
manifest_version: 1.0.0
last_refresh_timestamp: <ISO8601 UTC — set to current time on creation>
confidence: low
response_status: partial

data:
  status: null
  current_work: []
  blockers: []
  recent_activity: []

error:
  code: null
  message: null
  path_attempted: null
---
```

## Notes

- `confidence` starts at `low` on creation. It will be updated after the first successful query.
- `response_status` starts at `partial` on creation. Updated after first successful query.
- `last_refresh_timestamp` must be set to the time this record was created.
- All `data` fields are `null` or empty on creation; populated after first `query-studio-status` execution.
- File path: `{hub_registry}/<studio-id>.md`
- Referenced in aggregate: `{hub_data}/studio-registry.md`
