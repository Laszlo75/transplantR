# Global variables for NSE (non-standard evaluation)
# This prevents R CMD check from issuing NOTEs about undefined global variables

utils::globalVariables(c(
  # Variables from create_cumulative_df
  "params",
  "tx_date",
  "transplant",

  # Variables from plot_cumulative
  "is_top",
  "range_y",
  "raw_nudge_y"
))
