test_that("clean_geo_headers errors on missing required column", {
  df <- data.frame(state = "OH", value = 1)
  map <- c(zip = "zip|zcta")
  expect_error(
    clean_geo_headers(df, map = map, keep = "zip"),
    "Missing required column for 'zip'"
  )
})