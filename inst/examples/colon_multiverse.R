# Minimal end-to-end multiverse + vibration of effects with forkflow.
# Data: survival::colon (ships with R). Run time: a few seconds.
library(forkflow)
library(survival)
library(broom)
library(furrr)
plan(multisession)

d <- colon |> dplyr::filter(etype == 2) |> tidyr::drop_na()

specs <- adjuster_sets(
  c("age", "sex", "obstruct", "perfor", "adhere", "differ", "surg")
)

results <- fit_multiverse(
  specs,
  function(spec) {
    f <- reformulate(c("node4", spec$adjusters[[1]]), "Surv(time, status)")
    coxph(f, data = d) |> tidy(conf.int = TRUE) |>
      dplyr::filter(term == "node4")
  },
  .parallel = TRUE, .seed = 2026
)

voe(results)                        # relative HR + Janus fraction
report_multiverse(results, dir = "outputs")
