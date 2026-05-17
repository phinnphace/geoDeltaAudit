test_that("prep_hud_crosswalk errors on missing required columns", {
  bad <- data.frame(zip = "00001", county = "99999")  # missing TOT_RATIO
  expect_error(
    prep_hud_crosswalk(bad),
    "HUD crosswalk missing required columns"
  )
})