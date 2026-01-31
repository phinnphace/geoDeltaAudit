test_that("audit_transform returns expected delta on toy data", {
  acs <- data.frame(zcta = c("00001","00002"), pop = c(100, 200))

  assoc <- data.frame(ZIP_CODE = c("00010","00010"), zcta = c("00001","00002"))
  hud <- data.frame(ZIP = c("00010"), COUNTY = c("99999"), TOT_RATIO = c(1))

  steps <- list(
    step_zcta_to_zip_equal(assoc),
    step_zip_to_county_totratio(hud)
  )

  res <- audit_transform(
    df = acs,
    geo_col = "zcta",
    var_col = "pop",
    steps = steps,
    target_id = "99999"
  )

  expect_s3_class(res, "audit_result")
  expect_equal(res$baseline_total, 300)
  expect_equal(res$final_total, 300)
  expect_equal(res$delta, 0)
})
