#' Enumerate a multiverse specification grid
#'
#' `spec_grid()` builds a tibble in which each row is one fully specified,
#' defensible analysis. Every named argument is one analytic choice; the grid
#' is the Cartesian product of all choices (via [tidyr::expand_grid()]), with a
#' leading `.spec_id` column added.
#'
#' @param ... Named analytic choices. Each value is a vector or list of the
#'   options for that choice, for example `adjust_age = c(TRUE, FALSE)`.
#'
#' @return A [tibble][tibble::tibble] with one row per specification and a
#'   leading integer column `.spec_id`.
#' @seealso [adjuster_sets()] for the common case of toggling covariates.
#' @export
#' @examples
#' spec_grid(
#'   adjust_age = c(TRUE, FALSE),
#'   transform  = c("identity", "log"),
#'   missing    = c("complete", "impute")
#' )
spec_grid <- function(...) {
  choices <- rlang::list2(...)
  if (length(choices) == 0) {
    rlang::abort("Supply at least one named analytic choice.")
  }
  if (!rlang::is_named(choices)) {
    rlang::abort("All analytic choices must be named.")
  }
  grid <- tidyr::expand_grid(!!!choices)
  tibble::add_column(grid, .spec_id = seq_len(nrow(grid)), .before = 1L)
}

#' Enumerate every adjustment set from a pool of covariates
#'
#' A common multiverse in observational epidemiology varies which covariates
#' adjust a target association. `adjuster_sets()` returns every subset of
#' `vars`, from the empty set to the full set, giving `2^length(vars)`
#' specifications by default.
#'
#' @param vars Character vector of candidate adjustment covariates.
#' @param min_size,max_size Optional integer bounds on subset size.
#'
#' @return A tibble with columns `.spec_id`, `adjusters` (a list column of
#'   character vectors), and `n_adjusters`.
#' @seealso [spec_grid()], [fit_multiverse()].
#' @export
#' @examples
#' adjuster_sets(c("age", "sex", "bmi"))
adjuster_sets <- function(vars, min_size = 0L, max_size = length(vars)) {
  vars <- unique(as.character(vars))
  sizes <- seq.int(min_size, max_size)
  sets <- unlist(
    lapply(sizes, function(k) utils::combn(vars, k, simplify = FALSE)),
    recursive = FALSE
  )
  tibble::tibble(
    .spec_id    = seq_along(sets),
    adjusters   = sets,
    n_adjusters = lengths(sets)
  )
}
