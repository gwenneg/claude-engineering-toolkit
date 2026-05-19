# /improve-docs

Processes captured friction events and turns them into documentation improvements, committed as a PR. Also checks whether the friction capture toolkit is up to date.

## Prerequisites

Run `/setup-friction-capture` once in the repo before using this skill.

## What it does

1. **Health check** — verifies the capture script and skill are installed; warns if either is missing
2. **Version check** — compares the installed toolkit version against the latest GitHub release; prints a notice if an update is available, then continues
3. **Processes friction** — reads `.claude/friction/*.md` files written by `capture-friction.sh`
4. **Improves docs** — proposes targeted edits to guideline files based on friction patterns
5. **Proposes evals** — adds test cases to `promptfoo.yaml` (or equivalent) for grader-friendly events
6. **Opens a PR** — commits all changes and posts a metrics summary as a PR comment

If no friction files are found, it stops after the version check.

## How friction files get there

At the end of every Claude Code session, the `SessionEnd` hook runs `capture-friction.sh`. If `FRICTION_CAPTURE=1` is set in the user's local environment, the script asks a small LLM to scan the session transcript for friction events (corrections, mistakes, clarifications, denied tool calls) and writes one markdown file per event to `.claude/friction/`.

These files accumulate until `/improve-docs` is run.

## Discovered documentation structure

The skill adapts to whatever documentation structure the repo uses. It looks for guideline files in `docs/`, `.claude/rules/`, and root-level agent context files (`AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`). No specific structure is required.

## Version notices

If a newer toolkit version is available, `/improve-docs` prints:

```
Notice: a newer version of the friction capture toolkit is available.
  Installed: v1.0.0 → Latest: v1.1.0
  Re-run /setup-friction-capture to update.
```

The check is best-effort — it is skipped silently if the GitHub API is unreachable.

## Quick start

```
> /improve-docs
```
