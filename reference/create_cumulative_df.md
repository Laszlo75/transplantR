# Monthly cumulative transplant counts

Aggregates transplant-level data into a tidy, month-by-month cumulative
series for each calendar year.

## Usage

``` r
create_cumulative_df(df, report_year = NULL, report_month = NULL)
```

## Arguments

- df:

  A data frame or tibble containing **one row per transplant** and a
  `Date` column named `tx_date`.

- report_year:

  (numeric) Calendar year of the report (e.g. `2025`).

- report_month:

  (integer, 0–12) Final month to include in the year-to-date comparison.
  Use `0` for a baseline plot.

## Value

A tibble with columns:

- year:

  integer — calendar year

- month:

  integer — 0 = baseline, 1–12 = January-December

- cumsum:

  numeric — cumulative transplant count at the end of `month`

## Details

- Adds a **month 0** row (value = 0) so every yearly line starts at
  zero.

- Ensures every month 0–12 is present, forward-filling missing values so
  the output is plot-ready.

- Trims future months beyond the reporting cut-off.

## Examples

``` r
if (FALSE) { # \dontrun{
cum_df <- create_cumulative_df(transplants,
                               report_year  = 2025,
                               report_month = 4)
} # }
```
