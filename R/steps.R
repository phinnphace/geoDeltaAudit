step_zip_to_county_totratio <- function(hud, zip_col="zip", county_col="county", weight_col="tot_ratio") {

  hud <- clean_geo_headers(
    hud,
    map = c(
      zip = "zip|zip_code|zipcode|zip5",
      county = "county|countyfp|fips|cnty|geoid",
      weight = paste0("^", weight_col, "$|tot_ratio|totratio|total_ratio|weight")
    ),
    keep = c("zip", "county", "weight")
  )

  function(df_in, geo_col, var_col) {
    ...
    joined <- dplyr::left_join(df0, hud, by="zip")
    ...
    alloc <- joined |>
      dplyr::filter(!is.na(.data$county), !is.na(.data$weight)) |>
      dplyr::mutate(var_alloc = as.numeric(.data[[var_col]]) * as.numeric(.data$weight)) |>
      ...
  }
}

    # Diagnose unmapped ZIPs
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
