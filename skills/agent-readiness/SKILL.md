---
name: agent-readiness
description: Assess and improve a repository's readiness for AI-assisted development
---

Assess the current repository's readiness for AI-assisted development, then offer to improve it step by step. $ARGUMENTS

Whenever you need to ask the user a question, always use the AskUserQuestion tool — never ask as plain text.

When a step involves a discussion with the user, tell them they can say "done" or "skip" to move on to the next step.

## Step 1. Assess (before)

Before making any changes, present the following explanation to the user:

> This skill helps you build a layered documentation system for AI-assisted development. Each file has a distinct role:
>
> - **`docs/*-guidelines.md`** — Detailed, domain-specific playbooks (security, testing, database, etc.) with concrete rules agents follow
> - **`AGENTS.md`** — The onboarding doc for any AI agent: cross-cutting conventions + an index pointing to the guideline files
> - **`CLAUDE.md`** — A thin, Claude Code-specific layer that imports AGENTS.md and adds Claude-only behavior (build commands, etc.)
> - **`.coderabbit.yaml`** — Points CodeRabbit (AI code reviewer) to the guideline files so it enforces your conventions during PR reviews
> - **`README.md`** — The front door: high-level project context for humans and agents alike
> - **`CONTRIBUTING.md`** — Contribution conventions for both humans and agents
> - **`docs/ARCHITECTURE.md`** — Institutional knowledge about the system's design and key architectural decisions
>
> We'll check what's already in place, then walk through each file step by step.

Check every requirement listed below and record its state as ✅ or ❌. Present the results in a table. This is a read-only step — do not modify any files.

### Requirements

Check them in this order:

| # | Requirement | How to check |
|---|-------------|--------------|
| 1 | Domain-specific guideline files exist (`docs/*-guidelines.md`) | Glob for `docs/*-guidelines.md` — ✅ if at least one file exists |
| 2 | AGENTS.md exists with AI-specific guidance, repo conventions, and docs index | Check for `AGENTS.md` at the repo root |
| 3 | CLAUDE.md imports AGENTS.md | Check for `CLAUDE.md` at the repo root containing `@AGENTS.md` |
| 4 | CodeRabbit configured with guideline files (`.coderabbit.yaml`) | Check for `.coderabbit.yaml` at the repo root containing a `knowledge_base.code_guidelines.filePatterns` entry pointing to `docs/*-guidelines.md` |
| 5 | README.md with repo-level foundational context | Check for `README.md` at the repo root |
| 6 | CONTRIBUTING.md with contribution conventions for humans and agents | Check for `CONTRIBUTING.md` at the repo root |
| 7 | docs/ARCHITECTURE.md with institutional knowledge | Check for `docs/ARCHITECTURE.md` |

Present the results:

```
| Requirement                                        | Status |
|----------------------------------------------------|--------|
| Domain-specific guideline files (docs/)            |   ❌   |
| AGENTS.md (agent onboarding + docs index)          |   ❌   |
| CLAUDE.md (Claude-specific config + imports)       |   ❌   |
| CodeRabbit configured to enforce guidelines        |   ❌   |
| README.md (project overview + getting started)     |   ✅   |
| CONTRIBUTING.md (contribution workflow)            |   ❌   |
| docs/ARCHITECTURE.md (design decisions + context)  |   ❌   |
```

Then proceed to step 2.

## Step 2. Generate or update domain-specific guideline files

Present the following explanation to the user:

> Guideline files (`docs/*-guidelines.md`) are the deepest layer of the documentation system. They contain detailed, domain-specific rules (security, testing, database, etc.) — concrete conventions from your repo, not generic knowledge. AGENTS.md will point to these files so any AI agent can find them.

Ask the user if they want to generate or update guideline files. If they decline, skip to the next step.

If they accept, follow this process:

### 2a. Identify relevant domains

First, check if `AGENTS.md` exists and contains a docs index section. If it does, extract the domains already listed there — these were identified in a previous run and should be included in the suggested list.

Then, start from this curated list of domains:

- security
- performance (includes concurrency, thread safety, resource contention)
- error-handling
- api-contracts
- database (includes schema design and query patterns)
- testing
- integration

Merge the curated list with any previously identified domains from AGENTS.md (including custom domains the user may have added in a prior run).

Use an Explore agent with the Sonnet model to scan the repository and determine which domains from the merged list are relevant. A domain is relevant if the repo contains code, configuration, or patterns that fall within that domain (e.g., skip `database` if there is no database usage, skip `api-contracts` if there are no REST APIs).

Present the filtered list to the user and ask if they want to add any custom domains or remove any from the list. Wait for confirmation before proceeding.

### 2b. Explore and generate guidance

For each confirmed domain, launch an agent in the background using the Opus model. Each agent must:

1. Thoroughly explore the repository from its domain perspective — read source code, configuration files, existing documentation, test patterns, and any other relevant files
2. Identify the conventions, patterns, libraries, frameworks, and practices used in the repo for that domain
3. If `docs/<domain>-guidelines.md` already exists, read it first and incorporate its content — update with new findings while preserving still-accurate content
4. Return the complete guideline content as its result — do NOT write any files

Each guideline must not exceed 200 lines. To stay within this limit, agents must:

- Focus on repo-specific conventions and patterns, not general domain knowledge (e.g., don't explain what SQL injection is — describe how this repo validates input)
- Write concise, actionable rules — not explanations or tutorials
- Only document conventions that an agent couldn't infer from reading a single file
- Use short code examples only when the pattern isn't obvious from the rule itself

The agent decides the structure of the guideline content based on what it finds. The content should be actionable guidance that a specialized implementation or review agent can follow when working in this repo.

Once all exploration agents have completed, ensure the `docs/` directory exists and write each guideline to `docs/<domain>-guidelines.md`. Then proceed to verification.

### 2c. Verify guideline accuracy

For each domain, launch a verification agent in the background using the Sonnet model. Each verification agent must read `docs/<domain>-guidelines.md` for its assigned domain **and** all other `docs/*-guidelines.md` files for cross-document consistency checks. Each verification agent must:

1. **Reference accuracy** — Check every file path, class name, function name, and library reference mentioned in the guideline against the actual codebase using Grep and Glob. Flag any claim that cannot be confirmed (e.g., a file that doesn't exist, a pattern that isn't used, a library that isn't in the dependencies)
2. **Factual claims about libraries/frameworks** — Verify any claim about default values, behaviors, or semantics of external libraries and frameworks (e.g., "the default is unbounded", "this annotation requires X"). Use WebSearch to check official documentation when needed. Remove or correct any claim that is inaccurate
3. **Absolute rules vs existing code** — For every rule using absolute language ("Never", "Always", "Must", "All"), grep the codebase for counter-examples. If existing code violates the rule, either soften the language to "Prefer" / "Avoid" with the known exceptions listed, or scope the rule to specific contexts (e.g., "for new code" or "in module X")
4. **Cross-document consistency** — Compare the guideline against all other domain guidelines to detect contradictory advice. If two guidelines make conflicting claims, flag the conflict and reconcile by choosing the more specific or authoritative rule
5. Return the corrected version of the guideline as its result — do NOT write any files

The verification agent must NOT add new content — its only job is to confirm or correct what the exploration agent produced.

Once all verification agents have completed, overwrite each `docs/<domain>-guidelines.md` with the corrected content.

## Step 3. Generate or update AGENTS.md

Present the following explanation to the user:

> AGENTS.md is the onboarding doc for any AI agent — Claude, Cursor, CodeRabbit, or any other tool. It sits between the high-level README and the deep domain playbooks in `docs/`: it captures cross-cutting conventions (naming, code style, architecture) and includes an index pointing to the detailed guideline files. Unlike CLAUDE.md, it's agent-agnostic — any tool can use it.

Ask the user if they want to generate or update AGENTS.md. If they decline, skip to the next step.

If they accept, follow this process:

### 3a. Docs index

Detect all existing `docs/*-guidelines.md` files. Present the list to the user and ask which ones to include or update in the AGENTS.md docs index. Allow the user to discuss this — they can add, remove, or reorder entries. When they say "done" or "skip", proceed.

### 3b. AI guidance and repo conventions

Launch an agent in the background using the Opus model. The agent must:

1. Thoroughly explore the repository — read source code, configuration files, build scripts, CI/CD pipelines, existing documentation (including README.md), and any other relevant files
2. Read all existing `docs/*-guidelines.md` files to understand what's already covered in detail
3. If AGENTS.md already exists, read it first and incorporate its content — update with new findings while preserving still-accurate content
4. Identify cross-cutting conventions that span multiple domains and aren't already covered in the guideline files or README.md — things like naming conventions, code style, architectural patterns, common pitfalls, PR expectations, and any repo-specific workflows
5. Return the complete AGENTS.md content as its result — do NOT write any files

The proposed content should include:
- The docs index from step 3a
- Cross-cutting repo conventions that any AI agent needs to follow
- Architectural context that isn't obvious from reading a single file
- Common pitfalls or anti-patterns specific to this repo

The content must stay focused on what isn't already covered elsewhere. The `docs/*-guidelines.md` files have the domain depth — AGENTS.md should not duplicate it.

Once the agent has completed, present the proposed AGENTS.md content to the user for review. Let them adjust, add, or remove content. When they say "done" or "skip", write the agreed content to AGENTS.md.

## Step 4. Generate or update CLAUDE.md

Present the following explanation to the user:

> CLAUDE.md is the Claude Code-specific layer on top of AGENTS.md. It uses `@AGENTS.md` to import the agent guidance automatically, then adds anything that only applies to Claude Code — like build/test commands to run or behavioral preferences. It's intentionally thin: most guidance lives in AGENTS.md where all agents can use it.

Ask the user if they want to generate or update CLAUDE.md. If they decline, skip to the next step.

If they accept, follow this process:

CLAUDE.md must NOT duplicate or restate anything already in AGENTS.md or `docs/*-guidelines.md`. Since `@AGENTS.md` imports all that guidance, repeating it in CLAUDE.md is redundant and creates maintenance burden. The only content that belongs in CLAUDE.md is what is exclusive to Claude Code and irrelevant to other agents.

**Belongs in CLAUDE.md** (Claude Code-exclusive):
- `@AGENTS.md` import
- Build/test/lint commands Claude Code should run (e.g., `mvn verify`, `npm test`)
- Pre-commit hook behavior or CI checks Claude should be aware of
- Claude Code-specific behavioral preferences (e.g., "always run tests before suggesting a PR")

**Does NOT belong in CLAUDE.md** (put in AGENTS.md instead):
- Coding conventions, naming patterns, code style
- Architectural context, project structure
- Domain-specific rules (these go in `docs/*-guidelines.md`)
- Any guidance that would be useful to Cursor, CodeRabbit, or other AI tools

### If CLAUDE.md exists

1. Read the existing CLAUDE.md
2. Check if it already contains `@AGENTS.md`. If not, tell the user this import is needed for Claude Code to load the agent guidance, and offer to add it
3. Read AGENTS.md and all `docs/*-guidelines.md` files
4. Launch an agent in the background using the Sonnet model. The agent must:
   - Read CLAUDE.md, AGENTS.md, and all `docs/*-guidelines.md` files
   - Identify and remove any content in CLAUDE.md that duplicates or restates guidance already present in AGENTS.md or the guideline files
   - Explore the repository for build scripts, CI/CD pipelines, pre-commit hooks, test commands, and any other configuration exclusive to Claude Code
   - Propose an updated CLAUDE.md containing only Claude Code-exclusive content as defined above
   - Return the proposed content as its result — do NOT write any files
4. Present the proposed changes to the user for review. When they say "done" or "skip", write the agreed content

### If CLAUDE.md does not exist

1. Read AGENTS.md and all `docs/*-guidelines.md` files
2. Launch an agent in the background using the Sonnet model. The agent must:
   - Read AGENTS.md and all `docs/*-guidelines.md` files to know what is already covered — none of this content should appear in CLAUDE.md
   - Explore the repository for build scripts, CI/CD pipelines, pre-commit hooks, test commands, and any other configuration exclusive to Claude Code
   - Propose a minimal CLAUDE.md containing only Claude Code-exclusive content:
     - `@AGENTS.md` import (so Claude loads the agent guidance)
     - Build/test commands that Claude Code should run when working in this repo
     - Any Claude Code-specific behavioral preferences discovered from the repo
   - Return the proposed content as its result — do NOT write any files
3. Present the proposed content to the user for review. When they say "done" or "skip", write the agreed content

## Step 5. Configure CodeRabbit

Present the following explanation to the user:

> CodeRabbit is an AI-powered code review tool. By pointing it to the guideline files in `docs/`, it can enforce your repo-specific conventions automatically during pull request reviews — the same rules your implementation agents follow.

This step creates or updates a `.coderabbit.yaml` that points CodeRabbit to the `docs/*-guidelines.md` files.

Ask the user if they want to configure CodeRabbit. If they decline, skip to step 6.

If they accept:

### If `.coderabbit.yaml` does not exist

Create a new file with this content:

```yaml
# yaml-language-server: $schema=https://coderabbit.ai/integrations/schema.v2.json
# See https://docs.coderabbit.ai/reference/configuration for all fields and default values
knowledge_base:
  code_guidelines:
    filePatterns:
      - "docs/*-guidelines.md"
```

Do not include any other fields or sections — only what differs from CodeRabbit defaults.

### If `.coderabbit.yaml` already exists

1. Read the existing file
2. Merge the new `knowledge_base.code_guidelines.filePatterns` entry into the existing configuration
3. Preserve all existing settings — do not remove or overwrite them
4. If the existing file already contains a `knowledge_base.code_guidelines.filePatterns` entry, merge the patterns (avoid duplicates)
5. Ensure the schema comment and reference comment are present at the top of the file, adding them if missing

## Step 6. Generate or update README.md

Present the following explanation to the user:

> README.md is the front door of the repository — high-level project context for both humans and AI agents. While the guideline files and AGENTS.md give agents detailed rules, README.md helps them understand what the project is, how it's structured, and how to build and run it before diving into the code.

Ask the user if they want to generate or update README.md. If they decline, skip to the next step.

If they accept, follow this process:

### 6a. Assess existing content

If README.md exists, read it and assess whether it covers these areas:
- Project purpose and description
- Tech stack and key dependencies
- Project structure overview
- How to build and run the project
- Links to further documentation (AGENTS.md, CONTRIBUTING.md, docs/, etc.)

Present the assessment to the user, highlighting what's missing or could be improved.

### 6b. Propose content

Launch an agent in the background using the Opus model. The agent must:

1. Thoroughly explore the repository — read source code, configuration files, build scripts, existing documentation, and any other relevant files
2. Read AGENTS.md and all `docs/*-guidelines.md` files to understand what's already documented elsewhere and avoid duplicating it
3. If README.md already exists, read it first and incorporate its content — update with new findings while preserving still-accurate content
4. Propose README.md content covering the areas listed in step 6a, linking to AGENTS.md and other docs where appropriate
5. Return the complete README.md content as its result — do NOT write any files

### 6c. Review and write

Present the proposed content to the user for review. Let them adjust, add, or remove content. When they say "done" or "skip", write the agreed content to README.md.

## Step 7. Assess (after)

Re-check all requirements from step 1. Present the before/after comparison:

```
| Requirement                                        | Before | After |
|----------------------------------------------------|--------|-------|
| Domain-specific guideline files (docs/)            |   ❌   |  ✅   |
| AGENTS.md (agent onboarding + docs index)          |   ❌   |  ✅   |
| CLAUDE.md (Claude-specific config + imports)       |   ❌   |  ✅   |
| CodeRabbit configured to enforce guidelines        |   ❌   |  ✅   |
| README.md (project overview + getting started)     |   ✅   |  ✅   |
| CONTRIBUTING.md (contribution workflow)            |   ❌   |  ❌   |
| docs/ARCHITECTURE.md (design decisions + context)  |   ❌   |  ❌   |
```

## Step 8. Create a pull request (optional)

Ask the user if they want to create a pull request with all the changes made during this session. If they decline, stop here.

If they want a PR:

1. Create a new branch named `improve-agent-readiness`
2. Stage all changed and new files
3. Commit with a descriptive message summarizing what was created or updated
4. Push the branch and create a pull request using `gh pr create`
5. The PR description must start with: `This PR was generated by the /agent-readiness Claude skill from https://github.com/gwenneg/claude-engineering-toolkit.`
6. Display the PR link in the chat
