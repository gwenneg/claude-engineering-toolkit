---
name: full-review
description: Launch all 11 review agents in parallel for a thorough code review
---

Run a comprehensive code review by launching all review agents in parallel.

First, run `git diff master...HEAD` to get the full diff. Pass the complete diff output to each agent so they know exactly which files and lines changed.

Spawn each of the following agents in the background without worktree isolation, asking each to review changes on the current branch vs the main branch. These agents are read-only reviewers and do not need isolated worktrees. Launching 10 worktrees in parallel causes git lock contention on `.git/config`, leading to failures and retries. IMPORTANT: Include the diff output in each agent's prompt and instruct them to ONLY review files and lines that appear in the diff — they must not explore or report on files outside the changeset. Exceptions: the lint-reviewer runs golangci-lint against the entire codebase, not just the diff. Do NOT specify a config file in the lint-reviewer prompt — the agent has its own config detection logic that must not be overridden. The vuln-reviewer runs govulncheck against the entire module, not just the diff.

1. @security-reviewer
2. @performance-reviewer
3. @test-reviewer
4. @error-handling-reviewer
5. @concurrency-reviewer
6. @api-contract-reviewer
7. @db-query-reviewer
8. @db-schema-reviewer
9. @integration-reviewer
10. @lint-reviewer
11. @vuln-reviewer

Additional focus areas if specified: $ARGUMENTS

Once all agents complete, compile their findings into a single summary organized by severity:
1. Critical - must fix before merge
2. High - should fix before merge
3. Medium - consider fixing
4. Low - optional improvements

Include file:line references for every finding.
