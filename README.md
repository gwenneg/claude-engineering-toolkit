# Claude Engineering Toolkit

A Claude Code plugin that provides specialized review agents and engineering skills for thorough, parallel code reviews and Jira workflows.

## Installation

Add this plugin to your Claude Code configuration by including it in your `.claude/settings.json`:

```json
{
  "plugins": [
    "/path/to/claude-engineering-toolkit"
  ]
}
```

Or install it directly:

```bash
claude plugin add /path/to/claude-engineering-toolkit
```

## Skills

Skills are user-invocable commands you can run directly in Claude Code with the `/` prefix.

### `/full-review` - Parallel Code Review

Launches all 9 review agents in parallel to perform a comprehensive code review. Each agent runs in its own isolated worktree, reviewing changes on your current branch vs `main`.

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
- Set the appropriate issue type (Story, Bug, Task) and priority
- Search the codebase for relevant file paths and line numbers
- Create the ticket via Jira MCP and return the ticket key and URL

## Review Agents

The plugin includes 9 specialized review agents. Each agent focuses on a specific area and can be invoked individually with `@agent-name` or all at once via `/full-review`.

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

All agents run with `worktree` isolation and in the `background`, comparing the current branch against `main`.

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

This compares your current branch against `main` and runs all 9 agents in parallel. You'll get a consolidated report with findings sorted by severity. Fix any Critical/High issues before pushing your PR.

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
