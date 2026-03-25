---
name: my-work
description: Show a prioritized dashboard of Jira tickets, GitHub PRs/reviews, and Google Tasks
---

Show a prioritized view of all my current work across Jira, GitHub, and Google Tasks. $ARGUMENTS

Follow these steps:

## 1. Gather data in parallel

Fetch data from all three sources simultaneously.

### Jira
Use the `mcp__rh-jira__jira_search` MCP tool to find all tickets assigned to the current user that are NOT in a "Done" or "Closed" status. Retrieve: ticket key, summary, status, priority, and issue type.

### GitHub
Use the `mcp__github__get_me` MCP tool to get the current user's GitHub username. Then use `mcp__github__search_pull_requests` to find open PRs awaiting review (query: `is:open is:pr review-requested:<username>`).

### Google Tasks
Use the Bash tool. Capture the access token in a shell variable and use it in the same Bash command as the curl calls. IMPORTANT: Never run `gcloud auth application-default print-access-token` as a standalone command — always combine it with curl to avoid logging the token in the output.
```
TOKEN=$(gcloud auth application-default print-access-token 2>/dev/null) && curl -s -H "Authorization: Bearer $TOKEN" ...
```
- Fetch all task lists: `GET https://tasks.googleapis.com/tasks/v1/users/@me/lists`
- For each task list, fetch incomplete tasks: `GET https://tasks.googleapis.com/tasks/v1/lists/{listId}/tasks?showCompleted=false`

## 2. Display the results

Present three tables:

### Jira Tickets
| Priority | Key | Summary | Status | Type |
|----------|-----|---------|--------|------|

Sort by priority (Blocker > Critical > Major > Minor > Trivial), then by status (In Progress first, then To Do, then others).

### GitHub Review Requests
| Repo | PR | Title | Draft |
|------|----|-------|-------|

Sort: non-draft PRs first, then draft PRs.

### Google Tasks
| Due Date | Task | List |
|----------|------|------|

Sort by due date (soonest first, then tasks with no due date).

## 3. Suggest priorities

After showing the tables, provide a short prioritized recommendation of what to focus on next, considering:
- Blocker/Critical Jira tickets in progress
- Review requests (unblock others first)
- Overdue Google Tasks
- Remaining Jira work by priority
