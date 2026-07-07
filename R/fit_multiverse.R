#' Fit a model across every specification
#'
#' `fit_multiverse()` applies a fitting function to each row of a specification
#' grid and returns a tidy tibble with one row per returned model term per
#' specification. Because the fits are independent, they can run in parallel via
#' \pkg{furrr} when `.parallel = TRUE`.
#'
#' @param specs A specification grid, for example from [spec_grid()] or
#'   [adjuster_sets()].
#' @param .f A function (or a purrr-style formula) applied to each
#'   specification. It receives one row of `specs` as a one-row tibble; access
#'   columns with `spec$col`, for example `spec$adjusters[[1]]` for the output
#'   of [adjuster_sets()]. It should return a tibble, for example from
#'   [broom::tidy()].
#' @param ... Additional arguments passed on to `.f`.
#' @param .parallel Logical; fit across cores with \pkg{furrr}. Set a plan first
#'   with [future::plan()].
#' @param .seed Optional integer seed for reproducible parallel fits.
#'
#' @return `specs` with the tidy model output unnested: one row per returned
#'   term per specification, in the original grid order.
#' @export
#' @examples
#' \dontrun{
#' specs <- adjuster_sets(c("age", "sex", "bmi"))
#' fit_multiverse(specs, function(spec) {
#'   f <- reformulate(c("exposure", spec$adjusters[[1]]), "outcome")
#'   broom::tidy(lm(f, data = df), conf.int = TRUE)
#' })
#' }
fit_multiverse <- function(specs, .f, ..., .parallel = FALSE, .seed = NULL) {
  .f <- rlang::as_function(.f)
  idx <- seq_len(nrow(specs))
  rows <- purrr::map(idx, function(i) specs[i, , drop = FALSE])

  if (isTRUE(.parallel)) {
    if (!requireNamespace("furrr", quietly = TRUE)) {
      rlang::abort("`.parallel = TRUE` requires the furrr package.")
    }
    opts <- furrr::furrr_options(seed = .seed %||% TRUE)
    out <- furrr::future_map(rows, .f, ..., .options = opts)
  } else {
    out <- purrr::map(rows, .f, ...)
  }

  specs[[".out"]] <- out
  tidyr::unnest(specs, ".out")
}
