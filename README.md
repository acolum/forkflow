# Analytic Multiplicity in Epidemiology

An open-source project for making analytic decision spaces visible and
reproducible in R. It has two parts:

- **`forkflow/`** &mdash; an R package to build, run, summarise, and report
  multiverse and vibration-of-effects analyses.
- **`book/`** &mdash; a Quarto book of tutorials,
  *Analytic Multiplicity in Epidemiology: A Reproducible Workflow in R*, that
  teaches the workflow end to end.

The useR! 2026 talk *Managing Analytic Multiplicity in Epidemiology* is an
excerpt from this project.

## Why

Empirical analysis involves many defensible choices: model form, covariate
selection, transformations, and missing-data rules. Reported results usually
show one analytic pathway. This project enumerates the plausible specifications,
fits a model across the whole grid, and summarises the distribution of estimates
so that robustness can be assessed and reported transparently.

## Quick start

```r
pak::pak("acolum/forkflow")
library(forkflow)
vignette("forkflow")            # the colon-cancer walkthrough
```

## Layout

```
forkflow/   R package (functions, tests, vignette, pkgdown, CI)
book/        Quarto book of tutorials
```

## Roadmap

- v0.1 workflow verbs: enumerate, fit, summarise, visualise, report.
- Peer review via rOpenSci and the Journal of Open Source Software.
- CRAN release; book chapters completed and published.
- Teaching materials for reproducible-research workshops.

## License

MIT (code) and CC BY 4.0 (book prose). Contributions welcome; please open an
issue first.

Maintainer: Alyssa Columbus &middot; alyssacolumbus.com
