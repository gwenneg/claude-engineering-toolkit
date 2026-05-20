# AGENTS.md Validation Checklist

## Overview

AGENTS.md is the onboarding doc for any AI agent (Claude, Cursor, CodeRabbit, etc.). It captures cross-cutting conventions and provides an index to detailed guideline files. It should be agent-agnostic — nothing specific to one tool.

## Automated Checks

Run these checks programmatically:

- [ ] **File exists**: `AGENTS.md` is present at repo root
- [ ] **File size**: < 2000 lines recommended (not a hard limit, but keep reasonable)
  ```bash
  wc -l AGENTS.md
  ```
- [ ] **No hardcoded secrets**: No API keys, passwords, tokens, or credentials
  ```bash
  grep -iE "(api_key|password|secret|token|credential)" AGENTS.md
  ```
- [ ] **Contains docs index**: References to guideline files
  ```bash
  grep -i "docs.*guidelines" AGENTS.md
  ```

## Content Quality Checks

These require agent review:

### 1. Cross-Cutting Conventions

AGENTS.md should describe conventions that span multiple domains and aren't already covered in guideline files or README.md.

- [ ] Naming conventions (files, variables, functions, modules)
- [ ] Code style and formatting preferences
- [ ] Architectural patterns used across the project
- [ ] Common anti-patterns specific to this repo
- [ ] PR and code review expectations

**Avoid**: Duplicating domain-specific rules from `docs/*-guidelines.md`

### 2. Docs Index Accuracy

The docs index should accurately point to all existing guideline files.

- [ ] Lists all `docs/*-guidelines.md` files
- [ ] Links are correct and files exist
- [ ] Descriptions match file contents
- [ ] No broken links to non-existent files

**Verification**:
```bash
# List all guideline files
find docs -name "*-guidelines.md"

# Compare with docs index in AGENTS.md
```

### 3. No Duplication

AGENTS.md should not duplicate content from other documentation files.

- [ ] README.md content not repeated (high-level overview, getting started)
- [ ] Domain-specific rules not repeated (those belong in `docs/*-guidelines.md`)
- [ ] No duplication of Claude Code-specific content (that belongs in CLAUDE.md)

**Keep unique**: Cross-cutting conventions, architectural context, docs index

### 4. Architectural Context

Include repo-specific architectural decisions and patterns.

- [ ] Architectural context is actually from this repo (not generic advice)
- [ ] Design decisions are documented with rationale
- [ ] Module organization and boundaries are explained
- [ ] Integration patterns between components are described

**Examples**:
- ✅ Good: "We use event sourcing for the billing service because..."
- ❌ Bad: "Event sourcing is a pattern where..."

### 5. Common Pitfalls Are Repo-Specific

List actual pitfalls from this codebase, not generic ones.

- [ ] Pitfalls are specific to this repo
- [ ] Examples reference actual code or past issues
- [ ] Not just generic best practices

**Examples**:
- ✅ Good: "Don't access `database.connection` directly — use `DbPool.get()` to avoid connection leaks (see incident #45)"
- ❌ Bad: "Always validate user input"

### 6. Agent-Agnostic Content

AGENTS.md should work for any AI agent, not just Claude Code.

- [ ] No Claude Code-specific commands (those go in CLAUDE.md)
- [ ] No mentions of Claude-specific behavior or preferences
- [ ] Guidance useful to Cursor, CodeRabbit, and other tools
- [ ] Tool-neutral language throughout

**If it mentions Claude Code**: Move it to CLAUDE.md

## Common Mistakes to Avoid

| Mistake | Why It's Wrong | Correct Approach |
|---------|----------------|------------------|
| ❌ Duplicating security rules from `docs/security-guidelines.md` | Creates maintenance burden, confusion | Keep domain rules in guideline files only |
| ❌ Including `npm test` command | Claude Code-specific, not useful to other agents | Put in CLAUDE.md instead |
| ❌ Copying project description from README.md | Duplication | Link to README.md or keep it there only |
| ❌ Generic advice: "Write clean code" | Not repo-specific | Describe actual conventions used in this repo |
| ❌ Missing links to guideline files | Agents can't find detailed rules | Include complete docs index |
| ❌ "When using Claude, remember to..." | Agent-specific | Keep agent-agnostic or move to CLAUDE.md |

## Validation Commands

```bash
# Check file size
wc -l AGENTS.md
# Expected: < 2000 lines (recommended)

# Check for secrets
grep -iE "(api_key|password|secret|token|credential)" AGENTS.md
# Expected: no matches

# Verify docs index completeness
echo "=== Guideline files in repo ==="
find docs -name "*-guidelines.md" 2>/dev/null || echo "No docs/ directory"

echo "=== Referenced in AGENTS.md ==="
grep -o "docs/[a-z-]*guidelines\.md" AGENTS.md | sort -u

# Check for Claude-specific content (may belong in CLAUDE.md)
grep -i "claude code\|claude-specific\|/[a-z-]*\s" AGENTS.md
```

## Structure Recommendations

A well-structured AGENTS.md typically includes:

```markdown
# Project Name

Brief overview and purpose (can reference README.md for details)

## Docs Index

- [Security Guidelines](docs/security-guidelines.md) - Auth, secrets, input validation
- [Testing Guidelines](docs/testing-guidelines.md) - Test patterns, coverage expectations
- [Database Guidelines](docs/database-guidelines.md) - Schema, migrations, query patterns
...

## Cross-Cutting Conventions

### Naming Conventions
[Repo-specific naming patterns]

### Code Style
[Project-specific style preferences beyond standard formatters]

### Architecture
[Key architectural patterns and decisions]

## Common Pitfalls

- [Repo-specific anti-patterns with examples]

## Contribution Workflow

[How agents should approach changes, PR expectations]
```

## Success Criteria

AGENTS.md passes validation when:

- ✅ All automated checks pass (exists, size reasonable, no secrets, has docs index)
- ✅ Describes cross-cutting conventions not in guideline files or README.md
- ✅ Docs index accurately lists all `docs/*-guidelines.md` files
- ✅ No duplication with README.md, guideline files, or CLAUDE.md
- ✅ Architectural context is repo-specific, not generic
- ✅ Common pitfalls are actual issues from this codebase
- ✅ Content is agent-agnostic (works for any AI tool)
- ✅ Provides clear value: agents know where to find detailed rules and understand cross-repo conventions
