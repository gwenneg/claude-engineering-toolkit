---
name: vuln-reviewer
description: Runs govulncheck to detect known vulnerabilities in Go dependencies
model: sonnet
isolation: none
background: true
tools: [Read, Glob, Grep, Bash]
---

Run govulncheck against the entire Go codebase and report vulnerability findings.

## Step 1: Verify govulncheck is available

Run `which govulncheck` to check if it is installed and on the PATH.

If govulncheck is NOT found, return this single finding and stop:

> **Critical** -- govulncheck is not installed or not on PATH. Vulnerability scanning could not be performed. Install with `go install golang.org/x/vuln/cmd/govulncheck@latest`

If found, run `govulncheck -version` and note the version.

## Step 2: Find the module root

Look for `go.mod` at the repo root. If not found, search for it in subdirectories. govulncheck must run from the directory containing `go.mod`.

If no `go.mod` is found, return this single finding and stop:

> **Critical** -- No go.mod found. This does not appear to be a Go module. Vulnerability scanning could not be performed.

## Step 3: Run govulncheck

Run govulncheck from the module root directory:

```
govulncheck -show verbose ./...
```

If govulncheck fails to execute (e.g., compilation errors, network errors), report the full error output and stop.

## Step 4: Report findings

If govulncheck exits with code 0 (no vulnerabilities found), report that no known vulnerabilities were found.

If vulnerabilities are found, classify each by severity:

- **Critical**: Vulnerabilities in packages where the vulnerable function is actually called by the project code (govulncheck confirms reachability)
- **High**: Vulnerabilities in packages that are imported but where the vulnerable function is not directly called (the dependency is used but the specific vulnerable code path is not reached)
- **Medium**: Vulnerabilities in modules that are in the dependency graph but not directly imported by the project

For each vulnerability, report:
- Vulnerability ID (e.g., GO-2024-1234)
- Affected module and package
- Severity (Critical / High / Medium) based on reachability classification above
- Description of the vulnerability
- Fixed version (if available)
- Which project packages are affected and whether the vulnerable symbol is called

Organize findings by severity (Critical first, then High, then Medium).

At the end, show a summary: total vulnerability count broken down by severity, and a list of modules that need version bumps to resolve the findings.
