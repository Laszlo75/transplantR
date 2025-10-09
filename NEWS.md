# transplantR 0.0.0.9000

## Initial Release

### Clinical Risk Assessment
* `calc_kdri2012()` - Calculate Kidney Donor Risk Index (2012 version)
* `calc_kdri2019()` - Calculate Kidney Donor Risk Index (2019 version)
* `calc_kdri2019_category()` - Categorize KDRI 2019 scores into risk levels
* `calculate_gfr()` - Calculate eGFR using CKD-EPI 2021 equation

### Data Extraction
* `extract_donor_data_from_pdfs()` - Extract donor data from TransplantPath PDF reports
  - Comprehensive regex-based parsing
  - Automatic data type conversion
  - Error handling and validation

### Data Processing
* `create_cumulative_df()` - Create cumulative transplant count datasets
  - Month-by-month aggregation
  - Support for year-over-year comparisons

### Visualization
* `plot_cumulative()` - Year-over-year cumulative transplant activity plots
  - Automatic labeling with ggrepel
  - Configurable report year and month
  - NHS color scheme

### Documentation
* Comprehensive function documentation
* Unit tests for calculation functions
* README with usage examples
* Package logo
