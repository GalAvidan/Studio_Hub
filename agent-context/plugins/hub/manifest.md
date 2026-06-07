---
plugin_id: hub
manifest_version: 1.0.0
studio_id: studio-hub
studio_name: Studio_Hub
project_root_alias: "{hub_data}"

status:
  source_path: Studio_Hub/README.md
  read_mode: file

current_work:
  source_path: Vault/Studio_Hub/context.md
  read_mode: file
  empty_note: "No active coordination work recorded. Check Vault/Studio_Hub/ for context."

blockers:
  source_path: Studio_Hub/README.md
  read_mode: file

recent_activity:
  source_path: Vault/Studio_Hub/
  read_mode: directory-index

bounds:
  max_files_per_query: 5
  max_lines_per_file: 100
  max_depth: 1

security:
  allow_paths:
    - Studio_Hub/README.md
    - Studio_Hub/agent-context/intent/overview.md
    - Studio_Hub/agent-context/map/
    - Vault/Studio_Hub/
  deny_paths:
    - Studio_Hub/agent-context/intent/dependencies/
    - Vault/Studio_Hub/knowledge/
    - .git\

confidence_rules:
  status_confidence: medium

notes: >
  Studio_Hub is the coordination layer, not a content studio. It has no projects of its own.
  Status and blockers are read from README.md (high-level purpose) and Vault/Studio_Hub/context.md
  (current phase). current_work reflects active coordination tasks tracked in Vault.
  Use confidence medium: Hub's "status" is its task log and cross-studio reports, not a project list.
---
