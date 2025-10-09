#' Monthly cumulative transplant counts
#'
#' Aggregates transplant-level data into a tidy, month-by-month cumulative
#' series for each calendar year.
#'
#' * Adds a **month 0** row (value = 0) so every yearly line starts at zero.
#' * Ensures every month 0–12 is present, forward-filling missing values so the
#'   output is plot-ready.
#' * Trims future months beyond the reporting cut-off.
#'
#' @param df           A data frame or tibble containing **one row per transplant**
#'                     and a `Date` column named `tx_date`.
#' @param report_year  (numeric) Calendar year of the report (e.g. `2025`).
#' @param report_month (integer, 0–12) Final month to include in the
#'                     year-to-date comparison. Use `0` for a baseline plot.
#'
#' @return A tibble with columns:
#' \describe{
#'   \item{year}{integer — calendar year}
#'   \item{month}{integer — 0 = baseline, 1–12 = January-December}
#'   \item{cumsum}{numeric — cumulative transplant count at the end of `month`}
#' }
#'
#' @examples
#' \dontrun{
#' cum_df <- create_cumulative_df(transplants,
#'                                report_year  = 2025,
#'                                report_month = 4)
#' }
#'
#' @importFrom dplyr mutate count group_by arrange ungroup filter %>%
#' @importFrom tidyr complete full_seq
#' @importFrom lubridate year month
#' @export
#'
create_cumulative_df <- function(df, report_year = NULL, report_month = NULL) {
  # ---- resolve defaults ------------------------------------------------------
  if (is.null(report_year)) {
    if (
      exists("params", inherits = TRUE) &&
        !is.null(params$report_year)
    ) {
      report_year <- params$report_year
    } else {
      stop("`report_year` is missing and not found in `params`.")
    }
  }

  if (is.null(report_month)) {
    if (
      exists("params", inherits = TRUE) &&
        !is.null(params$report_month)
    ) {
      report_month <- params$report_month
    } else {
      stop("`report_month` is missing and not found in `params`.")
    }
  }

  df %>%
    # one row per (year, month) with a count of transplants
    mutate(year = year(tx_date), month = month(tx_date)) %>%
    count(year, month, name = "transplant") %>%

    # add month 0 for every year so each line starts from zero
    complete(
      year = full_seq(c(min(year), report_year), 1),
      month = 0:12,
      fill = list(transplant = 0)
    ) %>%

    group_by(year) %>%
    arrange(month, .by_group = TRUE) %>%
    mutate(cumsum = cumsum(transplant)) %>%
    ungroup() %>%

    # trim future months
    filter(year < report_year | month <= report_month)
}
