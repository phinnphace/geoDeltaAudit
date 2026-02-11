# ------------------------------------------------------------------------------
# data-raw/regenerate_hennepin_maps.R
# Regeneration-only script (manual)
# - NOT package code
# - NOT run during R CMD check
# - Writes two PNGs into /vignettes for use via knitr::include_graphics()
# ------------------------------------------------------------------------------

# ---- guards ------------------------------------------------------------------
if (!interactive()) {
    stop("Do not run regenerate_hennepin_maps.R non-interactively.", call. = FALSE)
}

# Require a Census API key if you make tidycensus calls.
# Put it in your shell profile once: export CENSUS_API_KEY="..."
key <- Sys.getenv("CENSUS_API_KEY")
if (identical(key, "")) {
    stop(
        "Missing CENSUS_API_KEY env var. Set it in your shell, e.g.\n",
        'export CENSUS_API_KEY="YOUR_KEY"\n',
        "Then restart R and rerun this script.",
        call. = FALSE
    )
}

# ---- config ------------------------------------------------------------------

HENNEPIN_COUNTYFP <- "053"
YEAR_ACS <- 2024
YEAR_GEOMETRY <- 2020 # ZCTA shapes are often stable/decennial

out_dir <- "vignettes"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

message("Regenerating Hennepin visuals -> ", normalizePath(out_dir))

# ---- acquisition -------------------------------------------------------------
tidycensus::census_api_key(key, install = FALSE, overwrite = TRUE)

# Pull ZCTA geometries with a single ACS variable using year 2020
# User confirmed 2020 is valid and resolves geometry availability issues
zcta_mn <- tidycensus::get_acs(
    geography = "zcta",
    variables = "B01001_001",
    year = 2020,
    survey = "acs5",
    geometry = TRUE,
    cb = TRUE
)

hennepin_county <- tigris::counties(state = "27", year = 2020, cb = TRUE) |>
    dplyr::filter(.data$STATEFP == "27", .data$COUNTYFP == HENNEPIN_COUNTYFP) # nolint: line_length_linter.

# ---- membership sets ---------------------------------------------------------
# "Geometric membership": ZCTAs that intersect the county polygon
zcta_geometric <- sf::st_intersection(zcta_mn, hennepin_county) |>
    dplyr::rename(ZCTA5CE10 = GEOID)

# "Relationship membership": from your toy ACS list shipped with geoDeltaAudit
acs_path <- system.file("extdata", "toy_acs_zcta_hennepin.csv", package = "geoDeltaAudit")

# Fallback for development (if package not installed/loaded)
if (!nzchar(acs_path)) {
    # Try local path relative to project root or script location
    local_path <- file.path("inst", "extdata", "toy_acs_zcta_hennepin.csv")
    if (file.exists(local_path)) {
        acs_path <- local_path
        message("Using local development file: ", acs_path)
    }
}

if (!nzchar(acs_path)) stop("Could not find toy ACS file in geoDeltaAudit extdata.", call. = FALSE)

acs <- readr::read_csv(acs_path, show_col_types = FALSE) |>
    dplyr::mutate(zcta = stringr::str_pad(as.character(.data$zcta), 5, pad = "0"))

zcta_baseline <- zcta_mn |>
    dplyr::mutate(GEOID = stringr::str_pad(as.character(.data$GEOID), 5, pad = "0")) |>
    dplyr::filter(.data$GEOID %in% acs$zcta) |>
    dplyr::rename(ZCTA5CE10 = GEOID)

# ---- plots -------------------------------------------------------------------
# Plot A: baseline (relationship set)
p_baseline <- shellgame::plot_baseline_zctas(
    zcta_sf = zcta_baseline,
    county_sf = hennepin_county,
    title = "Hennepin County: ZCTAs Used in Baseline"
)

# Plot B: baseline vs geometric-only extras
p_relationship <- shellgame::plot_geometric_vs_relationship(
    zcta_baseline_sf = zcta_baseline,
    zcta_geometric_sf = zcta_geometric,
    county_sf = hennepin_county,
    title = "Hennepin County: Relationship vs Geometric Membership"
)

# ---- write outputs -----------------------------------------------------------
ggplot2::ggsave(
    filename = file.path(out_dir, "baseline_hennepin.png"),
    plot = p_baseline,
    width = 8, height = 6, dpi = 300
)

ggplot2::ggsave(
    filename = file.path(out_dir, "hennepin_relationship.png"),
    plot = p_relationship,
    width = 8, height = 6, dpi = 300
)

message("Done. Wrote:")
message(" - ", file.path(out_dir, "baseline_hennepin.png"))
message(" - ", file.path(out_dir, "hennepin_relationship.png"))
