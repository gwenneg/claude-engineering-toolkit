# Domain Guideline Validation Checklist

## Overview

Domain guideline files (`docs/*-guidelines.md`) contain detailed, repo-specific rules for specific domains (security, testing, database, etc.). This checklist ensures they meet quality standards and are accurate.

## Automated Checks

Run these checks programmatically before agent review:

- [ ] **File size**: < 200 lines (hard constraint)
  ```bash
  wc -l docs/<domain>-guidelines.md
  ```
- [ ] **Naming convention**: Follows `docs/*-guidelines.md` pattern
- [ ] **No hardcoded secrets**: No API keys, passwords, tokens, or credentials
  ```bash
  grep -iE "(api_key|password|secret|token|credential)" docs/<domain>-guidelines.md
  ```
- [ ] **Correct location**: File is in `docs/` directory

## Content Quality Checks

These require agent review:

### 1. Reference Accuracy

Check every file path, class name, function name, and library reference mentioned in the guideline against the actual codebase using Grep and Glob.

- [ ] All file paths exist in the repository
- [ ] All class names can be found in the codebase
- [ ] All function names are present
- [ ] All library references are in dependencies

**Flag**: Any claim that cannot be confirmed (e.g., a file that doesn't exist, a pattern that isn't used, a library that isn't in the dependencies)

### 2. Factual Claims About Libraries/Frameworks

Verify any claim about default values, behaviors, or semantics of external libraries and frameworks.

- [ ] Default values are accurate (e.g., "the default is unbounded")
- [ ] Framework behaviors are correct (e.g., "this annotation requires X")
- [ ] Library semantics are properly described

**Method**: Use WebSearch to check official documentation when needed. Remove or correct any claim that is inaccurate.

### 3. Absolute Rules vs Existing Code

For every rule using absolute language ("Never", "Always", "Must", "All"), grep the codebase for counter-examples.

- [ ] "Always" rules have no violations in the codebase
- [ ] "Never" rules have no counter-examples
- [ ] "Must" requirements are consistently followed
- [ ] "All" statements are universally true

**Action**: If existing code violates the rule, either:
- Soften the language to "Prefer" / "Avoid" with known exceptions listed
- Scope the rule to specific contexts (e.g., "for new code" or "in module X")

### 4. Cross-Document Consistency

Compare the guideline against all other domain guidelines to detect contradictory advice.

- [ ] No contradictions with other guideline files
- [ ] No duplicate rules across multiple files
- [ ] Conflicting claims are reconciled

**Resolution**: If two guidelines make conflicting claims, flag the conflict and reconcile by choosing the more specific or authoritative rule.

### 5. Repo-Specific Focus

Focus on repo-specific conventions and patterns, not general domain knowledge.

- [ ] Rules describe how THIS repo does things, not general best practices
- [ ] No explanations of general concepts (e.g., what SQL injection is)
- [ ] Examples are from the actual codebase
- [ ] Patterns are specific to this project

**Example**:
- ❌ Bad: "SQL injection is when untrusted data is sent to an interpreter..."
- ✅ Good: "This repo validates all user input in `middleware/validator.ts` using the `validateSchema()` function"

### 6. Conciseness and Actionability

Write concise, actionable rules — not explanations or tutorials.

- [ ] Rules are direct and actionable
- [ ] No tutorial-like explanations
- [ ] Each rule has a clear action
- [ ] Content stays under 200 lines

**Keep**: Concrete rules agents can follow  
**Remove**: Background explanations, theory, tutorials

### 7. Non-Obvious Conventions Only

Only document conventions that an agent couldn't infer from reading a single file.

- [ ] Each rule covers cross-cutting concerns or hidden patterns
- [ ] No documentation of obvious patterns visible in code
- [ ] Rules provide context not available in individual files

## Common Mistakes to Avoid

| Mistake | Why It's Wrong | Correct Approach |
|---------|----------------|------------------|
| ❌ Explaining what SQL injection is | General knowledge, not repo-specific | Describe how THIS repo validates input |
| ❌ Rules longer than 200 lines | Violates hard constraint | Keep concise, remove explanations |
| ❌ Referencing `utils/helper.ts` that doesn't exist | Breaks agent trust | Verify all references with Grep/Glob |
| ❌ "Always use X" when repo has counter-examples | Rule is violated | Soften to "Prefer X" or scope to "for new code" |
| ❌ Duplicating rules across files | Maintenance burden, confusion | Keep each rule in one canonical file |
| ❌ Tutorial-style: "First understand that..." | Not actionable | Direct rule: "Validate input using validateSchema()" |
| ❌ Documenting obvious patterns | Wastes context | Only non-obvious, cross-cutting conventions |

## Validation Commands

```bash
# Check file size
wc -l docs/security-guidelines.md
# Expected: < 200 lines

# Check for secrets
grep -iE "(api_key|password|secret|token|credential)" docs/security-guidelines.md
# Expected: no matches

# Verify file references exist
# Extract file paths from guideline and check each one
grep -oE "[a-zA-Z0-9_/-]+\.(ts|js|py|java|go|md)" docs/security-guidelines.md | while read file; do
  if [ ! -f "$file" ]; then
    echo "Missing: $file"
  fi
done

# Check for absolute language that may need softening
grep -E "(Always|Never|Must|All) " docs/security-guidelines.md
# Review each match for counter-examples in codebase
```

## Verification Agent Instructions

When verifying a guideline file:

1. Read `docs/<domain>-guidelines.md` for your assigned domain
2. Read ALL other `docs/*-guidelines.md` files for cross-document checks
3. Run automated checks above
4. Perform all content quality checks (1-7)
5. Flag violations with specific line numbers and examples
6. Return corrected content (do NOT write files)
7. Do NOT add new content — only confirm or correct existing content

## Success Criteria

A guideline file passes validation when:

- ✅ All automated checks pass (size, naming, no secrets, correct location)
- ✅ All references are verified accurate (files, classes, functions exist)
- ✅ All library/framework claims are factually correct
- ✅ Absolute rules have no counter-examples (or are properly scoped)
- ✅ No contradictions with other guidelines
- ✅ Content is repo-specific, not general knowledge
- ✅ Rules are concise and actionable
- ✅ Only documents non-obvious conventions
