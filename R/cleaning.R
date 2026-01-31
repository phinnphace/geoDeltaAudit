#' Normalize messy geography headers to standard names
#'
#' @param df A data frame with geography columns.
#' @param map Named character vector: names are standardized outputs,
#'   values are regex patterns of accepted input names.
#' @param keep Character vector of standardized columns to keep.
#' @return A tibble with standardized names.
#' @export
clean_geo_headers <- function(df, map, keep) {
  df0 <- janitor::clean_names(df)
  nms <- names(df0)

  pick_one <- function(pattern) {
    hits <- nms[stringr::str_detect(nms, stringr::regex(pattern, ignore_case = TRUE))]
    if (length(hits) == 0) NA_character_ else hits[[1]]
  }

  rename_list <- list()
  for (new_name in names(map)) {
    old_name <- pick_one(map[[new_name]])
    if (is.na(old_name)) {
      rlang::abort(paste0(
        "Missing required column for '", new_name, "'. Saw: ",
        paste(nms, collapse = ", ")
      ))
    }
    # Only rename when needed (idempotent)
    if (old_name != new_name) {
      rename_list[[new_name]] <- rlang::sym(old_name)
    }
  }

  out <- df0
  if (length(rename_list) > 0) {
    out <- dplyr::rename(out, !!!rename_list)
  }

  out <- dplyr::select(out, dplyr::all_of(keep))
  tibble::as_tibble(out)
}
