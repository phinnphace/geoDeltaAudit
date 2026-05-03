# geoDeltaAudit 0.1.0

## Initial release

* `audit_transform()` — step-based audit engine for quantifying variable change
  across arbitrary administrative boundary transformations. Accepts a list of
  `step_*` functions and returns an `audit_result` object with baseline total,
  final total, delta, and per-step diagnostics.
* `step_aggregate()` and related `step_*` helpers — composable transformation
  steps for building custom audit pipelines.
* `prep_hud_crosswalk()` and `prep_zip_zcta()` — crosswalk cleaning and
  standardization utilities.
* S3 methods for `audit_result` objects.
* Vignettes: introduction, audit walkthrough, audit workflow,
  proportionality considerations.
* Includes Hennepin County toy datasets in `inst/extdata` for running examples
  without external data dependencies.
