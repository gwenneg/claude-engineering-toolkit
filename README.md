# Claude Engineering Toolkit

A Claude Code plugin that provides specialized review agents and engineering skills for thorough, parallel code reviews, Jira workflows, and ticket-driven implementation.

## Installation

### Per-session

Use the `--plugin-dir` flag when starting Claude Code:

```bash
claude --plugin-dir /path/to/claude-engineering-toolkit
```

### Per-Repo

Optionally, copy the contents of `exampleconfig/hooks` to `.claude/hooks` in
your repo. Likewise, adjust `.claude/settings.json` in your repo, based on the
example provided in `exampleconfig/settings.json`. This provides claude
permission to run `golangci-lint` and `govulncheck` commands without asking.

### Always loaded (shell alias)

To permanently load the plugin in every session, add an alias to your shell config (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
alias claude='claude --plugin-dir /path/to/claude-engineering-toolkit'
```

Then reload your shell config:

```bash
source ~/.bashrc
```

## Skills

Skills are user-invocable commands you can run directly in Claude Code with the `/` prefix.

### `/full-review` - Parallel Code Review

Launches all 11 review agents in parallel to perform a comprehensive code review, comparing changes on your current branch vs `main`.

```
/full-review
```

You can also provide additional focus areas:

```
/full-review pay special attention to the new webhook retry logic
```

Once all agents complete, findings are compiled into a single summary organized by severity:

1. **Critical** - must fix before merge
2. **High** - should fix before merge
3. **Medium** - consider fixing
4. **Low** - optional improvements

Every finding includes `file:line` references.

### `/jira-ticket` - Create Jira Tickets

Generates a well-structured Jira ticket from a natural language description. Requires Jira MCP tools to be configured.

```
/jira-ticket Add rate limiting to the webhook delivery endpoint
```

The skill will:
- Write a concise summary (under 100 characters)
- Add context, details, and acceptance criteria to the description
- Set the appropriate issue type (Epic, Story, or Spike) and priority
- Set the Activity Type (e.g., Product/Portfolio Work, Security & Compliance, Quality/Stability/Reliability)
- Assign the team, component, and labels automatically
- Optionally create a paired QE testing ticket
- Search the codebase for relevant file paths and line numbers
- Create the ticket via Jira MCP and return the ticket key and URL

### `/implement` - Implement a Feature from a Jira Ticket

Implements a feature based on a Jira ticket, with built-in quality gates for ticket completeness and service documentation. Requires Jira MCP tools to be configured.

```
/implement RHCLOUD-44561
```

The skill will:
1. **Fetch the ticket** from Jira and extract summary, description, acceptance criteria, and linked issues
2. **Validate ticket quality** — checks for Context/Background, Technical Details, and Acceptance Criteria sections. Stops if missing and asks whether to proceed or improve the ticket first
3. **Load service guidelines** — looks for guideline files matching `docs/*-guidelines.md` containing architecture, conventions, data model, and other service-specific context. Stops if none are found and asks whether to proceed
4. **Plan the implementation** — identifies files to change, breaks work into steps, calls out assumptions, and asks for confirmation before writing code
5. **Implement the feature** — writes code following existing codebase patterns and conventions
6. **Verify acceptance criteria** — presents a checklist of each criterion with pass/fail status

The skill never pushes code, opens PRs, or takes any action visible to others — its scope ends at local implementation.

### `/my-work` - Prioritized Work Dashboard

Displays a prioritized dashboard of your current work across Jira, GitHub, and Google Tasks. Requires Jira MCP tools and `gh` CLI to be configured.

```
/my-work
```

The skill will:
- Fetch your assigned Jira tickets (not Done/Closed), open GitHub review requests, and incomplete Google Tasks — all in parallel
- Display three sorted tables: Jira tickets by priority/status, GitHub PRs (non-draft first), and Google Tasks by due date
- Provide prioritized recommendations on what to work on next

### `/agent-readiness` - AI-Readiness Assessment

Assesses how well a repository is set up for AI-assisted development, then offers to improve it step by step.

```
/agent-readiness
```

The skill checks 7 requirements and presents a status table:
1. Domain-specific guideline files (`docs/*-guidelines.md`)
2. AGENTS.md with AI guidance and docs index
3. CLAUDE.md imports AGENTS.md
4. CodeRabbit configured with guideline files
5. README.md with foundational context
6. CONTRIBUTING.md with contribution conventions
7. docs/ARCHITECTURE.md with institutional knowledge

After the initial assessment, it walks you through improving each area — explaining what each file is for as you go:
- **Generate guideline files** — launches parallel agents to explore the codebase per domain, then verifies accuracy
- **Generate AGENTS.md** — AI explores the repo and proposes cross-cutting conventions + a docs index (user reviews before writing)
- **Generate CLAUDE.md** — AI proposes a minimal Claude Code-specific config that imports AGENTS.md without duplicating it (user reviews before writing)
- **Configure CodeRabbit** — points `.coderabbit.yaml` to the guideline files
- **Generate README.md** — AI proposes project overview content based on the repo (user reviews before writing)
- **Before/after comparison** — re-checks all requirements and shows improvement
- **Optional PR** — creates a pull request with all changes

## Review Agents

The plugin includes 11 specialized review agents. Each agent focuses on a specific area and can be invoked individually with `@agent-name` or all at once via `/full-review`.

| Agent | Model | Focus Area |
|---|---|---|
| `@security-reviewer` | Opus | OWASP Top 10, auth, secrets, input validation, crypto |
| `@performance-reviewer` | Sonnet | Allocations, blocking calls, caching, memory leaks, thread pools |
| `@test-reviewer` | Sonnet | Coverage gaps, brittle tests, mock correctness, test isolation |
| `@error-handling-reviewer` | Sonnet | Swallowed exceptions, error propagation, HTTP status codes |
| `@concurrency-reviewer` | Opus | Race conditions, deadlocks, thread safety, transaction isolation |
| `@api-contract-reviewer` | Sonnet | Breaking changes, REST conventions, backward compatibility |
| `@db-query-reviewer` | Sonnet | N+1 queries, unbounded SELECTs, JPA/Hibernate correctness |
| `@db-schema-reviewer` | Opus | Missing indexes, migration safety, constraints, column types |
| `@integration-reviewer` | Sonnet | Webhook delivery, retries, idempotency, circuit breakers |
| `@lint-reviewer` | Sonnet | Runs `golangci-lint` against the code base, if it detects Go code. |
| `@vuln-reviewer` | Sonnet | Runs `govulncheck` against the code base, if it detects Go code. |

All agents run in the `background`, comparing the current branch against `main`.

## Code Review Workflows

### Reviewing your own code before creating a PR

When you're on a feature branch and want to review your changes before opening a pull request:

```bash
# Make sure you're on your feature branch
git checkout my-feature-branch

# Run the full review
claude
> /full-review
```

This compares your current branch against `main` and runs all 11 agents in parallel. You'll get a consolidated report with findings sorted by severity. Fix any Critical/High issues before pushing your PR.

You can also run a single agent if you only care about a specific area:

```
> @security-reviewer review changes on the current branch vs main
```

### Reviewing someone else's PR

To review a pull request from a colleague:

```bash
# Fetch and check out their branch
git fetch origin
git checkout pr-branch-name

# Run the full review
claude
> /full-review
```

Or, if you want to review a GitHub PR by number using the `gh` CLI:

```bash
gh pr checkout 123
claude
> /full-review
```

The agents will compare the PR branch against `main` and produce the same severity-organized report. You can then use the findings to leave informed review comments on the PR.

For a targeted review, invoke specific agents:

```
> @db-query-reviewer review changes on the current branch vs main
> @security-reviewer review changes on the current branch vs main
```

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.
