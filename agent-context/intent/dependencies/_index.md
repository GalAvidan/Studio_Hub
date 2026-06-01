# Dependencies

This repo depends on the following external repos and systems.
Load this file before any cross-repo task, then load the specific dependency file for the repo you need.

| Dependency | Type | Direction | Purpose | Notes |
|---|---|---|---|---|
| [vault](vault.md) | `repo` | `reads-from` | Content store for Hub-generated cross-studio reports and snapshots | always load |
| [campaign](campaign.md) | `repo` | `reads-from` | Campaign manifest glob for query skills | optional — always loaded; no per-project trigger needed |
