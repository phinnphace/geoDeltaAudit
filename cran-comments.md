## Update

This is an update to geoDeltaAudit 0.1.0 on CRAN. Version 0.1.1 adds the
data-preparation vignette and clarifies the transformation documentation.
The R code and tests are unchanged.

## Test environments

* macOS, R 4.5.1: `R CMD check --as-cran` completed with 0 ERRORs,
  0 WARNINGs, and 2 NOTEs.
* R-hub Ubuntu, R release and R-devel (clang): both check workflows completed
  successfully: https://github.com/r-hub2/automatic-chimpanzee-geoDeltaAudit/actions/runs/39159379117

## Local check NOTEs

* CRAN's URL check received HTTP 202 from the HUD USPS crosswalk page
  (https://www.huduser.gov/portal/datasets/usps_crosswalk.html). The page is
  reachable in a browser; the server's response to automated requests varies.
* HTML manual validation was skipped because this Mac's HTML Tidy is too old.

## Reverse dependencies

None.
