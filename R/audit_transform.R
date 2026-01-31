#' Audit a sequence of geographic transformations
#'
#' testthat::skip("Integration test: run manually (slow / uses real data).")

#' Computes Δx(VAR) between a baseline and a transformed result while returning diagnostics.
#'
#' @param df Input data frame.
#' @param geo_col Column containing geography IDs.
#' @param var_col Column containing the variable of interest.
#' @param steps A list of step functions created by step_* helpers.
#' @param baseline_filter Optional function(df) -> filtered df defining baseline membership.
#' @param target_id Optional target ID to extract after final step (e.g., "27053").
#' @return An object of class `audit_result`.
#' @export
audit_transform <- function(df, geo_col, var_col, steps, baseline_filter = NULL, target_id = NULL) {

  if (!is.null(baseline_filter)) {
    df <- baseline_filter(df)
  }

  baseline_total <- sum(as.numeric(df[[var_col]]), na.rm = TRUE)

  diags <- list()
  intermediates <- list(baseline = df)

  cur <- df
  cur_geo <- geo_col
  cur_var <- var_col

  for (i in seq_along(steps)) {
    res <- steps[[i]](cur, geo_col = cur_geo, var_col = cur_var)

    cur <- res$df_out
    cur_geo <- res$geo_col_out
    cur_var <- res$var_col_out

    diags[[paste0("step_", i)]] <- res$diag
    intermediates[[paste0("step_", i)]] <- cur
  }

  if (!is.null(target_id)) {
    cur <- dplyr::filter(cur, .data[[cur_geo]] == target_id)
  }

  final_total <- sum(as.numeric(cur[[cur_var]]), na.rm = TRUE)

  out <- list(
    baseline_total = baseline_total,
    final_total = final_total,
    delta = final_total - baseline_total,
    pct_delta = 100 * (final_total - baseline_total) / baseline_total,
    diagnostics = diags,
    intermediates = intermediates
  )

  class(out) <- "audit_result"
  out
}
