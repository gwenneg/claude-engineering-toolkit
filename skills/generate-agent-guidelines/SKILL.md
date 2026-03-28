---
name: generate-agent-guidelines
description: Generate domain-specific guideline files for specialized implementation and review agents
---

Generate domain-specific guideline files that specialized agents can reference when implementing or reviewing code in this repository. $ARGUMENTS

Whenever you need to ask the user a question, always use the AskUserQuestion tool — never ask as plain text.

## 1. Identify relevant domains

First, check if `CLAUDE.md` exists and contains an `## Implementation And Review Guidelines` section. If it does, extract the domains already listed there — these were identified in a previous run and should be included in the suggested list.

Then, start from this curated list of domains:

- security
- performance (includes concurrency, thread safety, resource contention)
- error-handling
- api-contracts
- database (includes schema design and query patterns)
- testing
- integration

Merge the curated list with any previously identified domains from CLAUDE.md (including custom domains the user may have added in a prior run).

Use an Explore agent to scan the repository and determine which domains from the merged list are relevant. A domain is relevant if the repo contains code, configuration, or patterns that fall within that domain (e.g., skip `database` if there is no database usage, skip `api-contracts` if there are no REST APIs).

Present the filtered list to the user and ask if they want to add any custom domains or remove any from the list. Wait for confirmation before proceeding.

## 2. Explore and generate guidance

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

## 3. Verify guideline accuracy

For each domain, launch a verification agent in the background using the Sonnet model. Each verification agent must read `docs/<domain>-guidelines.md` for its assigned domain **and** all other `docs/*-guidelines.md` files for cross-document consistency checks. Each verification agent must:

1. **Reference accuracy** — Check every file path, class name, function name, and library reference mentioned in the guideline against the actual codebase using Grep and Glob. Flag any claim that cannot be confirmed (e.g., a file that doesn't exist, a pattern that isn't used, a library that isn't in the dependencies)
2. **Factual claims about libraries/frameworks** — Verify any claim about default values, behaviors, or semantics of external libraries and frameworks (e.g., "the default is unbounded", "this annotation requires X"). Use WebSearch to check official documentation when needed. Remove or correct any claim that is inaccurate
3. **Absolute rules vs existing code** — For every rule using absolute language ("Never", "Always", "Must", "All"), grep the codebase for counter-examples. If existing code violates the rule, either soften the language to "Prefer" / "Avoid" with the known exceptions listed, or scope the rule to specific contexts (e.g., "for new code" or "in module X")
4. **Cross-document consistency** — Compare the guideline against all other domain guidelines to detect contradictory advice. If two guidelines make conflicting claims, flag the conflict and reconcile by choosing the more specific or authoritative rule
5. Return the corrected version of the guideline as its result — do NOT write any files

The verification agent must NOT add new content — its only job is to confirm or correct what the exploration agent produced.

Once all verification agents have completed, overwrite each `docs/<domain>-guidelines.md` with the corrected content.

## 4. Update CLAUDE.md

After all domain agents have completed:

1. If `CLAUDE.md` does not exist at the repo root, create it with a minimal structure
2. Add or update an `## Implementation And Review Guidelines` section in `CLAUDE.md` with a bullet list linking to each generated guideline file, formatted as:

```markdown
## Implementation And Review Guidelines
- Security: docs/security-guidelines.md
- Performance: docs/performance-guidelines.md
```

Use the domain name (capitalized) as the label. If the section already exists, update it to reflect the current set of guideline files — add new entries and remove entries for domains that are no longer relevant. Do not modify other sections of CLAUDE.md.

## 5. Create a pull request (optional)

After all files have been generated/updated and CLAUDE.md has been updated, ask the user if they want to create a pull request with the changes. If they decline, stop here.

If they want a PR:

1. Create a new branch named `add-agent-guidelines`
2. Stage all changed and new files (`docs/*-guidelines.md` and `CLAUDE.md`)
3. Commit with a descriptive message summarizing which guideline files were created or updated and for which domains
4. Push the branch and create a pull request using `gh pr create`
5. Display the PR link in the chat
