# Changelog

## transplantR 0.1.0 (2026-10-14)

First numbered release.

#### Breaking Changes

**`extract_donor_data_from_pdfs()`** has been removed. It has moved,
unchanged, to a separate package for tools specific to the
TransplantPath donor reports. transplantR now focuses on the clinical
calculators and the activity reporting plots.

- `pdftools`, `stringr` and `tibble` are no longer dependencies

## transplantR 0.0.0.9000

### Changes (2025-10-14)

#### Breaking Changes

**`extract_donor_data_from_pdfs()`** - **BREAKING**: Function signature
changed

- Now accepts a character vector of file paths instead of a folder path

- Parameter renamed from `folder_path` to `files`

- Users must now use
  [`list.files()`](https://rdrr.io/r/base/list.files.html) to generate
  file lists from folders

- **Migration**: Replace
  `extract_donor_data_from_pdfs("path/to/folder")` with:

  ``` r

  pdf_files <- list.files("path/to/folder", pattern = "\\.pdf$", full.names = TRUE)
  extract_donor_data_from_pdfs(pdf_files)
  ```

  - Benefits: More flexible file selection, can process files from
    multiple locations, easier testing

### Initial Release

#### Clinical Risk Assessment

- [`calc_kdri2012()`](https://laszlo75.github.io/transplantR/reference/calc_kdri2012.md) -
  Calculate Kidney Donor Risk Index (2012 version)
- [`calc_kdri2019()`](https://laszlo75.github.io/transplantR/reference/calc_kdri2019.md) -
  Calculate Kidney Donor Risk Index (2019 version)
- [`calc_kdri2019_category()`](https://laszlo75.github.io/transplantR/reference/calc_kdri2019_category.md) -
  Categorize KDRI 2019 scores into risk levels
- [`calculate_gfr()`](https://laszlo75.github.io/transplantR/reference/calculate_gfr.md) -
  Calculate eGFR using CKD-EPI 2021 equation

#### Data Extraction

**`extract_donor_data_from_pdfs()`** - Extract donor data from
TransplantPath PDF reports

- Comprehensive regex-based parsing
- Automatic data type conversion
- Error handling and validation

#### Data Processing

**[`create_cumulative_df()`](https://laszlo75.github.io/transplantR/reference/create_cumulative_df.md)** -
Create cumulative transplant count datasets

- Month-by-month aggregation
- Support for year-over-year comparisons

#### Visualization

**[`plot_cumulative()`](https://laszlo75.github.io/transplantR/reference/plot_cumulative.md)** -
Year-over-year cumulative transplant activity plots

- Automatic labeling with ggrepel
- Configurable report year and month
- NHS color scheme

#### Documentation

- Comprehensive function documentation
- Unit tests for calculation functions
- README with usage examples
- Package logo
