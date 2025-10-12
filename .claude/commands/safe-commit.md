Create a git commit with PII safety checks for healthcare data protection:

1. Run git status to see all staged and unstaged changes
2. Run git diff to see full changes that will be committed
3. **CRITICAL PII SAFETY CHECK** - Scan changes for potential patient identifiable information:
   - NHS numbers (format: XXX XXX XXXX)
   - UK phone numbers (0XXX XXX XXXX)
   - Medical record numbers (MRN/Patient ID patterns)
   - UK postcodes
   - Dates that could be dates of birth
   - Any PDF, Excel, or CSV files with potential patient data
   - Check against patterns in .github/workflows/pii-check.yaml
4. If ANY suspicious patterns are detected:
   - STOP and warn the user with specific examples
   - Explain why each pattern is flagged
   - Ask for explicit confirmation before proceeding
   - Suggest adding false positives to .pii-whitelist if appropriate
5. If safe, or user confirms to proceed:
   - Stage appropriate files with git add
   - Create commit with descriptive message following the repository convention
   - Include Claude Code attribution:
     ```
     Brief description (50 chars or less)

     - Bullet points for changes
     - Use imperative mood

     🤖 Generated with [Claude Code](https://claude.com/claude-code)

     Co-Authored-By: Claude <noreply@anthropic.com>
     ```
6. Run git status after commit to verify success

Remember: This package is used by NHS Wales. Patient data protection is PARAMOUNT. When in doubt, err on the side of caution.
