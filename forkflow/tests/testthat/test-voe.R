test_that("voe summarises the distribution", {
  res <- tibble::tibble(
    estimate = c(-0.1, 0.0, 0.2, 0.35, 0.5),
    p.value  = c(0.60, 0.90, 0.20, 0.04, 0.01)
  )
  v <- voe(res)
  expect_s3_class(v, "voe_summary")
  expect_equal(v$n_models, 5L)
  expect_true(v$janus_fraction >= 0 && v$janus_fraction <= 1)
  expect_true(v$relative_ratio >= 1)
})

test_that("fit_multiverse preserves grid order and unnests", {
  specs <- adjuster_sets(c("a", "b"))
  fake_fit <- function(spec) {
    tibble::tibble(term = "x", estimate = spec$n_adjusters[[1]] + 0.1)
  }
  out <- fit_multiverse(specs, fake_fit)
  expect_equal(nrow(out), nrow(specs))
  expect_equal(out$estimate, specs$n_adjusters + 0.1)
})
