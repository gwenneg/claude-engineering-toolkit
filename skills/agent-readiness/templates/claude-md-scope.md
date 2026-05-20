# CLAUDE.md Scope Guide

## What Belongs in CLAUDE.md

CLAUDE.md must NOT duplicate or restate anything already in AGENTS.md or `docs/*-guidelines.md`. Since `@AGENTS.md` imports all that guidance, repeating it creates redundancy.

### ✅ Belongs in CLAUDE.md (Claude Code-exclusive)

- `@AGENTS.md` import
- Build/test/lint commands Claude Code should run (e.g., `mvn verify`, `npm test`)
- Pre-commit hook behavior or CI checks Claude should be aware of
- Claude Code-specific behavioral preferences (e.g., "always run tests before suggesting a PR")

### ❌ Does NOT belong in CLAUDE.md (put in AGENTS.md instead)

- Coding conventions, naming patterns, code style
- Architectural context, project structure
- Domain-specific rules (these go in `docs/*-guidelines.md`)
- Any guidance that would be useful to Cursor, CodeRabbit, or other AI tools
