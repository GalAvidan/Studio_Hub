# Studio Registry Schema

This file documents the schema for Hub registry records. Runtime data lives in Vault at `{hub_registry}/<studio>.md` and the aggregate at `{hub_data}/studio-registry.md`. This file is schema documentation only — no operational data is stored here.

## Per-Studio Registry Record (`{hub_registry}/<studio>.md`)

```yaml
---
studio_id: <kebab-case-id>
studio_name: <Display Name>
manifest_version: <semver>
last_refresh_timestamp: <ISO8601 UTC>
confidence: high|medium|low
response_status: success|partial|degraded|error
data:
  status: <summary string or null>
  current_work:
    - <item>
  blockers:
    - <item>
  recent_activity:
    - <item>
error:
  code: <ERROR_CLASS or null>
  message: <remediation hint or null>
  path_attempted: <path or alias or null>
---
```

## Aggregate Studio Map (`{hub_data}/studio-registry.md`)

```yaml
---
map_version: 1
generated_at: <ISO8601 UTC>
studios:
  - studio_id: <kebab-case-id>
    studio_name: <Display Name>
    manifest_version: <semver>
    last_refresh_timestamp: <ISO8601 UTC>
    confidence: high|medium|low
    status_summary: <one-line summary or null>
---
```

## Field Definitions

| Field | Type | Required | Description |
|---|---|---|---|
| `studio_id` | string | yes | Kebab-case unique identifier matching manifest `studio_id` |
| `studio_name` | string | yes | Display name |
| `manifest_version` | semver | yes | Version from studio manifest |
| `last_refresh_timestamp` | ISO8601 UTC | yes | When Hub last successfully read this studio |
| `confidence` | enum | yes | `high`, `medium`, or `low` per deterministic rules |
| `response_status` | enum | yes | `success`, `partial`, `degraded`, or `error` |
| `data.status` | string | no | One-line studio status summary |
| `data.current_work` | list | no | Active work items |
| `data.blockers` | list | no | Active blockers |
| `data.recent_activity` | list | no | Recent activity entries |
| `error.code` | string | no | Error class if applicable |
| `error.message` | string | no | Remediation hint |
| `error.path_attempted` | string | no | Path or alias that failed |

## Confidence Assignment Rules

| Condition | Confidence |
|---|---|
| All 4 sources readable, refresh age ≤ 24h, no errors | `high` |
| ≥ 2 sources readable, refresh age ≤ 72h, no blocking policy error | `medium` |
| < 2 sources readable, refresh age > 72h, or any blocking error | `low` |

## Stale Rule

`REGISTRY_STALE` is emitted when `query_timestamp - last_refresh_timestamp > 168h` (7 days) or when `last_refresh_timestamp` is missing. Stale detection forces confidence to `low`.
