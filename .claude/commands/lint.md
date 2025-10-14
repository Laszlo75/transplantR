---
description: Check and fix linting problems in markdown files
---

# Lint Check and Fix Command

You are a markdown linting expert. Your task is to check for and fix linting issues in markdown files.

## Task

1. **Identify the scope:**
   - If a file path is provided as an argument (e.g., `/lint path/to/file.md`), work on that specific file
   - If `all` is specified (e.g., `/lint all`), check all markdown files in the project
   - If no argument is provided, check the most recently modified markdown file or ask the user which file to lint

2. **Check for linting issues:**
   - Use the IDE diagnostics to identify markdown linting issues (markdownlint rules)
   - Look for common issues like:
     - MD022: Headings should be surrounded by blank lines
     - MD032: Lists should be surrounded by blank lines
     - MD031: Fenced code blocks should be surrounded by blank lines
     - MD040: Fenced code blocks should have a language specified
     - MD026: Trailing punctuation in heading
     - MD029: Ordered list item prefix inconsistencies
     - Any other markdownlint warnings or errors

3. **Automatically fix issues:**
   - Read the file content
   - Apply fixes for each detected issue:
     - Add blank lines around headings, lists, and code blocks
     - Add language identifiers to code blocks (infer from context or use `text` as default)
     - Remove trailing punctuation from headings
     - Fix ordered list numbering
   - Write the corrected file back

4. **Report results:**
   - Provide a summary of what was fixed
   - List each type of issue and how many were corrected
   - Confirm the file now passes linting checks

## Important Notes

- **Preserve file content:** Only modify formatting and structure, never change the actual content or meaning
- **Handle code blocks carefully:** Don't modify code inside code blocks, only add language identifiers if missing
- **Verify fixes:** After making changes, check if new linting issues were introduced
- **Be conservative:** If unsure about a fix, ask the user before proceeding

## Example Usage

```bash
/lint                           # Lint most recent markdown file
/lint REFACTORING_REPORT.md    # Lint specific file
/lint all                       # Lint all markdown files in project
```

## Output Format

Provide output in this format:

```
✅ Linted: path/to/file.md

Fixed issues:
- MD022: Added blank lines around 5 headings
- MD032: Added blank lines around 8 lists
- MD031: Added blank lines around 12 code blocks
- MD029: Fixed ordered list numbering (2 instances)

✨ File now passes all linting checks!
```

If there are remaining issues that couldn't be auto-fixed, report them clearly so the user can address them manually.
