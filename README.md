# forkflow

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/acolum/forkflow/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/acolum/forkflow/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

**Build, run, summarise, and report multiverse and vibration-of-effects
analyses in R.** Empirical analysis involves many defensible choices, model
form, covariate selection, transformations, and missing-data rules among them.
`forkflow` makes that decision space explicit: enumerate the specifications,
fit a model across the whole grid, and summarise the distribution of estimates
instead of reporting a single analytic pathway.

`forkflow` is the engine behind the book
*Analytic Multiplicity in Epidemiology: A Reproducible Workflow in R*, and this
talk and its examples are drawn from that project.

## Documentation

- Package reference site: <https://acolum.github.io/forkflow/>
- Companion book: <https://acolum.github.io/forkflow/book/>

Both are built and published automatically by the `pkgdown` GitHub Action on
every push to `main`. The first time, enable it once under
**Settings -> Pages -> Build and deployment -> Source: Deploy from a branch**,
and choose the `gh-pages` branch with the `/ (root)` folder. The site links
appear after the first successful run.

## Installation

```r
# the package (fast; no vignette):
# install.packages("pak")
pak::pak("acolum/forkflow")

# the package with the vignette built (needs remotes + knitr/rmarkdown):
# install.packages("remotes")
remotes::install_github("acolum/forkflow", build_vignettes = TRUE)
```

After the second install, open the walkthrough with `vignette("forkflow")`.
`pak` does not build vignettes on GitHub installs, which is why the vignette is
only available after the `build_vignettes = TRUE` route.

## The workflow

| Step | Function | What it does |
|------|----------|--------------|
| Enumerate | `spec_grid()`, `adjuster_sets()` | Turn analytic choices into a grid, one row per specification |
| Fit | `fit_multiverse()` | Fit a model across the whole grid, optionally in parallel via furrr |
| Summarise | `voe()` | Relative ratio, Janus fraction, and the spread of estimates |
| Visualise | `spec_curve()`, `voe_volcano()` | Specification curve and vibration-of-effects volcano |
| Report | `report_multiverse()` | Save shareable figures and a summary table |

## Quick example

```r
library(forkflow)
library(survival)
library(broom)

d <- colon |> dplyr::filter(etype == 2) |> tidyr::drop_na()

specs <- adjuster_sets(
  c("age", "sex", "obstruct", "perfor", "adhere", "differ", "surg")
)

results <- fit_multiverse(specs, function(spec) {
  f <- reformulate(c("node4", spec$adjusters[[1]]), "Surv(time, status)")
  coxph(f, data = d) |> tidy(conf.int = TRUE) |>
    dplyr::filter(term == "node4")
})

voe(results)          # relative hazard ratio + Janus fraction
spec_curve(results)   # the distribution, ranked
voe_volcano(results, colour = n_adjusters)
```

## Method background

- Steegen, Tuerlinckx, Gelman and Vanpaemel (2016). Increasing transparency
  through a multiverse analysis. *Perspectives on Psychological Science*.
- Patel, Burford and Ioannidis (2015). Assessment of vibration of effects due
  to model specification. *Journal of Clinical Epidemiology*.
- Klau, Hoffmann, Patel, Ioannidis and Boulesteix (2021). Examining the
  robustness of observational associations with the vibration of effects
  framework. *International Journal of Epidemiology*.

## Companion book

This repository also contains a Quarto book of tutorials in `book/`,
*Analytic Multiplicity in Epidemiology: A Reproducible Workflow in R*. Render it
with:

```bash
quarto render book
```

The book is excluded from the package build (see `.Rbuildignore`), so it does
not affect installation.

## Contributing

Contributions are welcome. `forkflow` follows tidyverse conventions and aims for
review by rOpenSci and the Journal of Open Source Software. Please open an issue
before a large pull request.

## Citation

```r
citation("forkflow")
```
