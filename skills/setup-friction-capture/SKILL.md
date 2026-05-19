# Setup Friction Capture

Bootstrap the friction capture and documentation improvement loop in a shared repository.

Run this skill once to set up a repo. Re-run it at any time to update to the latest toolkit version.

## Instructions

### 1. Get the latest release tag

```bash
curl -fsSL https://api.github.com/repos/gwenneg/claude-engineering-toolkit/releases/latest \
  | jq -r '.tag_name'
```

If the API call fails, stop and report the error. Use the returned tag (e.g. `v1.2.0`) in all subsequent steps.

### 2. Install the capture script

```bash
mkdir -p .claude/scripts
curl -fsSL "https://raw.githubusercontent.com/gwenneg/claude-engineering-toolkit/{TAG}/scripts/capture-friction.sh" \
  -o .claude/scripts/capture-friction.sh
chmod +x .claude/scripts/capture-friction.sh
```

### 3. Install the improve-docs skill

```bash
mkdir -p .claude/skills/improve-docs
curl -fsSL "https://raw.githubusercontent.com/gwenneg/claude-engineering-toolkit/{TAG}/skills/improve-docs/SKILL.md" \
  -o .claude/skills/improve-docs/SKILL.md
```

### 4. Record the installed version

```bash
echo "{TAG}" > .claude/.friction-capture-version
```

### 5. Configure the SessionEnd hook

Read `.claude/settings.json` if it exists. Check whether a SessionEnd hook already calls `capture-friction.sh`. If not, add it.

The hook entry to add:
```json
{
  "matcher": "",
  "hooks": [
    {
      "type": "command",
      "command": "bash .claude/scripts/capture-friction.sh",
      "timeout": 5000
    }
  ]
}
```

Use `jq` to merge this into the existing `hooks.SessionEnd` array, preserving all other content. If `.claude/settings.json` does not exist, create it with just the hooks block.

### 6. Install the pre-push git hook

```bash
mkdir -p .githooks
curl -fsSL "https://raw.githubusercontent.com/gwenneg/claude-engineering-toolkit/{TAG}/scripts/pre-push" \
  -o .githooks/pre-push
chmod +x .githooks/pre-push
```

This hook reminds contributors to run `/improve-docs` when friction files have been accumulating.

Then wire git to use `.githooks/` for the current clone:

```bash
git config core.hooksPath .githooks
```

This git config is local and not committed — every team member must run it once after cloning. Include this instruction in the PR body (step 7).

### 7. Update .gitignore

The `.claude/` directory contains a mix of files that should be committed (scripts, skills, settings, version file) and files that must stay local (friction events, local settings, lock files, logs). Use an allowlist pattern to make this explicit.

Check whether `.gitignore` already contains `/.claude/*`. If not, append this block:

```
/.claude/*
!/.claude/scripts/
!/.claude/skills/
!/.claude/settings.json
!/.claude/.friction-capture-version
```

If `/.claude/*` is already present, ensure each negation line above exists individually, adding any that are missing. Never duplicate existing entries.

### 7. Commit and open a PR

Stage these files:
- `.claude/scripts/capture-friction.sh`
- `.claude/skills/improve-docs/SKILL.md`
- `.claude/.friction-capture-version`
- `.claude/settings.json`
- `.githooks/pre-push`
- `.gitignore`

Create a branch named `chore/setup-friction-capture` (add `-2`, `-3`, etc. if it already exists).

Commit with message: `chore: set up friction capture ({TAG})`

Push the branch and open a PR:
- Title: `chore: set up friction capture ({TAG})`
- Body: describe what was added and include this note for reviewers:

  > **For each team member after this PR is merged:**
  > 1. Run `git config core.hooksPath .githooks` once in your clone to activate the pre-push reminder hook.
  > 2. To opt in to friction capture, add `FRICTION_CAPTURE=1` to your `.claude/settings.local.json` (not committed, stays local).

- Base branch: `main`

### 8. Offer personal opt-in

After the PR is created, ask:

> Friction capture is now set up for the team. To opt in yourself, I can add `FRICTION_CAPTURE=1` to your `.claude/settings.local.json` (this file is never committed). Would you like me to do that?

If yes: ensure `.claude/settings.local.json` has `FRICTION_CAPTURE` set to `"1"` in its `env` block. Create the file if it doesn't exist; merge the key if it does.
