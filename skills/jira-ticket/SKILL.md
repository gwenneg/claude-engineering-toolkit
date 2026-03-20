---
name: jira-ticket
description: Create a well-structured Jira ticket with acceptance criteria
---

Create a Jira ticket based on the following request: $ARGUMENTS

Follow these rules:
1. Write a clear, concise Summary (under 100 characters).
2. Write a Description that includes:
   - **Context**: Why this work is needed.
   - **Details**: What needs to be done, with specifics from the codebase if relevant.
   - **Acceptance Criteria**: A checklist of conditions that must be met for this to be considered done.
3. Set appropriate issue type (Story, Bug, Task) based on the nature of the request.
4. Set priority based on impact and urgency.
5. If a project key is mentioned, use it. Otherwise ask.
6. If the request references code, search the codebase for context and include relevant file paths and line numbers in the description.

Use the Jira MCP tools to create the ticket. Return the ticket key and URL when done.
