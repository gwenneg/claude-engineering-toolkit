---
name: implement
description: Implement a feature based on a Jira ticket, with ticket quality and guideline validation
---

Implement the feature described in the following Jira ticket: $ARGUMENTS

## Step 1: Fetch the Jira ticket

Use the Jira MCP tools to fetch the ticket details (summary, description, acceptance criteria, comments, linked issues). Make sure to request the `customfield_10718` field, which is the dedicated "Acceptance Criteria" field. If the ticket key is invalid or cannot be found, tell the user and stop.

## Step 2: Validate ticket quality

Check that the ticket description contains ALL of the following sections. Sections may use heading markers (##, **bold**, or similar formatting) or be clearly identifiable blocks of text:

1. **Context / Background** — an explanation of why this work is needed, what problem it solves, or what business goal it serves.
2. **Technical Details** — implementation hints, constraints, API references, affected components, or other specifics that guide the implementation.
3. **Acceptance Criteria** — a bullet list of conditions that must be met for the work to be considered done. This may be in the description OR in the dedicated custom field `customfield_10718`. Check both locations.

If any section is missing:

- List exactly which sections are missing.
- Recommend that the user update the Jira ticket before proceeding.
- Explain that implementing without these sections risks producing code that doesn't match expectations.
- Ask the user whether they want to stop and improve the ticket, or bypass the recommendation and proceed anyway.
- If the user chooses to bypass, acknowledge the risk and continue. Clearly note in your output which sections were missing so there is a record.

## Step 3: Load service guidelines

Glob for `docs/*-guidelines.md` and read every file that matches. These files contain repo-specific conventions, patterns, and constraints that must inform the implementation plan and the code you write.

If no files match the glob:

- Tell the user that no guideline files were found under `docs/*-guidelines.md`.
- Explain that these files help produce implementations that follow repo-specific conventions. They can be generated with the `/agent-readiness` skill.
- Ask the user whether they want to stop and create them, or proceed without them.

## Step 4: Plan the implementation

Based on the ticket description, acceptance criteria, and service documentation (if available), create an implementation plan:

1. Identify which files need to be created or modified.
2. Break the work into discrete, logical steps.
3. Call out any ambiguities or assumptions you're making.
4. Present the plan to the user and ask for confirmation before writing any code.

## Step 5: Implement the feature

Execute the plan step by step:

- Write clean, idiomatic code that follows the patterns and conventions already present in the codebase.
- Follow the architecture and conventions described in the guideline files (if available).
- Satisfy every item in the Acceptance Criteria checklist.
- Include tests for the new functionality.
- Do not refactor or modify code outside the scope of the ticket.

## Step 6: Verify acceptance criteria

After implementation, go through each acceptance criteria item from the ticket and confirm whether it has been met. Present a checklist to the user:

- [x] Criteria that are satisfied
- [ ] Criteria that are NOT satisfied (with explanation)

If any criteria are not met, ask the user whether to continue working on them or stop here.

## Rules

- Always fetch the ticket fresh via MCP — do not ask the user to paste the ticket contents.
- Never skip the ticket quality or guideline validation steps. The user must explicitly choose to bypass them.
- When the user bypasses a recommendation, do not repeatedly warn them. Acknowledge once and move on.
- Keep implementation focused on the ticket scope. Do not add features, refactoring, or improvements beyond what the ticket asks for.
- If the ticket references other tickets or links, read them for additional context but do not implement their scope.
- Never push code, open PRs, merge branches, or perform any action visible to others. The skill's scope ends at local implementation.
- If the user bypassed the ticket quality check and no Acceptance Criteria exist, do NOT invent your own criteria in Step 6. Instead, state that verification is not possible without acceptance criteria and ask the user to define what "done" looks like.
- If the implementation plan touches shared infrastructure (CI/CD pipelines, database migrations, shared libraries, deployment configs), explicitly flag this to the user and get confirmation before proceeding.
