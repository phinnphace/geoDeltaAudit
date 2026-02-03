#' Prepare HUD ZIP-to-County crosswalk
#'
#' Standardizes HUD crosswalk fields and enforces string IDs.
#'
#' @param data Raw HUD crosswalk data frame.
#' @param ratio_col Which HUD ratio to use (default: "TOT_RATIO").
#' @return Tibble with columns: zip, county, tot_ratio.
#' @export
prep_hud_crosswalk <- function(data, ratio_col = "TOT_RATIO") {
  data <- janitor::clean_names(data)

  ratio_col_clean <- tolower(ratio_col)

  # Hard requirements: these are HUD’s semantics
  required <- c("zip", "county", ratio_col_clean)
  missing <- setdiff(required, names(data))
  if (length(missing)) {
    stop("HUD crosswalk missing required columns: ",
         paste(missing, collapse = ", "),
         call. = FALSE)
  }

  dplyr::transmute(
    data,
    zip = stringr::str_pad(as.character(.data$zip), 5, pad = "0"),
    county = stringr::str_pad(as.character(.data$county), 5, pad = "0"),
    tot_ratio = as.numeric(.data[[ratio_col_clean]])
  )
}
