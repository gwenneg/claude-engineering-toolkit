# CLAUDE.md Validation Checklist

## Overview

CLAUDE.md is the Claude Code-specific layer on top of AGENTS.md. It should be minimal — most guidance lives in AGENTS.md where all agents can use it. CLAUDE.md only adds what is exclusive to Claude Code and irrelevant to other tools.

## Automated Checks

Run these checks programmatically:

- [ ] **File exists**: `CLAUDE.md` is present at repo root
- [ ] **File size**: < 300 lines recommended (should be minimal since most content is in AGENTS.md)
  ```bash
  wc -l CLAUDE.md
  ```
- [ ] **Contains @AGENTS.md import**: Must import AGENTS.md to load agent guidance
  ```bash
  grep "@AGENTS.md" CLAUDE.md
  ```
- [ ] **No hardcoded secrets**: No API keys, passwords, tokens, or credentials
  ```bash
  grep -iE "(api_key|password|secret|token|credential)" CLAUDE.md
  ```

## Content Quality Checks

These require agent review with reference to [templates/claude-md-scope.md](../claude-md-scope.md):

### 1. @AGENTS.md Import Present

CLAUDE.md must import AGENTS.md to load all agent guidance automatically.

- [ ] Contains `@AGENTS.md` at or near the top
- [ ] Import is not commented out
- [ ] No duplication of AGENTS.md content after the import

**Critical**: Without this import, Claude Code won't load the agent guidance from AGENTS.md.

### 2. Claude Code-Exclusive Content Only

See [templates/claude-md-scope.md](../claude-md-scope.md) for complete scope guidance.

**✅ Belongs in CLAUDE.md** (Claude Code-exclusive):
- [ ] Build/test/lint commands Claude Code should run (e.g., `mvn verify`, `npm test`)
- [ ] Pre-commit hook behavior or CI checks Claude should be aware of
- [ ] Claude Code-specific behavioral preferences (e.g., "always run tests before suggesting a PR")
- [ ] Development workflow commands specific to Claude Code usage

**❌ Does NOT belong in CLAUDE.md** (put in AGENTS.md instead):
- [ ] No coding conventions, naming patterns, or code style
- [ ] No architectural context or project structure
- [ ] No domain-specific rules (those go in `docs/*-guidelines.md`)
- [ ] No guidance that would be useful to Cursor, CodeRabbit, or other AI tools

### 3. No Duplication

CLAUDE.md should not duplicate content from AGENTS.md or guideline files.

- [ ] No repeated conventions from AGENTS.md
- [ ] No repeated rules from `docs/*-guidelines.md`
- [ ] Only Claude Code-specific additions

**Remember**: `@AGENTS.md` imports all that guidance, so repeating it is redundant.

### 4. Build Commands Are Accurate

If build/test commands are listed, they should be accurate and tested.

- [ ] Commands actually work in the repository
- [ ] Commands are the correct ones for this project
- [ ] Commands handle edge cases (e.g., missing dependencies)

**Verification**: Try running the commands to ensure they work.

### 5. Minimal File Size

Since most content should be in AGENTS.md, CLAUDE.md should be concise.

- [ ] Under 300 lines recommended
- [ ] No unnecessary explanations (put those in AGENTS.md)
- [ ] Direct and to the point

## Common Mistakes to Avoid

| Mistake | Why It's Wrong | Correct Approach |
|---------|----------------|------------------|
| ❌ Missing `@AGENTS.md` import | Claude Code won't load agent guidance | Add `@AGENTS.md` at the top |
| ❌ Repeating naming conventions from AGENTS.md | Duplication, maintenance burden | Remove — they're imported via @AGENTS.md |
| ❌ Including security rules | Domain-specific, useful to all agents | Keep in `docs/security-guidelines.md` |
| ❌ Generic architectural context | Useful to all agents | Keep in AGENTS.md |
| ❌ File is 800 lines | Too much content for Claude-specific file | Move most to AGENTS.md, keep only Claude-specific |
| ❌ "Code should follow PEP 8" | Coding convention, useful to all agents | Move to AGENTS.md |
| ✅ "Run `pytest` before creating a PR" | Claude Code-specific workflow | Perfect for CLAUDE.md |

## Validation Commands

```bash
# Check file size
wc -l CLAUDE.md
# Expected: < 300 lines

# Check for @AGENTS.md import
grep "@AGENTS.md" CLAUDE.md
# Expected: at least one match

# Check for secrets
grep -iE "(api_key|password|secret|token|credential)" CLAUDE.md
# Expected: no matches

# Look for potential content that belongs in AGENTS.md
grep -iE "(naming convention|code style|architecture|always use|pattern)" CLAUDE.md
# Review each match to see if it's truly Claude-specific
```

## Structure Recommendation

A minimal, well-structured CLAUDE.md:

```markdown
@AGENTS.md

# Claude Code Configuration

## Build Commands

Run these commands before suggesting changes:

```bash
npm run lint
npm test
```

## Pre-commit Hooks

This repo uses pre-commit hooks that will:
- Run linting (fails on errors)
- Format code automatically
- Check for secrets

If a hook fails, the commit did NOT happen — fix the issue and create a NEW commit (don't amend).

## Claude Code Preferences

- Always run `npm test` before suggesting a PR
- When making database changes, also update `schema.md`
- [Other Claude-specific behavioral preferences]
```

## Scope Decision Tree

Use this to decide if content belongs in CLAUDE.md:

```
Is it useful ONLY to Claude Code and not to other agents?
├─ Yes → Does it involve build/test/workflow commands?
│         ├─ Yes → ✅ Belongs in CLAUDE.md
│         └─ No → Is it a behavioral preference for Claude Code?
│                   ├─ Yes → ✅ Belongs in CLAUDE.md
│                   └─ No → ❌ Move to AGENTS.md
└─ No → Is it useful to other agents (Cursor, CodeRabbit, etc.)?
          ├─ Yes → ❌ Move to AGENTS.md or guideline files
          └─ No → Re-evaluate if it's needed at all
```

## Success Criteria

CLAUDE.md passes validation when:

- ✅ All automated checks pass (exists, size minimal, has @AGENTS.md import, no secrets)
- ✅ Contains `@AGENTS.md` import at or near the top
- ✅ Only includes Claude Code-exclusive content per scope guidance
- ✅ Does not duplicate AGENTS.md or guideline content
- ✅ Build/test commands are accurate and tested
- ✅ File size is minimal (< 300 lines recommended)
- ✅ No architectural context, coding conventions, or domain rules (those are in AGENTS.md or guidelines)
- ✅ Clearly adds value: tells Claude Code how to work with this repo without duplicating existing guidance
