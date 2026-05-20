#!/bin/bash
# Automated validation checks for agent-readiness generated files

set -e

REPO_ROOT=${1:-.}
ERRORS=0

echo "Running automated validation checks..."
echo ""

# Function to check file size
check_file_size() {
    local file=$1
    local max_lines=$2
    local actual_lines=$(wc -l < "$file" 2>/dev/null || echo "0")

    if [ "$actual_lines" -gt "$max_lines" ]; then
        echo "❌ $file: $actual_lines lines (max: $max_lines)"
        ((ERRORS++))
    else
        echo "✅ $file: $actual_lines lines (within limit)"
    fi
}

# Function to check for secrets
check_secrets() {
    local file=$1
    local matches=$(grep -iE "(api_key|password|secret|token|credential)" "$file" 2>/dev/null || true)

    if [ -n "$matches" ]; then
        echo "⚠️  $file: Possible secrets detected"
        echo "$matches"
        ((ERRORS++))
    else
        echo "✅ $file: No secrets detected"
    fi
}

# Function to check file exists
check_exists() {
    local file=$1
    if [ -f "$file" ]; then
        echo "✅ $file: exists"
        return 0
    else
        echo "❌ $file: not found"
        ((ERRORS++))
        return 1
    fi
}

# Check AGENTS.md
echo "=== AGENTS.md ==="
if check_exists "$REPO_ROOT/AGENTS.md"; then
    check_file_size "$REPO_ROOT/AGENTS.md" 2000
    check_secrets "$REPO_ROOT/AGENTS.md"

    # Check for docs index
    if grep -q "docs.*guidelines" "$REPO_ROOT/AGENTS.md"; then
        echo "✅ AGENTS.md: Contains docs index"
    else
        echo "⚠️  AGENTS.md: Missing docs index reference"
    fi
fi
echo ""

# Check CLAUDE.md
echo "=== CLAUDE.md ==="
if check_exists "$REPO_ROOT/CLAUDE.md"; then
    check_file_size "$REPO_ROOT/CLAUDE.md" 300
    check_secrets "$REPO_ROOT/CLAUDE.md"

    # Check for @AGENTS.md import
    if grep -q "@AGENTS.md" "$REPO_ROOT/CLAUDE.md"; then
        echo "✅ CLAUDE.md: Contains @AGENTS.md import"
    else
        echo "❌ CLAUDE.md: Missing @AGENTS.md import"
        ((ERRORS++))
    fi
fi
echo ""

# Check guideline files
echo "=== Domain Guidelines ==="
guideline_count=$(find "$REPO_ROOT/docs" -name "*-guidelines.md" 2>/dev/null | wc -l)
if [ "$guideline_count" -gt 0 ]; then
    echo "✅ Found $guideline_count guideline file(s)"

    for guideline in "$REPO_ROOT/docs"/*-guidelines.md; do
        [ -f "$guideline" ] || continue
        basename_file=$(basename "$guideline")
        check_file_size "$guideline" 200
        check_secrets "$guideline"
    done
else
    echo "⚠️  No guideline files found in docs/"
fi
echo ""

# Check README.md
echo "=== README.md ==="
if check_exists "$REPO_ROOT/README.md"; then
    # Check for common sections
    if grep -iq "## .*install\|## .*build\|## .*getting started" "$REPO_ROOT/README.md"; then
        echo "✅ README.md: Contains getting started info"
    else
        echo "⚠️  README.md: Missing getting started section"
    fi
fi
echo ""

# Check .coderabbit.yaml
echo "=== CodeRabbit Config ==="
if check_exists "$REPO_ROOT/.coderabbit.yaml"; then
    if grep -q "docs/\*-guidelines.md" "$REPO_ROOT/.coderabbit.yaml"; then
        echo "✅ .coderabbit.yaml: Points to guideline files"
    else
        echo "⚠️  .coderabbit.yaml: Missing guideline file pattern"
    fi
fi
echo ""

# Summary
echo "========================================"
if [ "$ERRORS" -eq 0 ]; then
    echo "✅ All automated checks passed!"
    exit 0
else
    echo "❌ Found $ERRORS error(s)"
    exit 1
fi
