# ------------------------------------------------------------------------------
# data-raw/process_crosswalks.R
# ------------------------------------------------------------------------------
# Purpose:
# This script reads the raw HUD and ZCTA crosswalk CSV files, performs any
# necessary cleanup, and saves them as internal package data objects.
#
# Instructions:
# 1. Place 'ZiptoZCTA-Table 1.csv' and 'HUD_ZIP_COUNTY.csv' in the 'data-raw/' folder.
# 2. Run this script interactively (e.g., Source or Run in RStudio).
# ------------------------------------------------------------------------------

# Ensure we are in the package root or can find the files
# Adjust paths if necessary, but assuming script is run from project root
# and files are in data-raw/

if (!interactive()) {
    stop("Please run this script interactively.", call. = FALSE)
}

# --- Paths to raw files ---
# We use 'data-raw' prefix relative to package root
zip_zcta_path <- file.path("data-raw", "ZiptoZCTA-Table 1.csv")
hud_path <- file.path("data-raw", "HUD_ZIP_COUNTY.csv")

# Check if files exist
if (!file.exists(zip_zcta_path)) {
    stop("Could not find ", zip_zcta_path, ". Please make sure the file is in 'data-raw/' folder.")
}
if (!file.exists(hud_path)) {
    stop("Could not find ", hud_path, ". Please make sure the file is in 'data-raw/' folder.")
}

# --- Load and Process Data ---

# 1. ZIP to ZCTA Crosswalk
message("Processing ZIP to ZCTA crosswalk...")
zip_zcta_raw <- read.csv(zip_zcta_path, stringsAsFactors = FALSE)

# (Optional) Add cleaning steps here if needed, e.g., padding ZIP codes
# zip_zcta_raw$ZIP_CODE <- sprintf("%05d", zip_zcta_raw$ZIP_CODE)

# 2. HUD Crosswalk
message("Processing HUD crosswalk...")
hud_raw <- read.csv(hud_path, stringsAsFactors = FALSE)

# (Optional) Add cleaning steps here


# --- Save to Package ---
# This will save the objects 'zip_zcta_raw' and 'hud_raw' to 'data/zip_zcta_raw.rda' and 'data/hud_raw.rda'
message("Saving data to package...")
usethis::use_data(zip_zcta_raw, hud_raw, overwrite = TRUE)

message("Done! Data processed and saved. You can now use data('zip_zcta_raw') and data('hud_raw') in your package.")
