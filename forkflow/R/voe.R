#' Summarise the vibration of effects across a multiverse
#'
#' Given per-specification estimates, `voe()` returns the distribution summaries
#' used in vibration-of-effects analysis (Patel, Burford and Ioannidis, 2015):
#' the median effect, the 1st and 99th percentiles, the relative ratio (the
#' 99th divided by the 1st percentile of the exponentiated effect, for example
#' the relative hazard or odds ratio), the Janus fraction (the share of
#' estimates above zero, so a value near 0 or 1 means the sign is stable), and
#' the proportion of specifications reaching a significance threshold.
#'
#' @param results A tibble of per-specification results, for example from
#'   [fit_multiverse()].
#' @param estimate <[`data-masking`][dplyr::dplyr_data_masking]> column of
#'   effect estimates on the model link scale, for example a log hazard ratio.
#' @param p_value <[`data-masking`][dplyr::dplyr_data_masking]> column of
#'   p-values.
#' @param exponentiate Logical; exponentiate the effect before forming the
#'   relative ratio. Use `TRUE` for log-scale effects such as Cox or logistic
#'   models.
#' @param alpha Significance threshold for `prop_significant`.
#'
#' @return A one-row tibble of vibration-of-effects summaries with class
#'   `voe_summary`.
#' @references
#' Patel CJ, Burford B, Ioannidis JPA (2015). Assessment of vibration of effects
#' due to model specification can demonstrate the instability of observational
#' associations. *Journal of Clinical Epidemiology*, 68(9), 1046-1058.
#' @export
#' @examples
#' res <- tibble::tibble(
#'   estimate = c(-0.1, 0.0, 0.2, 0.35, 0.5),
#'   p.value  = c(0.60, 0.90, 0.20, 0.04, 0.01)
#' )
#' voe(res)
voe <- function(results, estimate = estimate, p_value = p.value,
                exponentiate = TRUE, alpha = 0.05) {
  est <- dplyr::pull(results, {{ estimate }})
  pv  <- dplyr::pull(results, {{ p_value }})
  eff <- if (exponentiate) exp(est) else est
  q <- quantile(eff, c(0.01, 0.99), names = FALSE, na.rm = TRUE)

  out <- tibble::tibble(
    n_models         = length(est),
    median_effect    = median(eff, na.rm = TRUE),
    lower_p01        = q[[1]],
    upper_p99        = q[[2]],
    relative_ratio   = q[[2]] / q[[1]],
    janus_fraction   = mean(est > 0, na.rm = TRUE),
    prop_significant = mean(pv < alpha, na.rm = TRUE)
  )
  class(out) <- c("voe_summary", class(out))
  out
}

#' @export
print.voe_summary <- function(x, ...) {
  cat("<vibration of effects>\n")
  cat(sprintf("  models             : %d\n", x$n_models))
  cat(sprintf("  median effect      : %.3f\n", x$median_effect))
  cat(sprintf("  relative ratio     : %.2f   (p99 / p01)\n", x$relative_ratio))
  cat(sprintf("  Janus fraction     : %.2f   (0 or 1 = stable sign)\n", x$janus_fraction))
  cat(sprintf("  prop. significant  : %.2f\n", x$prop_significant))
  invisible(x)
}
