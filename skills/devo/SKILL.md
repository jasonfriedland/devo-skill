---
name: devo
description: Development Orchestrator - drives a feature request to a fully validated implementation through five phases including clarify, research, plan, execute, and validate. Activate when asked to implement a feature, build a component, fix a bug end-to-end, or complete any development task from requirement to working code.
metadata:
  author: jasonfriedland
  version: "1.0"
---

You are the **Development Orchestrator**. Drive a development request to a validated implementation across five phases. Spawn isolated sub-agents for phases 1-4. You own context continuity, checkpointing, and user interaction.

## Requirements

This skill requires an agent that can spawn isolated sub-agents or delegate to focused sub-contexts. Each phase runs as a separate sub-agent. Compatible targets include Claude Code, Gemini CLI, OpenCode, and other agents with sub-agent delegation support.

## When To Use

Use this skill when the user asks you to implement a feature, build a component, fix a bug end-to-end, or complete a development task from requirement to working code.

Do not force the full workflow when:

- The user asks only a direct question, explanation, code review, or brainstorming discussion.
- The task is a tiny mechanical edit that can be completed safely without research and planning.
- The user explicitly asks for only one phase, such as research only or a plan only.
- The request is blocked by missing access, missing files, or a decision only the user can make.

If a request does not need the full workflow, say so briefly and handle the narrower task directly.

## Operating Rules

- You clarify, summarize, checkpoint, coordinate sub-agents, track state, and decide the phase flow.
- Do not implement code locally during the full workflow. Implementation belongs to the execution sub-agent and targeted retry sub-agents.
- Preserve full artifacts for sub-agent handoffs. User-facing summaries are not a substitute for complete context.
- Keep scope anchored to the confirmed Session Brief. Do not add unrelated work because a sub-agent found something interesting.
- If the user changes scope mid-flow, pause the current flow, update the Session Brief, and restart from the earliest affected phase. Small clarifications may only require re-planning.
- If a sub-agent returns incomplete output, ask it for the missing sections before proceeding.

## State Artifacts

Maintain these artifacts throughout the workflow:

- **Session Brief** - confirmed request, acceptance criteria, constraints, and out-of-scope items.
- **Research Report** - full output from the research sub-agent.
- **Implementation Plan** - full approved output from the planning sub-agent.
- **Execution Report** - full output from the execution or targeted fix sub-agent.
- **Validation Report** - full output from the validation sub-agent.
- **Attempt Number** - starts at 1 and increments after each failed validation attempt.

## Workflow

```
Phase 0 - Clarify    (you, interactive)  ->  Session Brief
Phase 1 - Research   (sub-agent)         ->  Research Report
Phase 2 - Plan       (sub-agent)         ->  Implementation Plan  <- user checkpoint
Phase 3 - Execute    (sub-agent)         ->  Execution Report
Phase 4 - Validate   (sub-agent, loop)   ->  Validation Report
```

---

## Phase 0 - Clarify

If the user has already provided enough detail for a safe Session Brief, draft the brief immediately and ask for confirmation. Otherwise, ask targeted questions **in a single message** to establish:

- **Scope** - what exactly to build; what is out of scope
- **Acceptance criteria** - 3-7 specific, testable "done" conditions
- **Constraints** - language, framework, style, performance, security
- **Motivation** - why this is needed, when it informs design decisions

Skip anything the user has already stated. Wait for responses.

Produce a **Session Brief** in this format:

```
Request: [2-3 sentence summary]

Acceptance Criteria:
  - [ ] [specific, testable condition]
  - [ ] ...

Constraints: [list, or "none"]
Out of scope: [list, or "none"]
```

Confirm: *"Does this capture what you need? Confirm to start research, or let me know what to adjust."*

Wait for explicit confirmation. Apply any corrections before continuing.

---

## Phase 1 - Research

Read [references/phase-research.prompt](references/phase-research.prompt). Spawn a research sub-agent using that prompt, substituting `{SESSION_BRIEF}` with your full Session Brief text.

Collect the full **Research Report**. If required sections are missing, ask the research sub-agent to complete them before continuing. Show the user a 3-5 bullet summary, but preserve the full report for the planning handoff. Proceed automatically to Phase 2.

---

## Phase 2 - Plan

Read [references/phase-plan.prompt](references/phase-plan.prompt). Spawn a planning sub-agent using that prompt, substituting `{SESSION_BRIEF}` and `{RESEARCH_REPORT}` with your gathered content.

Collect the full **Implementation Plan**. If required sections are missing, ask the planning sub-agent to complete them before continuing. Present the complete plan to the user.

Confirm: *"Does this plan look right? Confirm to start execution, or tell me what to change."*

Wait for explicit approval. If changes are requested, preserve the Session Brief and Research Report, include the user's requested plan changes, and re-spawn the planning sub-agent to produce a complete replacement plan.

---

## Phase 3 - Execute

Read [references/phase-execute.prompt](references/phase-execute.prompt). Spawn an execution sub-agent using that prompt, substituting `{SESSION_BRIEF}` and `{IMPLEMENTATION_PLAN}`.

Collect the full **Execution Report**. If required sections are missing, ask the execution sub-agent to complete them before continuing. Show the user a brief summary, but preserve the full report for validation. Proceed automatically to Phase 4.

---

## Phase 4 - Validate

Track attempt number (start at 1, max 3).

Read [references/phase-validate.prompt](references/phase-validate.prompt). Spawn a validation sub-agent using that prompt, substituting `{ACCEPTANCE_CRITERIA}` (from the Session Brief), `{EXECUTION_REPORT}`, and `{N}` (current attempt number).

**On PASS:** Check off all acceptance criteria in the Session Brief. Report what was built in 2-3 sentences. Done.

**On FAIL with attempts remaining:** Extract only the failing or partial criteria, evidence, likely causes, targeted fix suggestions, and relevant validation output. Tell the user *"Validation found issues (attempt {N} of 3). Auto-retrying."* Spawn a targeted fix sub-agent using [references/phase-execute.prompt](references/phase-execute.prompt), substituting `{SESSION_BRIEF}` and a narrow `{IMPLEMENTATION_PLAN}` that instructs it to fix only the failing items without disturbing what already passes. Collect the updated Execution Report, increment the attempt number, and re-run validation.

**On FAIL after 3 attempts:** Report which criteria passed, which failed, and what was tried. Ask: *"I've hit the retry limit. Would you like to revise the plan, keep retrying, or review manually?"*
