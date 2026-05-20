# AI-Assisted Development Documentation System

This skill helps you build a layered documentation system for AI-assisted development. Each file has a distinct role:

## File Responsibilities

### `docs/*-guidelines.md`
Detailed, domain-specific playbooks (security, testing, database, etc.) with concrete rules agents follow.

### `AGENTS.md`
The onboarding doc for any AI agent: cross-cutting conventions + an index pointing to the guideline files.

### `CLAUDE.md`
A thin, Claude Code-specific layer that imports AGENTS.md and adds Claude-only behavior (build commands, etc.).

### `.coderabbit.yaml`
Points CodeRabbit (AI code reviewer) to the guideline files so it enforces your conventions during PR reviews.

### `README.md`
The front door: high-level project context for humans and agents alike.

### `CONTRIBUTING.md`
Contribution conventions for both humans and agents.

### `docs/ARCHITECTURE.md`
Institutional knowledge about the system's design and key architectural decisions.

## Progressive Disclosure

The system is designed for efficient context usage:
1. README.md provides high-level overview
2. AGENTS.md gives cross-cutting conventions and points to detailed docs
3. Domain-specific guidelines provide deep, focused guidance when needed
