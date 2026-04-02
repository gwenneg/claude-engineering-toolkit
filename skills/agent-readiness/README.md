# /agent-readiness

Assesses how well a repository is set up for AI-assisted development, then walks you through improving it step by step.

## Quick start

```
claude --plugin-dir /path/to/claude-engineering-toolkit
> /agent-readiness
```

The skill runs entirely in your local checkout. It never pushes code or opens PRs unless you explicitly ask in the final step.

## What it checks

| # | Requirement | What it means |
|---|-------------|---------------|
| 1 | `docs/*-guidelines.md` | Domain-specific rules agents can follow during implementation and review |
| 2 | `AGENTS.md` | AI-specific repo guidance and an index of the guideline files |
| 3 | `CLAUDE.md` imports `AGENTS.md` | Ensures Claude Code loads the agent guidance automatically |
| 4 | `.coderabbit.yaml` | Points CodeRabbit to the guideline files for automated reviews |
| 5 | `README.md` | Foundational context about the project |
| 6 | `CONTRIBUTING.md` | Contribution conventions for humans and agents |
| 7 | `docs/ARCHITECTURE.md` | Institutional knowledge about the system design |

## How it works

```
                          /agent-readiness
                                │
                    ┌───────────┴───────────┐
                    │   Step 1: Assess      │
                    │   (read-only scan)    │
                    └───────────┬───────────┘
                                │
              ┌─────────────────┴──────────────────┐
              │   Step 2: Generate guideline files │
              │                                    │
              │  ┌──────────────────────────────┐  │
              │  │ 2a. Identify relevant domains│  │
              │  │     (Explore agent, Sonnet)  │  │
              │  └──────────┬───────────────────┘  │
              │             │                      │
              │  ┌──────────┴───────────────────┐  │
              │  │ 2b. Explore & generate       │  │
              │  │     (parallel Opus agents)   │  │
              │  └──────────┬───────────────────┘  │
              │             │                      │
              │  ┌──────────┴───────────────────┐  │
              │  │ 2c. Verify accuracy          │  │
              │  │     (parallel Sonnet agents) │  │
              │  └──────────────────────────────┘  │
              └─────────────────┬──────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │   Step 3: AGENTS.md   │
                    │   docs index + AI     │
                    │   guidance sections   │
                    └───────────┬───────────┘
                                │
                    ┌───────────┴───────────┐
                    │   Step 4: CLAUDE.md   │
                    │   add @AGENTS.md      │
                    └───────────┬───────────┘
                                │
                    ┌───────────┴───────────┐
                    │   Step 5: CodeRabbit  │
                    │   .coderabbit.yaml    │
                    └───────────┬───────────┘
                                │
                    ┌───────────┴───────────┐
                    │   Step 6: Assess      │
                    │   (before vs after)   │
                    └───────────┬───────────┘
                                │
                    ┌───────────┴───────────┐
                    │   Step 7: PR          │
                    │   (optional)          │
                    └───────────────────────┘
```

Every step is interactive — you can say **"done"** or **"skip"** to move on.

## Guideline generation in detail

Step 2 is where most of the work happens. The skill uses multiple agents in parallel to produce high-quality, repo-specific guidelines:

1. **Domain detection** — An Explore agent (Sonnet) scans the repo to determine which domains apply. For example, if there's no database usage, the `database` domain is skipped. You can add or remove domains before generation starts.

2. **Exploration** — One Opus agent per domain reads source code, configs, tests, and docs to extract the conventions and patterns actually used in the repo. Each guideline is capped at 200 lines of actionable rules (not tutorials).

3. **Verification** — One Sonnet agent per domain cross-checks every claim against the codebase:
   - File paths, class names, and function references are verified with Grep/Glob
   - Library behavior claims are checked against official docs via web search
   - Absolute rules ("Never", "Always") are tested for counter-examples in existing code
   - Cross-document consistency is checked across all guideline files

## Example output

After a full run on a typical Java service:

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

Generated files:
```
docs/
  security-guidelines.md
  performance-guidelines.md
  error-handling-guidelines.md
  api-contracts-guidelines.md
  database-guidelines.md
  testing-guidelines.md
AGENTS.md
CLAUDE.md
.coderabbit.yaml
```

## Tips

- **Run it early.** The generated guidelines improve every AI tool that reads them — Claude Code, CodeRabbit, Copilot, Cursor, etc.
- **Review the output.** The verification step catches most inaccuracies, but you know your repo best. Treat the generated guidelines as a strong first draft.
- **Re-run after major changes.** If you add a new database, switch frameworks, or restructure the project, run `/agent-readiness` again to update the guidelines.
- **Commit guidelines to the repo.** They're meant to be checked in and maintained alongside the code.
