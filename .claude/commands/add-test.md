Create a comprehensive test file for a transplantR function:

1. Ask the user which function or R file needs tests
2. Read the function implementation to understand:
   - All parameters and their expected types
   - The calculation logic or data processing steps
   - Expected return values
   - Any error conditions
3. Create or update the test file in tests/testthat/test-<filename>.R following testthat conventions
4. Generate test cases covering:
   - **Normal inputs**: Typical valid values that should work correctly
   - **Edge cases**: Boundary values, NA, NULL, empty vectors, single values
   - **Invalid inputs**: Wrong types, out-of-range values (should error appropriately)
   - **Clinical edge cases** (for calculation functions): Minimum/maximum clinical values
5. Use ONLY synthetic test data that won't trigger PII checks:
   - Generic ages like 45, 60, 25 (not specific patient ages)
   - "YES"/"NO" for binary flags (not real patient responses)
   - "MALE"/"FEMALE" for sex
   - Round numbers for weights/heights
   - Obviously fake dates like "01/01/2020"
   - No real NHS numbers, postcodes, or identifiers
6. Follow existing test patterns in tests/testthat/test-calculations.R:
   - Use expect_equal() with tolerance for numeric comparisons
   - Use expect_error() for validation checks
   - Group related tests in describe() blocks if needed
7. After creating tests, run devtools::test() to verify they pass
8. Report:
   - Test file location with clickable link
   - Number of test cases added
   - Test results (pass/fail)
   - Suggest any additional test scenarios if gaps exist

Reference the package architecture in CLAUDE.md for context on how functions should behave.
