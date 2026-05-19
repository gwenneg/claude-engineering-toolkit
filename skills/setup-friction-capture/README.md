# /setup-friction-capture

Bootstraps the friction capture and documentation improvement loop in a shared repository. Run once to set up, re-run to update.

## What it does

1. Fetches the latest release of the toolkit from GitHub
2. Installs `.claude/scripts/capture-friction.sh` and `.claude/skills/improve-docs/SKILL.md` into the repo
3. Wires a `SessionEnd` hook in `.claude/settings.json` so capture runs automatically at the end of every Claude Code session
4. Updates `.gitignore` to keep friction files local
5. Opens a PR with all committed changes
6. Optionally enables friction capture for you personally (`FRICTION_CAPTURE=1` in your local settings)

## What ends up in the repo

```
.claude/
  scripts/
    capture-friction.sh        ← runs at session end, writes friction events
  skills/
    improve-docs/
      SKILL.md                 ← /improve-docs skill, available to all team members
  .friction-capture-version    ← records the installed toolkit version
  settings.json                ← SessionEnd hook (merged, existing content preserved)
.gitignore                     ← .claude/friction/ added
```

## What stays local (never committed)

Each team member who wants to participate adds this to their `.claude/settings.local.json`:

```json
{
  "env": {
    "FRICTION_CAPTURE": "1"
  }
}
```

Without this, the hook fires but exits immediately — so it is safe to install team-wide without forcing everyone to participate.

## Updating

Re-run `/setup-friction-capture` at any time. It fetches the latest release and opens an update PR. `/improve-docs` will also notify you when a newer version is available.

## Quick start

```
claude --plugin-dir /path/to/claude-engineering-toolkit
> /setup-friction-capture
```
