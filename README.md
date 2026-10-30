# devo-skill

An agent skill that drives a development request from idea to validated implementation using focused phases and sub-agents where available.

Skills follow the [Agent Skills](https://agentskills.io) open format and work with any compatible agent — Claude Code, Gemini CLI, VS Code Copilot, OpenCode, and others.

---

## How `devo` works

`devo` orchestrates five phases, delegating focused work when available and permitted. It can also run in a single agent, and scales down for small edits:

```
Phase 0 — Clarify    (orchestrator)   →  Session Brief
Phase 1 — Research   (sub-agent)     →  Research Report
Phase 2 — Plan       (sub-agent)     →  Implementation Plan  ← checkpoint if requested
Phase 3 — Execute    (sub-agent)     →  Execution Report
Phase 4 — Validate   (sub-agent)     →  Validation Report
```

1. **Clarify** — establishes observable acceptance criteria; asks only about material missing decisions
2. **Research** — inspects relevant code, repository instructions, reproduction steps, and baseline checks
3. **Plan** — maps requirements to changes and verification; pauses for approval when the user requests it or a consequential decision needs input
4. **Execute** — implements small coherent changes, preserves user work, and checks regressions
5. **Validate** — reviews the diff and verifies each criterion with evidence; distinguishes defects from blocked checks and allows up to three validation cycles for automatic fixes

---

## Installation

```bash
# Install globally (default: ~/.agents/skills/)
make install

# Install into the current project
make install-project

# Install to a custom path (e.g. for Claude Code)
make install DEST=~/.claude/commands

# Uninstall from global location
make uninstall

# Uninstall from a custom path
make uninstall DEST=~/.claude/commands

# Uninstall from the current project
make uninstall-project
```

### Skills directory by agent

| Agent | Default location |
|---|---|
| VS Code / GitHub Copilot | `.agents/skills/` |
| Gemini CLI | `.agents/skills/` |
| OpenCode | `.agents/skills/` |
| Claude Code | `~/.claude/commands/` |

---

## Repository structure

```
skills/
  devo/
    SKILL.md                       # Main orchestrator
    references/
      phase-research.prompt        # Research sub-agent prompt template
      phase-plan.prompt            # Planning sub-agent prompt template
      phase-execute.prompt         # Execution sub-agent prompt template
      phase-validate.prompt        # Validation sub-agent prompt template

Makefile                           # Install / uninstall / validate targets
```

Reference templates use the `.prompt` extension so they are not mistakenly discovered as standalone skills by agents that scan directories for `.md` files.

---

## Developing

Edit skill files directly in `skills/`. Re-run `make install` (or `make install DEST=...`) to propagate changes to an installed location.

```bash
# List skills in the repo
make list

# Validate SKILL.md files (requires skills-ref)
make validate
```
