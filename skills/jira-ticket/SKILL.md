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
3. Write **Acceptance Criteria** as a bullet-point list of conditions that must be met for the work to be considered done. Set this in the dedicated custom field `customfield_10718` (not in the description).
4. Set the **Activity Type** (`customfield_10464`) to the most appropriate value from this list:
   - Associate Wellness & Development
   - Future Sustainability
   - Incidents & Support
   - Quality / Stability / Reliability
   - Security & Compliance
   - Product / Portfolio Work
5. Set the issue type based on the nature of the request:
   - **Epic**: Large topics that encompass multiple changes or a broad initiative.
   - **Story**: Individual, well-defined changes or units of work.
   - **Spike**: Research tasks where the solution isn't immediately obvious and investigation is needed.
6. Set the `components` field to the most relevant value from this list based on the ticket details:
   - Export
   - Ingress
   - Notifications
   - Payload-tracker
   - Scheduler
   - Sources
   - Storage Broker
7. Always set the **Team** field (`customfield_10001`) to `Fabric - Notifications` (team ID: `ecb47ac2-c7a6-4bd8-8d76-f23906f83e25`).
8. Always add the `platform-integrations` label.
9. Set priority based on impact and urgency.
10. Always create tickets under the **RHCLOUD** project.
11. Set the **Target Version** (`customfield_10855`). Fetch the available versions for the RHCLOUD project, filter to only unreleased and non-archived versions. Default to the version matching the current quarter (e.g., "ConsoleDot CY26Q2" for Q2 2026). Present this default to the user and let them confirm or pick a different one.
12. Before creating the ticket, ask the user if it should be restricted to "Red Hat Employee" only (not public). If yes, set the `security` field to restrict access to Red Hat employees.
13. Before creating the ticket, ask the user if it should be linked to another ticket — either as a parent (set the parent field when creating the ticket) or as a standard link (create the link after the ticket is created).
14. Ask the user if the ticket should be assigned to someone specific. If yes, set the assignee when creating the ticket.
15. Ask the user if a second ticket should be created for QE testing of the first ticket. If yes, create it with the same project, component, labels, and priority, link it to the first ticket, and prefix its summary with "[QE]".
16. If the request references code, search the codebase for context and include relevant file paths and line numbers in the description.

Before creating the ticket, present a full preview of all fields (summary, description, acceptance criteria, issue type, components, activity type, priority, labels, target version, security, assignee, and any links) to the user and ask for explicit approval. Do NOT create the ticket until the user confirms. If the user requests changes, update the preview and ask again.

Whenever you need to ask the user a question, always use the AskUserQuestion tool — never ask as plain text.

Use the Jira MCP tools to create the ticket. Return the ticket key and URL when done. Always format the URL as `https://redhat.atlassian.net/browse/<TICKET_KEY>`.
