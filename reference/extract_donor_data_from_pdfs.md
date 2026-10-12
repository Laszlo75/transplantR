# Extract donor data from PDF reports

Processes specified PDF files to extract comprehensive donor information
using regular expression patterns. This function is designed to parse
TransplantPath donor reports and extract structured data for analysis.

## Usage

``` r
extract_donor_data_from_pdfs(files)
```

## Arguments

- files:

  (character) Character vector of full or relative paths to PDF files to
  process. Each file must exist and have a ".pdf" extension
  (case-insensitive). Use
  [`list.files()`](https://rdrr.io/r/base/list.files.html) to generate
  file lists from folders.

## Value

A **tibble** containing extracted donor information with the following
columns:

- `donor_number` - ODT donor identification number

- `donor_dob` - Date of birth (character format)

- `donor_age_year` - Age in years

- `donor_sex` - Gender (M/F)

- `donor_height` - Height in centimeters

- `donor_weight` - Weight in kilograms

- `donor_hypertension` - Hypertension status (Yes/No)

- `donor_diabetes` - Diabetes status (Yes/No)

- `donor_cmv` - CMV status (Positive/Negative)

- `donor_hcv` - HCV status

- `donor_creatinine` - Serum creatinine level (μmol/L)

- `donor_egfr` - Estimated glomerular filtration rate

- `donor_date_admission` - Hospital admission date

- `donor_type` - Donor type (DBD/DCD)

- `donor_pr_dg` - Primary diagnosis

- `donor_cause_of_death` - Cause of death

- `donor_adrenaline` - Adrenaline usage status

- `donor_noradrenaline` - Noradrenaline usage status

- `donor_kts` - Date/time surgery commenced

- `donor_treatment_withdrawal` - Treatment withdrawal time (DCD donors)

- `donor_perfusion_start` - Systemic perfusion start time

- `donor_perfusion_start_dcd` - Cold in-situ perfusion start time (DCD)

- `donor_left_kidney_perfusion_quality` - Quality of perfusion for left
  kidney

- `donor_right_kidney_perfusion_quality` - Quality of perfusion for
  right kidney

- `donor_days_in_hospital` - Calculated days between admission and
  surgery

- `filename` - Source PDF filename for reference

## Details

The function automatically:

- **Validates PDF files** in the provided file list

- **Extracts text content** from each PDF using the pdftools package

- **Applies regex patterns** to identify and extract specific donor
  variables

- **Calculates derived variables** such as days in hospital

- **Handles errors gracefully** with informative warnings for
  problematic files

- **Returns a clean tibble** with all extracted donor information

## Error Handling

- **Invalid input**: Function stops if files parameter is not a
  character vector

- **Missing files**: Function stops if any specified file does not exist

- **Non-PDF files**: Function stops if any file lacks .pdf extension

- **Empty file list**: Returns empty tibble with warning

- **Corrupted PDFs**: Individual file failures are logged as warnings,
  but processing continues for remaining files

- **Date parsing errors**: Days in hospital calculation defaults to NA
  if date parsing fails

## Dependencies

Requires **pdftools**, **dplyr**, **stringr**, and **tibble** packages.
Make sure these are loaded before calling the function.

## Performance Notes

- Processing time scales linearly with number and size of PDF files

- Large batches (\>100 files) may take several minutes

- Progress messages are printed to console during processing

## Examples

``` r
if (FALSE) { # \dontrun{
# Extract data from a list of specific PDF files
files <- c("path/to/donor1.pdf", "path/to/donor2.pdf")
donor_data <- extract_donor_data_from_pdfs(files)

# Extract data from all PDFs in a folder using list.files()
pdf_files <- list.files("path/to/pdf/folder",
                        pattern = "\\.pdf$",
                        full.names = TRUE)
donor_data <- extract_donor_data_from_pdfs(pdf_files)

# Check the results
glimpse(donor_data)
cat("Processed", nrow(donor_data), "donor records")
} # }
```
