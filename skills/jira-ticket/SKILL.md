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
   - The description MUST end with an **Acceptance Criteria** section containing a bullet points list of conditions that must be met for this to be considered done.
3. Set the **Activity Type** (`customfield_10464`) to the most appropriate value from this list:
   - Associate Wellness & Development
   - Future Sustainability
   - Incidents & Support
   - Quality / Stability / Reliability
   - Security & Compliance
   - Product / Portfolio Work
4. Set the issue type based on the nature of the request:
   - **Epic**: Large topics that encompass multiple changes or a broad initiative.
   - **Story**: Individual, well-defined changes or units of work.
   - **Spike**: Research tasks where the solution isn't immediately obvious and investigation is needed.
5. Always add the `Fabric Notifications` component to the ticket (use the standard `components` field).
6. Add a quarterly label in the format `ConsoleDot_CY{YY}Q{N}` (e.g. `ConsoleDot_CY26Q1`). Default to the current year and quarter based on today's date. Ask the user to confirm before creating the ticket.
7. Set priority based on impact and urgency.
8. Always create tickets under the **RHCLOUD** project.
9. Before creating the ticket, ask the user if it should be restricted to "Red Hat Employee" only (not public). If yes, set the `security` field to restrict access to Red Hat employees.
10. Before creating the ticket, ask the user if it should be linked to another ticket — either as a parent (set the parent field when creating the ticket) or as a standard link (create the link after the ticket is created).
11. Ask the user if the ticket should be assigned to someone specific. If yes, set the assignee when creating the ticket.
12. Ask the user if a second ticket should be created for QE testing of the first ticket. If yes, create it with the same project, component, labels, and priority, link it to the first ticket, and prefix its summary with "[QE]".
13. If the request references code, search the codebase for context and include relevant file paths and line numbers in the description.

Whenever you need to ask the user a question, always use the AskUserQuestion tool — never ask as plain text.

Use the Jira MCP tools to create the ticket. Return the ticket key and URL when done.
