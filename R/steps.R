# Internal helper: coerce ID keys to character and pad to 5 digits
#' @noRd
.as_chr5 <- function(x) {
  stringr::str_pad(as.character(x), 5, pad = "0")
}

#' Step: ZCTA -> ZIP using equal-share allocation
#'
#' Given an association table mapping ZCTAs to ZIPs, allocate each ZCTA's
#' values equally across its associated ZIPs.
#'
#' @param assoc A data frame containing ZCTA-ZIP associations.
#' @param zcta_col Column name in `assoc` containing ZCTA IDs (ignored if clean_geo_headers matches).
#' @param zip_col Column name in `assoc` containing ZIP IDs (ignored if clean_geo_headers matches).
#' @return A step function suitable for `audit_transform()`.
#' @export
step_zcta_to_zip_equal <- function(assoc, zcta_col = "zcta", zip_col = "zip") {

  # Standardize assoc headers to {zcta, zip}
  assoc <- clean_geo_headers(
    assoc,
    map = c(
      zcta = "zcta|zcta5|zcta5ce10|geoid10|geoid",
      zip  = "zip|zip_code|zipcode|zip5"
    ),
    keep = c("zcta", "zip")
  ) |>
    dplyr::mutate(
      zcta = .as_chr5(.data$zcta),
      zip  = .as_chr5(.data$zip)
    ) |>
    dplyr::distinct(.data$zcta, .data$zip)

  function(df_in, geo_col, var_col) {

    # Standardize df_in to {zcta, <var_col>}
    df0 <- clean_geo_headers(
      df_in,
      map = c(zcta = geo_col),
      keep = c("zcta", var_col)
    ) |>
      dplyr::mutate(zcta = .as_chr5(.data$zcta))

    # Attach ZIPs to each ZCTA
    joined <- dplyr::left_join(df0, assoc, by = "zcta")

    # Diagnose unmapped ZCTAs
    unmapped <- joined |>
      dplyr::filter(is.na(.data$zip)) |>
      dplyr::distinct(.data$zcta) |>
      nrow()

    # Count ZIPs per ZCTA for equal-share allocation
    denom <- joined |>
      dplyr::filter(!is.na(.data$zip)) |>
      dplyr::count(.data$zcta, name = "n_zip")

    alloc <- joined |>
      dplyr::filter(!is.na(.data$zip)) |>
      dplyr::left_join(denom, by = "zcta") |>
      dplyr::mutate(
        w = 1 / .data$n_zip,
        var_alloc = as.numeric(.data[[var_col]]) * .data$w
      ) |>
      dplyr::group_by(.data$zip) |>
      dplyr::summarise(var_alloc = sum(.data$var_alloc, na.rm = TRUE), .groups = "drop")

    diag <- list(
      step = "zcta_to_zip_equal",
      n_rows_out = nrow(alloc),
      n_zctas_in = dplyr::n_distinct(df0$zcta),
      n_zips_out = dplyr::n_distinct(alloc$zip),
      n_unmapped_zctas = unmapped,
      zips_per_zcta = if (nrow(denom) == 0) NA_integer_ else denom$n_zip
    )

    list(
      df_out = alloc,
      geo_col_out = "zip",
      var_col_out = "var_alloc",
      diag = diag
    )
  }
}

#' Step: ZIP -> COUNTY using HUD TOT_RATIO
#'
#' Allocate ZIP-level values to counties using HUD's TOT_RATIO weights.
#'
#' @param hud A data frame containing ZIP-to-county weights.
#' @param zip_col Column name for ZIP (kept for API symmetry; cleaning is robust).
#' @param county_col Column name for county (FIPS) (kept for API symmetry).
#' @param weight_col Column name for the weight (default "tot_ratio") (kept for API symmetry).
#' @return A step function suitable for `audit_transform()`.
#' @export
step_zip_to_county_totratio <- function(
    hud,
    zip_col = "zip",
    county_col = "county",
    weight_col = "tot_ratio"
) {

  # Enforce schema + types (pads ZIP, keeps county as character, numeric ratio)
  # NOTE: prep_hud_crosswalk should return columns {zip, county, tot_ratio}
  hud <- prep_hud_crosswalk(hud, ratio_col = "TOT_RATIO") |>
    dplyr::mutate(
      zip = .as_chr5(.data$zip),
      county = as.character(.data$county),
      tot_ratio = as.numeric(.data$tot_ratio)
    ) |>
    dplyr::filter(!is.na(.data$zip), !is.na(.data$county), !is.na(.data$tot_ratio)) |>
    dplyr::distinct(.data$zip, .data$county, .data$tot_ratio)

  function(df_in, geo_col, var_col) {

    df0 <- clean_geo_headers(
      df_in,
      map = c(zip = geo_col),
      keep = c("zip", var_col)
    ) |>
      dplyr::mutate(zip = .as_chr5(.data$zip))

    joined <- dplyr::left_join(df0, hud, by = "zip")

    unmapped <- joined |>
      dplyr::filter(is.na(.data$county) | is.na(.data$tot_ratio)) |>
      dplyr::distinct(.data$zip) |>
      nrow()

    alloc <- joined |>
      dplyr::filter(!is.na(.data$county), !is.na(.data$tot_ratio)) |>
      dplyr::mutate(var_alloc = as.numeric(.data[[var_col]]) * as.numeric(.data$tot_ratio)) |>
      dplyr::group_by(.data$county) |>
      dplyr::summarise(var_alloc = sum(.data$var_alloc, na.rm = TRUE), .groups = "drop")

    diag <- list(
      step = "zip_to_county_totratio",
      n_rows_out = nrow(alloc),
      n_zips_in = dplyr::n_distinct(df0$zip),
      n_counties_out = dplyr::n_distinct(alloc$county),
      n_unmapped_zips = unmapped
    )

    list(
      df_out = alloc,
      geo_col_out = "county",
      var_col_out = "var_alloc",
      diag = diag
    )
  }
}
