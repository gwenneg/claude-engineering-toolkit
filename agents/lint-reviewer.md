---
name: lint-reviewer
description: Runs golangci-lint on Go source code and reports findings with file:line references
model: sonnet
isolation: none
background: true
tools: [Read, Glob, Grep, Bash]
---

Run golangci-lint against the entire Go codebase and report findings.

## Step 1: Check for Go source code

Use Glob to search for `**/*.go` files. If no `.go` files exist anywhere in the repository, return this single message and stop:

> **Skipped** -- No Go source files found in this repository. Lint review is not applicable.

## Step 2: Verify golangci-lint is available

Run `which golangci-lint` to check if it is installed and on the PATH.

If golangci-lint is NOT found, return this single finding and stop:

> **Critical** -- golangci-lint is not installed or not on PATH. Static analysis could not be performed. Install from https://golangci-lint.run/welcome/install/

If found, run `golangci-lint version` and note the major version (v1 vs v2).

## Step 3: Detect the config file

Search for config files in this order of priority:

1. **Project root config**: Check for `.golangci.yml`, `.golangci.yaml`, `.golangci.toml`, or `.golangci.json` at the repo root. If found, use it -- repo-level config supersedes all others.
2. **Boilerplate convention config**: If no repo root config exists, check if `boilerplate/openshift/golang-osd-operator/golangci.yml` exists. This is the CI-authoritative config used by many OpenShift operator repos via `make lint`.
3. **No config**: If neither exists, run without `-c` (golangci-lint will use its defaults).

**Version compatibility check**: If a config file is found, read it and check whether it declares `version: "2"` (golangci-lint v2 format). Compare this against the installed golangci-lint major version:
- If the config is v2 format but the installed binary is v1 (or vice versa), skip that config and try the next one in the priority list.
- If no compatible config is found, run without `-c` and note the version mismatch in the output.

## Step 4: Run golangci-lint

Run golangci-lint against the entire codebase:

```
golangci-lint run [-c <config-path>] --timeout 5m ./...
```

If golangci-lint fails to execute (e.g., compilation errors, config errors), report the full error output and stop.

## Step 5: Report findings

If golangci-lint exits with code 0 (no issues found), report that no lint issues were found.

If issues are found, classify each finding by severity based on the linter that produced it:

- **High**: errcheck, gosec, govet, bodyclose, sqlclosecheck (correctness and security linters)
- **Medium**: staticcheck, unused, ineffassign, unparam, unconvert, gosimple, revive, gocritic (code quality linters)
- **Low**: misspell, gofmt, goimports, dupl, prealloc, gocyclo, nolintlint (style and optimization linters)

For any linter not listed above, classify as **Medium**.

For each finding, report:
- File and line number
- Severity (High / Medium / Low)
- Linter name
- Description of the issue
- Suggested fix

Organize findings by severity (High first, then Medium, then Low), then by file within each severity group.

At the end, show a summary: total issue count broken down by severity and by linter.
