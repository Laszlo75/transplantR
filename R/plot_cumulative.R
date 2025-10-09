#' Cumulative transplant comparison plot
#'
#' Generates a year-over-year cumulative line chart for transplant activity,
#' visually contrasting the current report year against the previous year.
#'
#' Key features
#' * **Vertical cut-off line** at the reporting month.
#' * **Automatic labelling** (via *ggrepel*) that places the higher value above
#'   the point, the lower below it, and nudges labels away from the y-axis when
#'   counts are near zero.
#' * A faint “tail” segment shows how last year continued after the current
#'   cut-off, providing instant context on catch-up or lag.
#'
#' @param cumulative_data A data frame (or tibble) returned by
#'   `create_cumulative_df()`, containing `year`, `month`, and `cumsum`
#'   columns.
#' @param report_year  (numeric) Calendar year of the current report
#'   (e.g. `2025`).
#' @param report_month (integer, 0–12) Final month shown for the
#'   year-to-date comparison.
#'
#' @return A **`ggplot`** object. Print it to display, or add layers /
#'   themes as needed.
#'
#' @section Dependencies:
#'   Relies on **ggplot2**, **dplyr**, and **ggrepel**.
#'
#' @examples
#' \dontrun{
#' cum_df <- create_cumulative_df(transplants,
#'                                report_year  = 2025,
#'                                report_month = 4)
#'
#' plot_cumulative(cum_df,
#'                 report_year  = 2025,
#'                 report_month = 4)
#' }
#'
#' @importFrom dplyr filter group_by mutate ungroup %>%
#' @importFrom ggplot2 ggplot aes geom_line geom_vline geom_point scale_colour_manual scale_x_continuous labs
#' @importFrom ggrepel geom_label_repel
#' @export
plot_cumulative <- function(
  cumulative_data,
  report_year = NULL,
  report_month = NULL
) {

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

  # --- points we want to label -----------------------------------------------
  label_data <- cumulative_data %>%
    filter(
      (month == report_month & year %in% c(report_year, report_year - 1)) |
        (month == 12 & year == report_year - 1)
    ) %>%
    group_by(month) %>%
    mutate(
      is_top = cumsum == max(cumsum),
      range_y = max(cumulative_data$cumsum, na.rm = TRUE),

      ## --- Y-offset -----------------------------------------------------------
      ## try to put the lower value below its point …
      raw_nudge_y = ifelse(
        is_top,
        0.06 * range_y, # top label goes up
        -0.06 * range_y
      ), # bottom label goes down
      ## … but never let the label’s centre fall below zero
      nudge_y = ifelse(
        cumsum + raw_nudge_y < 0,
        0.06 * range_y, # flip it above the point
        raw_nudge_y
      ),

      ## --- X-offset (unchanged) ----------------------------------------------
      nudge_x = ifelse(cumsum < 0.05 * range_y, 0.3, 0)
    ) %>%
    ungroup()

  ggplot(
    data = subset(cumulative_data, month <= report_month),
    aes(month, cumsum, colour = factor(year))
  ) +
    geom_line(linewidth = 1.5, lineend = "round") +
    geom_vline(xintercept = report_month, colour = "#E8EDEE", linewidth = .5) +

    # tail of the previous year beyond this month's cut-off
    geom_line(
      data = subset(
        cumulative_data,
        year == report_year - 1 &
          month >= report_month
      ),
      aes(month, cumsum),
      colour = "#768692",
      linewidth = .5,
      alpha = .5
    ) +

    scale_colour_manual(
      values = c("#768692", "#005EB8"),
      breaks = c(report_year - 1, report_year),
      name = NULL
    ) +

    # highlight points
    geom_point(data = label_data, size = 5, colour = "white") +
    geom_point(data = label_data, size = 3) +

    # collision-free labels
    geom_label_repel(
      data = label_data,
      aes(label = cumsum),
      nudge_x = label_data$nudge_x,
      nudge_y = label_data$nudge_y,
      size = 5,
      fontface = "bold",
      box.padding = .3,
      point.padding = .3,
      segment.color = NA,
      show.legend = FALSE
    ) +

    scale_x_continuous(limits = c(0, 12), breaks = 1:12) +
    labs(x = "month", y = "cumulative transplant number")
}
