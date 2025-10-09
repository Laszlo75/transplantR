# Global variables for NSE (non-standard evaluation)
# This prevents R CMD check from issuing NOTEs about undefined global variables

utils::globalVariables(c(
  # Variables from create_cumulative_df
  "params",
  "tx_date",
  "transplant",

  # Variables from extract_donor_data_from_pdfs
  "donor_dob_raw",
  "donor_height_raw",
  "donor_weight_raw",
  "donor_hcv_long",
  "donor_creatinine_raw",
  "donor_egfr",
  "donor_date_admission_raw",
  "donor_kts_raw",
  "donor_treatment_withdrawal_raw",
  "donor_perfusion_start_raw",
  "donor_perfusion_start_dcd_raw",
  "kidney_anatomy_left_raw",
  "kidney_anatomy_right_raw",
  "donor_kts",
  "donor_date_admission",

  # Variables from plot_cumulative
  "is_top",
  "range_y",
  "raw_nudge_y"
))
