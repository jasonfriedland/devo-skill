# devo-skill

A set of agent skills that drive a development request from idea to validated implementation using isolated sub-agents for each phase.

Skills follow the [Agent Skills](https://agentskills.io) open format and work with any compatible agent — Claude Code, Gemini CLI, VS Code Copilot, OpenCode, and others.

---

## Skills

| Skill | Role | Use standalone when... |
|---|---|---|
| `devo` | Full workflow orchestrator | Building or fixing something end-to-end |
| `devo-research` | Codebase research | You need context before planning |
| `devo-plan` | Implementation planning | You have a task and want a concrete plan |
| `devo-execute` | Code implementation | You have a plan and are ready to execute |
| `devo-validate` | Test & validate | You want to verify criteria after implementation |

---

## How `devo` works

`devo` orchestrates five phases, spawning an isolated sub-agent for each:

```
Phase 0 — Clarify    (interactive)   →  Session Brief
Phase 1 — Research   (sub-agent)     →  Research Report
Phase 2 — Plan       (sub-agent)     →  Implementation Plan  ← user checkpoint
Phase 3 — Execute    (sub-agent)     →  Execution Report
Phase 4 — Validate   (sub-agent)     →  Validation Report
```

1. **Clarify** — asks targeted questions to produce a Session Brief with acceptance criteria
2. **Research** — surveys the codebase; produces a Research Report summarising relevant files, conventions, and risks
3. **Plan** — turns the brief and research into a task-by-task Implementation Plan; requires explicit user approval before proceeding
4. **Execute** — implements the plan; produces an Execution Report noting deviations
5. **Validate** — runs tests and evaluates each acceptance criterion; retries up to 3 times on failure before escalating

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
  devo-research/
    SKILL.md                       # Standalone research skill
  devo-plan/
    SKILL.md                       # Standalone planning skill
  devo-execute/
    SKILL.md                       # Standalone execution skill
  devo-validate/
    SKILL.md                       # Standalone validation skill

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
