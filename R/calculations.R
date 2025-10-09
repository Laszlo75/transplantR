# Medical Calculation Functions
# Functions for calculating medical risk indices and clinical parameters

#' Calculate KDRI 2012
#'
#' @param donor_age_year Donor age in years
#' @param donor_hypertension Donor hypertension status ("YES"/"NO")
#' @param donor_weight Donor weight in kg
#' @param donor_days_in_hospital Days in hospital
#' @param donor_adrenaline Adrenaline use ("YES"/"NO")
#' @return KDRI 2012 score
#' @export
calc_kdri2012 <- function(
    donor_age_year,
    donor_hypertension,
    donor_weight,
    donor_days_in_hospital,
    donor_adrenaline) {
  kdri2012 = exp(
    -.245 * (donor_age_year<40) +
      0.396 *(donor_age_year>=60) +
      0.265 * (donor_hypertension=="YES") +
      0.0253 * as.integer((donor_weight-75)/10) +
      0.00461 * donor_days_in_hospital +
      0.0465 * (donor_adrenaline=="YES")
  )
}

#' Calculate KDRI 2019
#'
#' @param donor_age_year Donor age in years
#' @param donor_height Donor height in cm
#' @param donor_hypertension Donor hypertension status ("YES"/"NO")
#' @param donor_sex Donor sex ("MALE"/"FEMALE")
#' @param donor_cmv Donor CMV status ("Positive"/"Negative")
#' @param donor_egfr Donor eGFR
#' @param donor_days_in_hospital Days in hospital
#' @return KDRI 2019 score
#' @export
calc_kdri2019 <- function(
    donor_age_year,
    donor_height, 
    donor_hypertension, 
    donor_sex, 
    donor_cmv, 
    donor_egfr, 
    donor_days_in_hospital) {
  kdri2019 = exp(
    0.023 * (donor_age_year - 50) +
      -0.152 * ((donor_height - 170)/10) + # as.integer
      0.149 * (donor_hypertension == "YES") +
      -0.184 * (donor_sex == "FEMALE") +
      0.190 * (donor_cmv == "Positive") +
      -0.023 * ((donor_egfr - 90)/10) + # as.integer
      0.015 * donor_days_in_hospital
  )
}

#' Calculate KDRI 2019 Category
#'
#' @param kdri_2019 KDRI 2019 score
#' @return Risk category ("Low", "Standard", "High", "Very High")
#' @importFrom dplyr case_when
#' @export
calc_kdri2019_category <- function(kdri_2019) {
  case_when(
    kdri_2019 <= 0.83 ~ "Low",
    kdri_2019 > 0.83 & kdri_2019 <= 1.35 ~ "Standard",
    kdri_2019 > 1.35 & kdri_2019 <= 1.7 ~ "High",
    kdri_2019 > 1.7 ~ "Very High"
  )
}

#' Calculate GFR from creatinine
#'
#' This formula is based on CKD-EPI 2021 equation
#'
#' @param creatinine Serum creatinine in μmol/L
#' @param age Age in years
#' @param sex Sex ("MALE"/"FEMALE")
#' @return Estimated GFR
#' @importFrom dplyr if_else case_when
#' @export
calculate_gfr <- function(creatinine, age, sex) {
  A <- if_else(sex == "FEMALE", 0.7, 0.9)
  B <- case_when(
    sex == "FEMALE" & creatinine <= 62 ~ -0.241,
    sex == "FEMALE" & creatinine > 62 ~ -1.2,
    sex == "MALE" & creatinine <= 80 ~ -0.302,
    sex == "MALE" & creatinine > 80 ~ -1.2
  )
  C <- if_else(sex == "FEMALE", 1.012, 1)
  gfr <- 142 * (creatinine / 88.5714285714286 / A)^B * (0.9938^age) * C
  return(gfr)
}