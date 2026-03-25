---
name: agent-ready
description: Assess how well a repository is set up for AI-assisted development
---

Evaluate the current repository's readiness for AI-assisted development and produce a score with actionable recommendations. $ARGUMENTS

## 1. Assess the repository

Examine the following dimensions by reading files, checking for patterns, and exploring the project structure. Do NOT modify any files.

### Documentation (0–20 points)

| Points | Criterion |
|--------|-----------|
| 4 | README exists with clear project description and purpose |
| 4 | Build, run, and test instructions are documented and accurate |
| 4 | CLAUDE.md or equivalent AI agent instructions exist |
| 4 | Architecture or design documentation exists (inline or separate docs) |
| 4 | API documentation exists (OpenAPI spec, endpoint docs, or equivalent) |

### Testing (0–20 points)

| Points | Criterion |
|--------|-----------|
| 4 | Test framework is configured and tests can be discovered |
| 4 | Tests exist alongside source code with meaningful coverage |
| 4 | Test run command is documented or easily discoverable |
| 4 | Tests follow consistent patterns (naming, structure, assertions) |
| 4 | Integration or end-to-end tests exist beyond unit tests |

### Code Quality & Conventions (0–20 points)

| Points | Criterion |
|--------|-----------|
| 4 | Linter or formatter is configured (e.g., ESLint, Checkstyle, Spotless) |
| 4 | Consistent naming conventions across the codebase |
| 4 | Clear project structure with logical separation of concerns |
| 4 | Dependencies are managed with a lock file or BOM |
| 4 | Error handling follows consistent patterns |

### CI/CD & Automation (0–15 points)

| Points | Criterion |
|--------|-----------|
| 5 | CI pipeline exists and runs tests on PRs |
| 5 | Pre-commit hooks or automated checks are configured |
| 5 | Build process is reproducible with a single command |

### AI Agent Ergonomics (0–25 points)

| Points | Criterion |
|--------|-----------|
| 5 | CLAUDE.md contains project-specific conventions and patterns |
| 5 | CLAUDE.md contains build/test/lint commands |
| 5 | Domain-specific guideline files exist for specialized agents |
| 5 | Service documentation file exists (e.g., `.claude-skill-implement.md`) with architecture, data model, and business rules |
| 5 | Repository size and structure allow agents to navigate efficiently (no monorepo without clear boundaries, no deeply nested or ambiguous paths) |

## 2. Score and present results

Present a results table:

| Dimension | Score | Max |
|-----------|-------|-----|
| Documentation | X | 20 |
| Testing | X | 20 |
| Code Quality & Conventions | X | 20 |
| CI/CD & Automation | X | 15 |
| AI Agent Ergonomics | X | 25 |
| **Total** | **X** | **100** |

Then assign a readiness grade:

| Score | Grade | Meaning |
|-------|-------|---------|
| 80–100 | A | Agent-ready — AI agents can work effectively |
| 60–79 | B | Mostly ready — some gaps to address |
| 40–59 | C | Partially ready — significant improvements needed |
| 0–39 | D | Not ready — foundational work required |

## 3. Recommendations

List the top 5 highest-impact improvements the user can make, ordered by points recoverable. For each:

- What is missing or insufficient
- Why it matters for AI-assisted development
- A concrete action to fix it
