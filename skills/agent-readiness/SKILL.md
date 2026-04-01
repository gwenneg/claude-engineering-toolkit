---
name: agent-readiness
description: Assess and improve a repository's readiness for AI-assisted development
---

Assess the current repository's readiness for AI-assisted development, then offer to improve it step by step. $ARGUMENTS

Whenever you need to ask the user a question, always use the AskUserQuestion tool — never ask as plain text.

When a step involves a discussion with the user, tell them they can say "done" or "skip" to move on to the next step.

## Step 1. Assess (before)

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
| AGENTS.md with AI guidance and docs index          |   ❌   |
| CLAUDE.md imports AGENTS.md                        |   ❌   |
| CodeRabbit configured with guidelines              |   ❌   |
| README.md with foundational context                |   ✅   |
| CONTRIBUTING.md with contribution conventions      |   ❌   |
| docs/ARCHITECTURE.md with institutional knowledge  |   ❌   |
```

Then proceed to step 2.

## Step 2. Generate or update domain-specific guideline files

Guideline files give implementation and review agents concrete, repo-specific rules to follow instead of relying on generic knowledge. They live in `docs/*-guidelines.md`.

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

AGENTS.md provides AI-specific guidance that any agent (not just Claude) can use when working in this repository. It contains repo conventions, patterns, and an index pointing to the more granular guideline files in `docs/`.

### 3a. Docs index

Detect all existing `docs/*-guidelines.md` files. Present the list to the user and ask which ones to include or update in the AGENTS.md docs index. Allow the user to discuss this — they can add, remove, or reorder entries. When they say "done" or "skip", proceed.

If AGENTS.md already exists, read it first. Add the docs index if missing, or update it if present, without touching unrelated sections.

If AGENTS.md does not exist, create it with the docs index.

### 3b. AI guidance and repo conventions

Ask the user if they also want to generate the AI guidance and repo conventions sections of AGENTS.md. Give a brief explanation: these sections capture repo-specific patterns and conventions that help agents work effectively — things like preferred coding style, architectural decisions, or domain-specific context that isn't obvious from the code alone.

If they accept, discuss with the user what should go in these sections. Let them drive the content. When they say "done" or "skip", write the agreed content to AGENTS.md.

## Step 4. CLAUDE.md

### If CLAUDE.md exists

Check if it already contains `@AGENTS.md`. If not, ask the user if they want to add it. If they accept, add `@AGENTS.md` to CLAUDE.md.

### If CLAUDE.md does not exist

CLAUDE.md is a Claude Code-specific file that configures how Claude behaves in this repository. It can include project context, build/test commands, coding conventions, and references to other files (like AGENTS.md via the `@` import syntax). It's loaded automatically at the start of every Claude Code conversation, making it the primary way to give Claude persistent context about the project.

Present this explanation to the user and offer to discuss and generate a CLAUDE.md together. The generated file should include `@AGENTS.md` to import the agent guidance. Let the user drive the content. When they say "done" or "skip", write the agreed content or move on.

## Step 5. Configure CodeRabbit

CodeRabbit can use the guideline files to inform its automated reviews. This step creates or updates a `.coderabbit.yaml` that points CodeRabbit to the `docs/*-guidelines.md` files.

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

## Step 6. Assess (after)

Re-check all requirements from step 1. Present the before/after comparison:

```
| Requirement                                        | Before | After |
|----------------------------------------------------|--------|-------|
| Domain-specific guideline files (docs/)            |   ❌   |  ✅   |
| AGENTS.md with AI guidance and docs index          |   ❌   |  ✅   |
| CLAUDE.md imports AGENTS.md                        |   ❌   |  ✅   |
| CodeRabbit configured with guidelines              |   ❌   |  ✅   |
| README.md with foundational context                |   ✅   |  ✅   |
| CONTRIBUTING.md with contribution conventions      |   ❌   |  ❌   |
| docs/ARCHITECTURE.md with institutional knowledge  |   ❌   |  ❌   |
```

## Step 7. Create a pull request (optional)

Ask the user if they want to create a pull request with all the changes made during this session. If they decline, stop here.

If they want a PR:

1. Create a new branch named `improve-agent-readiness`
2. Stage all changed and new files
3. Commit with a descriptive message summarizing what was created or updated
4. Push the branch and create a pull request using `gh pr create`
5. The PR description must start with: `This PR was generated by the /agent-readiness Claude skill from https://github.com/gwenneg/claude-engineering-toolkit.`
6. Display the PR link in the chat
