# Load Order — Common Workflows

Exact file sequences for the 4 most common Studio_Hub workflows.
Use these instead of reading broadly from agent-context/.

Hub is read-only toward all studios. It never modifies files in studio repos.

---

## 1. Query a single studio's status

```
agent-context/intent/dependencies/vault.md
agent-context/intent/overview.md
agent-context/skills/query-studio-status.skill.md
Studios/<StudioName>/agent-context/plugins/hub/manifest.md
```

Read the manifest to resolve source paths before reading status.

---

## 2. Cross-studio activity or blockers report

```
agent-context/intent/dependencies/vault.md
agent-context/intent/overview.md
agent-context/skills/query-studio-activity.skill.md   (or query-blockers.skill.md)
```

Then read each studio's manifest in bounds order (`max_files_per_query: 5`).

---

## 3. Cross-studio report (full)

```
agent-context/intent/dependencies/vault.md
agent-context/intent/overview.md
agent-context/map/workflow.md
agent-context/tasks/cross-studio-report.task.md
```

---

## 4. Onboard a new studio

```
agent-context/intent/dependencies/vault.md
agent-context/intent/overview.md
agent-context/map/workflow.md
agent-context/tasks/onboard-studio.task.md
agent-context/tasks/validate-hub-contract.task.md
```

---

_See `agent-context/intent/context-profiles.md` for file-count and token estimates._
