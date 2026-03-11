
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geoDeltaAudit

Geographic crosswalks are directional allocations, not inverses. This
tool is the “engine” for the `shellgame` package and its purpose is to
empower analysts to make informed choices about their data
transformations with a light lift. Data and crosswalks are not
interchangeable. This tool allows you to audit yours and compare
crosswalks for your unique use case. What and how we measure are vitally
important as is our time and effort. These packages are designed to
forefront both.

Welcome to `geoDeltaAudit`, an audit package to quantify how much a
variable changes (perturbation) due to boundary
translation/transformation and allocation rules (pathway dependence).
When transforming data across and through administrative boundaries,
crosswalks are utilized to enable this administrative mismatch; for
instance, ZIP Codes do not follow county lines, ZCTAs do not align with
ZIP Codes, and so forth. The quantity of perturbation is not often
apparent, and is relegated to a footnote, percent error, or some other
quantification of real-world choice obfuscation. As researcher analysts,
data analysts, and anyone curious about populations, it is not a leap to
realize that percent error equals people. You, me, or people you care
about. And that a footnote or properly notated, acceptable loss
percentage might no longer be routinely acceptable when it does not have
to be.

This package is designed to be variable agnostic. You can swap in any
variable of your choice, from any dataset you are working with.
Ultimately I aim for this to be tool agnostic (beyond R).

## What it does

- Defines step functions for common geographic transformations (e.g.,
  ZCTA → ZIP → county)
- Runs an audit pipeline that reports:
  - fan-out and perturbation at each step
  - unmapped or duplicated units
  - Δx(VAR): change induced solely by transformation choices, holding
    the source constant

## Installation

``` r
# Install the development version from GitHub:
# install.packages("remotes")
remotes::install_github("phinnphace/geoDeltaAudit")
```
