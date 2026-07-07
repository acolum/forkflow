test_that("spec_grid enumerates the Cartesian product", {
  g <- spec_grid(a = c(TRUE, FALSE), b = c("x", "y", "z"))
  expect_equal(nrow(g), 6L)
  expect_true(".spec_id" %in% names(g))
  expect_equal(g$.spec_id, 1:6)
})

test_that("spec_grid rejects unnamed choices", {
  expect_error(spec_grid(c(1, 2)), "named")
})

test_that("adjuster_sets returns 2^n subsets", {
  s <- adjuster_sets(c("age", "sex", "bmi"))
  expect_equal(nrow(s), 8L)
  expect_equal(s$n_adjusters[[1]], 0L)
  expect_equal(max(s$n_adjusters), 3L)
})
