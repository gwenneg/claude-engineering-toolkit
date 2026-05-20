# README.md Validation Checklist

## Overview

README.md is the front door of the repository — high-level project context for both humans and AI agents. It helps agents understand what the project is, how it's structured, and how to build and run it before diving into code.

## Automated Checks

Run these checks programmatically:

- [ ] **File exists**: `README.md` is present at repo root
- [ ] **File not empty**: Has actual content (> 100 chars)
  ```bash
  wc -c README.md
  ```
- [ ] **Has headers**: Contains markdown section headers
  ```bash
  grep "^##\? " README.md
  ```
- [ ] **No hardcoded secrets**: No API keys, passwords, tokens, or credentials
  ```bash
  grep -iE "(api_key|password|secret|token|credential)" README.md
  ```

## Content Quality Checks

These require agent review:

### 1. Project Purpose and Description

README should clearly explain what the project is and why it exists.

- [ ] Project name is clear
- [ ] Purpose is explained (what problem it solves)
- [ ] Target audience is identifiable (who uses this)
- [ ] Brief description of key features or capabilities

**Example**:
- ✅ Good: "A Claude Code plugin that provides specialized review agents and engineering skills for thorough, parallel code reviews..."
- ❌ Bad: "This is a project that does things."

### 2. Tech Stack and Key Dependencies

List the main technologies, languages, and frameworks.

- [ ] Programming languages mentioned
- [ ] Major frameworks or libraries listed
- [ ] Runtime requirements (Node.js version, Python version, etc.)
- [ ] External services or APIs if applicable

**Helps agents**: Understand the ecosystem before reading code.

### 3. Project Structure Overview

Explain how the codebase is organized.

- [ ] Directory structure overview
- [ ] Main components or modules
- [ ] Where to find specific types of files

**Example**:
```markdown
## Project Structure

```
skills/          # User-invocable commands
agents/          # Specialized review agents
templates/       # Reusable templates
docs/            # Documentation
```
```

### 4. How to Build and Run

Clear instructions for getting started.

- [ ] Installation steps (dependencies, setup)
- [ ] Build commands
- [ ] How to run the project
- [ ] How to run tests (if applicable)

**Critical**: These instructions should actually work. Verify them.

### 5. Links to Further Documentation

Point to other documentation for deeper dives.

- [ ] Links to AGENTS.md (if it exists)
- [ ] Links to CONTRIBUTING.md (if it exists)
- [ ] Links to docs/ directory or specific documentation files
- [ ] Links to external resources (API docs, related projects)

**Helps agents**: Know where to find detailed information.

### 6. High-Level Context

README should provide overview context, not detailed conventions.

- [ ] Suitable for both humans and agents
- [ ] High-level enough to be a "front door"
- [ ] Not duplicating detailed conventions from AGENTS.md or guideline files

**Keep**: Overview, getting started, project structure  
**Avoid**: Detailed coding conventions (those go in AGENTS.md)

## Common Mistakes to Avoid

| Mistake | Why It's Wrong | Correct Approach |
|---------|----------------|------------------|
| ❌ Empty or placeholder README | Agents have no starting context | Write actual project overview |
| ❌ Duplicating detailed conventions from AGENTS.md | Maintenance burden, wrong audience | Link to AGENTS.md, keep README high-level |
| ❌ Missing build instructions | Can't get started | Add clear installation and build steps |
| ❌ No links to other documentation | Agents don't know where to find details | Link to AGENTS.md, CONTRIBUTING.md, docs/ |
| ❌ Just a title, no description | Unhelpful | Explain what the project does and why |
| ❌ Thousands of lines of detailed API docs | Wrong place, too much | Keep it high-level, link to detailed docs |

## Validation Commands

```bash
# Check file exists and has content
ls -lh README.md
# Expected: exists and > 1KB typically

# Check for common sections
echo "=== Checking for recommended sections ==="
grep -i "## install\|## build\|## getting started\|## usage" README.md && echo "✅ Has getting started info" || echo "⚠️  Missing getting started section"

grep -i "## structure\|## organization\|## directory" README.md && echo "✅ Has structure info" || echo "⚠️  Missing structure section"

grep -i "## test\|## testing" README.md && echo "✅ Has testing info" || echo "⚠️  Consider adding testing info"

# Check for links to other docs
grep -E "\[.*\]\(AGENTS\.md\)|\[.*\]\(CONTRIBUTING\.md\)|\[.*\]\(docs/" README.md && echo "✅ Links to other docs" || echo "⚠️  Consider linking to detailed docs"

# Check for secrets
grep -iE "(api_key|password|secret|token|credential)" README.md
# Expected: no matches (or only in safe contexts like "how to set API_KEY env var")
```

## Structure Recommendations

A well-structured README typically includes:

```markdown
# Project Name

Brief description (1-3 sentences) of what this project is and does.

## Features

- Key feature 1
- Key feature 2
- Key feature 3

## Tech Stack

- Language/runtime
- Major frameworks
- Key dependencies

## Installation

```bash
# Installation commands
```

## Getting Started

```bash
# How to build and run
```

## Project Structure

```
directory/       # Description
another-dir/     # Description
```

## Usage

Basic usage examples or common commands

## Documentation

- [AGENTS.md](AGENTS.md) - AI agent guidance
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/](docs/) - Detailed documentation

## Testing

```bash
# How to run tests
```

## License

License information
```

## Success Criteria

README.md passes validation when:

- ✅ All automated checks pass (exists, not empty, has headers, no secrets)
- ✅ Clearly explains project purpose and description
- ✅ Lists tech stack and key dependencies
- ✅ Includes project structure overview
- ✅ Provides clear build and run instructions (that actually work)
- ✅ Links to further documentation (AGENTS.md, CONTRIBUTING.md, docs/)
- ✅ High-level context suitable for both humans and agents
- ✅ Doesn't duplicate detailed conventions from AGENTS.md
- ✅ Serves as an effective "front door" to the project
