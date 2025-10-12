Run a comprehensive R package validation workflow for transplantR:

1. Update documentation first with roxygen2::roxygenise() to ensure everything is current
2. Run all tests with devtools::test() and report any failures
3. Run full package check with devtools::check() including:
   - R CMD check for CRAN standards
   - Documentation completeness
   - Namespace consistency
   - Examples validation
4. Summarize results clearly:
   - Number of errors, warnings, notes
   - Test pass/fail count
   - Key issues that need attention
5. If there are any issues, provide specific file/line references and suggest fixes

Focus on issues that would prevent CRAN submission or indicate bugs. Ignore cosmetic notes unless they're important.

This is a production package used by NHS Wales, so thoroughness is critical.
