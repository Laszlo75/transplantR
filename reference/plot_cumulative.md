# Cumulative transplant comparison plot

Generates a year-over-year cumulative line chart for transplant
activity, visually contrasting the current report year against the
previous year.

## Usage

``` r
plot_cumulative(cumulative_data, report_year = NULL, report_month = NULL)
```

## Arguments

- cumulative_data:

  A data frame (or tibble) returned by
  [`create_cumulative_df()`](https://laszlo75.github.io/transplantR/reference/create_cumulative_df.md),
  containing `year`, `month`, and `cumsum` columns.

- report_year:

  (numeric) Calendar year of the current report (e.g. `2025`).

- report_month:

  (integer, 0–12) Final month shown for the year-to-date comparison.

## Value

A **`ggplot`** object. Print it to display, or add layers / themes as
needed.

## Details

Key features

- **Vertical cut-off line** at the reporting month.

- **Automatic labelling** (via *ggrepel*) that places the higher value
  above the point, the lower below it, and nudges labels away from the
  y-axis when counts are near zero.

- A faint “tail” segment shows how last year continued after the current
  cut-off, providing instant context on catch-up or lag.

## Dependencies

Relies on **ggplot2**, **dplyr**, and **ggrepel**.

## Examples

``` r
if (FALSE) { # \dontrun{
cum_df <- create_cumulative_df(transplants,
                               report_year  = 2025,
                               report_month = 4)

plot_cumulative(cum_df,
                report_year  = 2025,
                report_month = 4)
} # }
```
