test_that("calc_kdri2012 works correctly", {
  # Test case with typical values
  result <- calc_kdri2012(
    donor_age_year = 45,
    donor_hypertension = "NO",
    donor_weight = 75,
    donor_days_in_hospital = 2,
    donor_adrenaline = "NO"
  )

  # Expected result: exp(-.245 * (45<40) + 0.396 *(45>=60) + 0.265 * 0 + 0.0253 * 0 + 0.00461 * 2 + 0.0465 * 0)
  # = exp(0.00922) ≈ 1.009264
  expect_true(is.numeric(result))
  expect_equal(result, exp(0.00461 * 2), tolerance = 1e-6)

  # Test with age < 40
  result_young <- calc_kdri2012(
    donor_age_year = 35,
    donor_hypertension = "NO",
    donor_weight = 75,
    donor_days_in_hospital = 0,
    donor_adrenaline = "NO"
  )
  expect_equal(result_young, exp(-0.245), tolerance = 1e-6)

  # Test with age >= 60
  result_old <- calc_kdri2012(
    donor_age_year = 65,
    donor_hypertension = "NO",
    donor_weight = 75,
    donor_days_in_hospital = 0,
    donor_adrenaline = "NO"
  )
  expect_equal(result_old, exp(0.396), tolerance = 1e-6)
})

test_that("calc_kdri2019 works correctly", {
  # Test case with typical values (50-year-old baseline)
  result <- calc_kdri2019(
    donor_age_year = 50,
    donor_height = 170,
    donor_hypertension = "NO",
    donor_sex = "MALE",
    donor_cmv = "Negative",
    donor_egfr = 90,
    donor_days_in_hospital = 0
  )

  # All factors should be zero for this baseline
  expect_equal(result, 1, tolerance = 1e-6)

  # Test with different values
  result2 <- calc_kdri2019(
    donor_age_year = 60,
    donor_height = 180,
    donor_hypertension = "YES",
    donor_sex = "FEMALE",
    donor_cmv = "Positive",
    donor_egfr = 80,
    donor_days_in_hospital = 3
  )

  expected <- exp(
    0.023 * (60 - 50) +
      -0.152 * ((180 - 170) / 10) +
      0.149 * 1 +
      -0.184 * 1 +
      0.190 * 1 +
      -0.023 * ((80 - 90) / 10) +
      0.015 * 3
  )

  expect_equal(result2, expected, tolerance = 1e-6)
})

test_that("calc_kdri2019_category works correctly", {
  expect_equal(calc_kdri2019_category(0.8), "Low")
  expect_equal(calc_kdri2019_category(0.83), "Low")
  expect_equal(calc_kdri2019_category(1.0), "Standard")
  expect_equal(calc_kdri2019_category(1.35), "Standard")
  expect_equal(calc_kdri2019_category(1.5), "High")
  expect_equal(calc_kdri2019_category(1.7), "High")
  expect_equal(calc_kdri2019_category(1.8), "Very High")
  expect_equal(calc_kdri2019_category(2.5), "Very High")
})

test_that("calculate_gfr works correctly", {
  # Test case for male with creatinine 80 (at threshold)
  result_male <- calculate_gfr(creatinine = 80, age = 50, sex = "MALE")

  # A = 0.9, B = -0.302, C = 1
  # gfr = 142 * (80/88.5714285714286/0.9)^-0.302 * (0.9938^50) * 1
  expected_male <- 142 * (80 / 88.5714285714286 / 0.9)^(-0.302) * (0.9938^50) * 1
  expect_equal(result_male, expected_male, tolerance = 1e-6)

  # Test case for female with creatinine 62 (at threshold)
  result_female <- calculate_gfr(creatinine = 62, age = 50, sex = "FEMALE")

  # A = 0.7, B = -0.241, C = 1.012
  expected_female <- 142 * (62 / 88.5714285714286 / 0.7)^(-0.241) * (0.9938^50) * 1.012
  expect_equal(result_female, expected_female, tolerance = 1e-6)

  # Test that results are numeric and positive
  male_gfr <- calculate_gfr(creatinine = 70, age = 40, sex = "MALE")
  female_gfr <- calculate_gfr(creatinine = 70, age = 40, sex = "FEMALE")

  expect_true(is.numeric(male_gfr))
  expect_true(is.numeric(female_gfr))
  expect_true(male_gfr > 0)
  expect_true(female_gfr > 0)
})
