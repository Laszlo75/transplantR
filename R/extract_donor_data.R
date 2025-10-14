#' Extract donor data from PDF reports
#'
#' Processes specified PDF files to extract comprehensive donor
#' information using regular expression patterns. This function is designed to
#' parse TransplantPath donor reports and extract structured data for analysis.
#'
#' The function automatically:
#' * **Validates PDF files** in the provided file list
#' * **Extracts text content** from each PDF using the pdftools package
#' * **Applies regex patterns** to identify and extract specific donor variables
#' * **Calculates derived variables** such as days in hospital
#' * **Handles errors gracefully** with informative warnings for problematic files
#' * **Returns a clean tibble** with all extracted donor information
#'
#' @param files (character) Character vector of full or relative paths to PDF
#'   files to process. Each file must exist and have a ".pdf" extension
#'   (case-insensitive). Use `list.files()` to generate file lists from folders.
#'
#' @return A **tibble** containing extracted donor information with the following columns:
#'   * `donor_number` - ODT donor identification number
#'   * `donor_dob` - Date of birth (character format)
#'   * `donor_age_year` - Age in years
#'   * `donor_sex` - Gender (M/F)
#'   * `donor_height` - Height in centimeters
#'   * `donor_weight` - Weight in kilograms
#'   * `donor_hypertension` - Hypertension status (Yes/No)
#'   * `donor_diabetes` - Diabetes status (Yes/No)
#'   * `donor_cmv` - CMV status (Positive/Negative)
#'   * `donor_hcv` - HCV status
#'   * `donor_creatinine` - Serum creatinine level (μmol/L)
#'   * `donor_egfr` - Estimated glomerular filtration rate
#'   * `donor_date_admission` - Hospital admission date
#'   * `donor_type` - Donor type (DBD/DCD)
#'   * `donor_pr_dg` - Primary diagnosis
#'   * `donor_cause_of_death` - Cause of death
#'   * `donor_adrenaline` - Adrenaline usage status
#'   * `donor_noradrenaline` - Noradrenaline usage status
#'   * `donor_kts` - Date/time surgery commenced
#'   * `donor_treatment_withdrawal` - Treatment withdrawal time (DCD donors)
#'   * `donor_perfusion_start` - Systemic perfusion start time
#'   * `donor_perfusion_start_dcd` - Cold in-situ perfusion start time (DCD)
#'   * `donor_left_kidney_perfusion_quality` - Quality of perfusion for left kidney
#'   * `donor_right_kidney_perfusion_quality` - Quality of perfusion for right kidney
#'   * `donor_days_in_hospital` - Calculated days between admission and surgery
#'   * `filename` - Source PDF filename for reference
#'
#' @section Error Handling:
#'   * **Invalid input**: Function stops if files parameter is not a character vector
#'   * **Missing files**: Function stops if any specified file does not exist
#'   * **Non-PDF files**: Function stops if any file lacks .pdf extension
#'   * **Empty file list**: Returns empty tibble with warning
#'   * **Corrupted PDFs**: Individual file failures are logged as warnings,
#'     but processing continues for remaining files
#'   * **Date parsing errors**: Days in hospital calculation defaults to NA
#'     if date parsing fails
#'
#' @section Dependencies:
#'   Requires **pdftools**, **dplyr**, **stringr**, and **tibble** packages.
#'   Make sure these are loaded before calling the function.
#'
#' @section Performance Notes:
#'   * Processing time scales linearly with number and size of PDF files
#'   * Large batches (>100 files) may take several minutes
#'   * Progress messages are printed to console during processing
#'
#' @examples
#' \dontrun{
#' # Extract data from a list of specific PDF files
#' files <- c("path/to/donor1.pdf", "path/to/donor2.pdf")
#' donor_data <- extract_donor_data_from_pdfs(files)
#'
#' # Extract data from all PDFs in a folder using list.files()
#' pdf_files <- list.files("path/to/pdf/folder",
#'                         pattern = "\\.pdf$",
#'                         full.names = TRUE)
#' donor_data <- extract_donor_data_from_pdfs(pdf_files)
#'
#' # Check the results
#' glimpse(donor_data)
#' cat("Processed", nrow(donor_data), "donor records")
#' }
#'
#' @importFrom pdftools pdf_text
#' @importFrom dplyr mutate filter select case_when %>%
#' @importFrom stringr str_extract str_flatten str_squish str_trim str_length
#' @importFrom tibble tibble
#' @importFrom lubridate dmy dmy_hm
#' @export
extract_donor_data_from_pdfs <- function(files) {
  # Validate input type
  if (!is.character(files)) {
    stop("'files' parameter must be a character vector of file paths")
  }

  # Check if any files provided
  if (length(files) == 0) {
    warning("No files provided")
    return(tibble())
  }

  # Check if all files exist
  missing_files <- files[!file.exists(files)]
  if (length(missing_files) > 0) {
    stop(
      "The following files do not exist:\n  ",
      paste(missing_files, collapse = "\n  ")
    )
  }

  # Check if all files have .pdf extension
  non_pdf_files <- files[!grepl("\\.pdf$", files, ignore.case = TRUE)]
  if (length(non_pdf_files) > 0) {
    stop(
      "The following files do not have .pdf extension:\n  ",
      paste(non_pdf_files, collapse = "\n  ")
    )
  }

  cat("Found", length(files), "PDF files\n")

  # Extract text from all PDFs
  text_data <- NULL

  for (file in files) {
    cat("Processing:", basename(file), "\n")
    tryCatch(
      {
        text <- pdf_text(file) %>%
          str_flatten(" ") %>%
          str_squish()
        text_data <- c(text_data, text)
      },
      error = function(e) {
        warning("Could not process file: ", file, " - ", e$message)
        text_data <- c(text_data, NA)
      }
    )
  }

  # Create raw data tibble
  raw_donor_data <- tibble(files, text_data)

  # Extract donor data using regex patterns
  df_tp_donors <- raw_donor_data %>%
    filter(!is.na(text_data)) %>% # Remove failed extractions
    mutate(
      donor_number = str_extract(text_data, "(?<=ODT number )[^\\s]+"),

      # Extract and convert donor_dob to Date
      donor_dob_raw = str_extract(text_data, "(?<=Date of birth )[^\\s]+"),
      donor_dob = dmy(donor_dob_raw),

      donor_age_year = str_extract(text_data, "(?<=Age )[^\\s]+"),
      donor_sex = str_extract(text_data, "\\w+(?= Date of Birth)"),

      # Extract and convert donor_height to numeric
      donor_height_raw = str_extract(text_data, "(?<=Height \\(cm\\) )[^\\s]+"),
      donor_height = as.numeric(donor_height_raw),

      # Extract and convert donor_weight to numeric
      donor_weight_raw = str_extract(text_data, "(?<=Weight \\(kg\\) )[^\\s]+"),
      donor_weight = as.numeric(donor_weight_raw),

      donor_hypertension = str_extract(
        text_data,
        "\\w+(?=\\s+No. of antihypertensives at time of)"
      ),
      donor_diabetes = str_extract(
        text_data,
        "\\w+(?=\\s+Insulin, medication or diet)"
      ),
      donor_cmv = str_extract(text_data, "(?<=CMV )[^\\s]+"),
      donor_hcv_long = str_extract(
        text_data,
        "(Pre Transfusion.*? HCV (\\w+))"
      ),
      donor_hcv = str_extract(donor_hcv_long, "(?<=HCV )(\\w+)"),

      # Extract and convert donor_creatinine to numeric
      donor_creatinine_raw = str_extract(
        text_data,
        "(?<=Serum Creatinine \\(.mol\\/L\\) )[^\\s]+"
      ),
      donor_creatinine = as.numeric(donor_creatinine_raw),

      donor_egfr = str_extract(
        text_data,
        "(?<=eGFR \\(ml\\/min\\/1\\.73 m.\\) )[^\\s]+"
      ),
      donor_egfr = as.numeric(donor_egfr),

      # Extract and convert donor_date_admission to Date
      donor_date_admission_raw = str_extract(
        text_data,
        "(?<=Date\\/time of admission to hospital )[^\\s]+"
      ),
      donor_date_admission = dmy(donor_date_admission_raw),

      donor_type = str_extract(text_data, "(?<=Donor Type )[^\\s]+"),
      donor_pr_dg = str_extract(
        text_data,
        "(?<=Primary diagnosis\\s)(.*?)(?=\\sCause of death)"
      ),
      donor_cause_of_death_raw = str_extract(
        text_data,
        "(?<=Cause of death\\s)([^\\r\\n]*?)(?=\\s*(?:Other|$))"
      ),
      donor_cause_of_death = case_when(
        is.na(donor_cause_of_death_raw) ~ NA_character_,
        str_trim(donor_cause_of_death_raw) == "" ~ NA_character_,
        str_length(str_trim(donor_cause_of_death_raw)) == 0 ~ NA_character_,
        TRUE ~ str_trim(donor_cause_of_death_raw)
      ),
      donor_adrenaline = str_extract(
        text_data,
        "(?<=Adrenaline\\s)\\S+(?=\\sDate/Time)"
      ),
      donor_noradrenaline = str_extract(
        text_data,
        "(?<=Noradrenaline\\s)\\S+(?=\\sDate/Time)"
      ),

      # Extract and convert donor_kts to datetime
      donor_kts_raw = str_extract(
        text_data,
        "(?<=Date/time surgery commenced )[^\\s]+.[^\\s]+"
      ),
      donor_kts = dmy_hm(donor_kts_raw),

      # Extract and convert donor_treatment_withdrawal to datetime
      donor_treatment_withdrawal_raw = str_extract(
        text_data,
        "((?<=Date/time of treatment withdrawal )[^\\s]+.[^\\s]+)"
      ),
      donor_treatment_withdrawal = dmy_hm(donor_treatment_withdrawal_raw),

      # Extract and convert donor_perfusion_start to datetime
      donor_perfusion_start_raw = str_extract(
        text_data,
        "(?<=Date/time Systemic Perfusion )[^\\s]+.[^\\s]+"
      ),
      donor_perfusion_start = dmy_hm(donor_perfusion_start_raw),

      # Extract and convert donor_perfusion_start_dcd to datetime
      donor_perfusion_start_dcd_raw = str_extract(
        text_data,
        "(?<=Date/time cold insitu aortic )[^\\s]+.[^\\s]+"
      ),
      donor_perfusion_start_dcd = dmy_hm(donor_perfusion_start_dcd_raw),

      # NRP
      nrp = str_extract(
        text_data,
        "(?<=Did donor undergo normothermic? )\\w+(?=\\sperfusion)"
      ),
      # Anatomy
      ## Left kidney
      kidney_anatomy_left_raw = str_extract(
        text_data,
        "Kidney Anatomy Left Kidney[\\s\\S]*?(?=Crossmatch material)"
      ),

      ## Right kidney
      kidney_anatomy_right_raw = str_extract(
        text_data,
        "Right Kidney Perfusion[\\s\\S]*?(?=Crossmatch material)"
      ),

      # Perfusion quality
      donor_left_kidney_perfusion_quality = str_extract(
        kidney_anatomy_left_raw,
        "(?<=Quality of perfusion\\s)\\w+(?=\\s+Anatomical)"
      ),
      donor_right_kidney_perfusion_quality = str_extract(
        kidney_anatomy_right_raw,
        "(?<=Quality of perfusion\\s)\\w+(?=\\s+Anatomical)"
      ),
      # Abnormalities
      donor_left_kidney_abnormalities = str_extract(
        kidney_anatomy_left_raw,
        "(?<=Other abnormalities\\s)(.*?)(?=\\s*Damage Capsule)"
      ),
      donor_right_kidney_abnormalities = str_extract(
        kidney_anatomy_right_raw,
        "(?<=Other abnormalities\\s)(.*?)(?=\\s*Damage Capsule)"
      ),

      # Damage
      donor_left_kidney_damage = str_extract(
        kidney_anatomy_left_raw,
        "(?<=Other damage during retrieval\\s)(.*)"
      ),
      donor_right_kidney_damage = str_extract(
        kidney_anatomy_right_raw,
        "(?<=Other damage during retrieval\\s)(.*)"
      ),

      # Calculate days in hospital using the converted Date objects
      donor_days_in_hospital = tryCatch(
        {
          as.numeric(as.Date(donor_kts) - donor_date_admission)
        },
        error = function(e) NA
      ),

      # Add filename for reference
      filename = basename(files)
    ) %>%
    # Remove raw extraction columns and intermediate columns
    select(
      -c(
        donor_hcv_long,
        # text_data,
        files,
        donor_dob_raw,
        donor_height_raw,
        donor_weight_raw,
        donor_creatinine_raw,
        donor_date_admission_raw,
        donor_kts_raw,
        donor_treatment_withdrawal_raw,
        donor_perfusion_start_raw,
        donor_perfusion_start_dcd_raw
      )
    )

  cat("Successfully extracted data from", nrow(df_tp_donors), "files\n")

  # Print data type summary
  cat("\nData types after conversion:\n")
  cat("donor_dob:", class(df_tp_donors$donor_dob), "\n")
  cat("donor_date_admission:", class(df_tp_donors$donor_date_admission), "\n")
  cat("donor_height:", class(df_tp_donors$donor_height), "\n")
  cat("donor_weight:", class(df_tp_donors$donor_weight), "\n")
  cat("donor_creatinine:", class(df_tp_donors$donor_creatinine), "\n")
  cat("donor_kts:", class(df_tp_donors$donor_kts), "\n")
  cat(
    "donor_treatment_withdrawal:",
    class(df_tp_donors$donor_treatment_withdrawal),
    "\n"
  )
  cat("donor_perfusion_start:", class(df_tp_donors$donor_perfusion_start), "\n")
  cat(
    "donor_perfusion_start_dcd:",
    class(df_tp_donors$donor_perfusion_start_dcd),
    "\n"
  )

  return(df_tp_donors)
}
