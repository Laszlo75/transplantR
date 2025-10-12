# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**transplantR** is an R package for transplant medicine and nephrology that provides clinical risk assessment tools, data extraction from PDF reports, and visualization functions for transplant activity reporting. Used by NHS Wales for analyzing transplant outcomes.

## Package Architecture

### Three Core Function Groups

1. **Clinical Calculations** (`R/calculations.R`)
   - KDRI (Kidney Donor Risk Index) 2012 and 2019 implementations
   - CKD-EPI 2021 GFR calculation
   - All use base R math (no external calculation libraries)
   - Input validation relies on type coercion - strings like "YES"/"NO" are expected

2. **Data Pipeline** (`R/extract_donor_data.R`, `R/create_cumulative_df.R`)
   - `extract_donor_data_from_pdfs()`: Regex-based extraction from TransplantPath PDF reports
   - Returns structured tibbles with parsed dates, numeric conversions, and calculated fields
   - `create_cumulative_df()`: Aggregates transplant events into month-by-month cumulative counts
   - Both support optional `params` object for parameterized R Markdown reports

3. **Visualization** (`R/plot_cumulative.R`)
   - Year-over-year comparison plots using ggplot2 + ggrepel
   - NHS color scheme: primary `#005EB8`, previous year `#768692`
   - Uses `linewidth` (not deprecated `size`) for lines

### Key Design Patterns

- **Field name conventions**: All donor fields prefixed with `donor_` (e.g., `donor_age_year`, `donor_hypertension`)
- **Date handling**: Uses lubridate's `dmy()` and `dmy_hm()` for UK date formats
- **NSE (Non-Standard Evaluation)**: Functions use dplyr's NSE; `R/globals.R` declares all NSE variables for R CMD check
- **Pipe operator**: Uses `%>%` from dplyr (imported in each file that needs it)

## Development Commands

### Building & Testing
```r
# Install package locally
devtools::install()

# Run tests
devtools::test()

# Run R CMD check
devtools::check()

# Build documentation
roxygen2::roxygenise()

# Build pkgdown site
pkgdown::build_site()
```

### Documentation
- All exported functions must have `@export` tag
- Use `@importFrom package function` for each external function used
- Examples in roxygen should be wrapped in `\dontrun{}` if they require external data
- Documentation style: imperative voice, UK English spelling

## Critical: PII Protection System

**NEVER commit patient data.** This package has automated PII detection:

### Pre-commit Hook
- Scans for NHS numbers, phone numbers, postcodes, dates, medical record numbers
- Located: `.git/hooks/pre-commit`
- If blocked: Review flagged content, remove actual PII, or add false positives to `.pii-whitelist`

### GitHub Actions
- Workflow: `.github/workflows/pii-check.yaml`
- Respects `.pii-whitelist` file
- Excludes `PII-PROTECTION.md` (documentation about PII)
- Full details in `PII-PROTECTION.md`

### When Adding Test Data or Examples
1. Use obviously synthetic values (e.g., `donor_age_year = 45`, not actual patient ages)
2. Add any example patterns to `.pii-whitelist` if they trigger false positives
3. Never use real dates, names, or identifiers - even if anonymized

## Package Dependencies

### Import Pattern
```r
# In function roxygen:
#' @importFrom dplyr mutate filter %>%
#' @importFrom ggplot2 ggplot aes geom_line
```

### Key Dependencies
- **dplyr**: Data manipulation (uses NSE)
- **ggplot2/ggrepel**: Plotting
- **pdftools**: PDF text extraction
- **lubridate**: Date parsing
- **stringr**: Regex extraction

## Testing

### Test Structure
- Location: `tests/testthat/test-*.R`
- Currently: Only calculation functions tested
- Tests verify mathematical correctness against known formula outputs

### Adding Tests
```r
test_that("function_name works correctly", {
  result <- your_function(args)
  expect_equal(result, expected_value, tolerance = 1e-6)
})
```

## Website (pkgdown)

### Configuration
- `_pkgdown.yml`: Defines function grouping, theme (Flatly), NHS primary color
- Auto-deploys: `.github/workflows/pkgdown.yaml` (on push to main)
- Live at: https://laszlo75.github.io/transplantR

### Function Grouping
Functions organized into:
- Clinical Risk Assessment
- Data Extraction
- Data Processing
- Visualization

Match these groups when adding new functions to `_pkgdown.yml`.

## Common Patterns

### Expected Input Formats
- **Dates**: UK format (DD/MM/YYYY) strings → converted with `lubridate::dmy()`
- **Binary flags**: Strings "YES"/"NO" (not TRUE/FALSE booleans)
- **Sex**: Strings "MALE"/"FEMALE" (case-sensitive in calculations)
- **Weights/heights**: Numeric in kg/cm

### Error Handling
- `extract_donor_data_from_pdfs()`: Uses `tryCatch()` per file, warns but continues on errors
- Returns empty tibbles for missing data (not NULL or errors)
- Date parsing failures → `NA` (not errors)

### Visualization Parameters
- `report_year` and `report_month`: Can default from `params` object (for R Markdown) or be explicit
- Colors: Use NHS palette constants when extending plots
- Font sizes: Match existing (size 5 for labels, 1.5/0.5 for lines)

## File Conventions

### When Adding Functions
1. Group related functions in same `.R` file
2. Add roxygen documentation with all tags
3. Add `@export` for user-facing functions
4. Update `_pkgdown.yml` to categorize in website
5. Add tests in `tests/testthat/test-<filename>.R`
6. Update `NEWS.md` with feature addition

### Naming
- Function names: `verb_noun` pattern (e.g., `calc_kdri2019`, `create_cumulative_df`)
- Internal variables: snake_case
- Exported functions: No dots in names (use underscores)

## NHS/Healthcare Context

- **TransplantPath**: Specific PDF report format from ODT (Organ Donation and Transplantation)
- **KDRI**: Clinical scoring system for kidney transplant outcomes
- **DCD/DBD**: Donation after Circulatory/Brain Death (donor types)
- **ODT numbers**: UK organ donor identifiers

## Commit Messages

Follow convention:
```
Brief description (50 chars or less)

- Bullet points for changes
- Use imperative mood

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Package State

- Version: 0.0.0.9000 (development)
- Status: Production-ready, in active use
- License: MIT
- R version: Compatible with R 4.5+
- Platform: Cross-platform (macOS, Linux, Windows)
