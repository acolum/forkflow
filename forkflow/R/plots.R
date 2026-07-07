#' Specification curve plot
#'
#' Draws a specification curve: every estimate sorted from smallest to largest,
#' with confidence intervals, coloured by whether the interval excludes zero.
#'
#' @param results A tibble of per-specification results with estimate and
#'   confidence-interval columns, for example from [fit_multiverse()].
#' @param estimate,conf_low,conf_high
#'   <[`data-masking`][dplyr::dplyr_data_masking]> columns for the estimate and
#'   its confidence bounds.
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' \dontrun{
#' spec_curve(results)
#' }
spec_curve <- function(results, estimate = estimate,
                       conf_low = conf.low, conf_high = conf.high) {
  df <- dplyr::mutate(
    results,
    .estimate = {{ estimate }},
    .low      = {{ conf_low }},
    .high     = {{ conf_high }}
  )
  df <- dplyr::arrange(df, .data$.estimate)
  df$.rank <- seq_len(nrow(df))
  df$.sig  <- df$.low > 0 | df$.high < 0

  ggplot2::ggplot(
    df, ggplot2::aes(.data$.rank, .data$.estimate, colour = .data$.sig)
  ) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed") +
    ggplot2::geom_linerange(
      ggplot2::aes(ymin = .data$.low, ymax = .data$.high), alpha = 0.5
    ) +
    ggplot2::geom_point(size = 1.5) +
    ggplot2::scale_colour_manual(
      values = c(`FALSE` = "grey60", `TRUE` = "#0072B2"),
      labels = c("CI includes 0", "CI excludes 0"), name = NULL
    ) +
    ggplot2::labs(x = "Specifications, ranked by estimate", y = "Estimate") +
    ggplot2::theme_minimal(base_size = 12)
}

#' Vibration-of-effects volcano plot
#'
#' Plots the exponentiated effect (for example a hazard ratio) against
#' `-log10(p)` for every specification, so the cloud shows how much the
#' association vibrates as the model changes.
#'
#' @param results A tibble of per-specification results.
#' @param effect,p_value <[`data-masking`][dplyr::dplyr_data_masking]> columns
#'   for the estimate (link scale) and its p-value.
#' @param colour Optional <[`data-masking`][dplyr::dplyr_data_masking]> column
#'   mapped to point colour, for example `n_adjusters`.
#' @param exponentiate Logical; exponentiate the effect for the x-axis.
#'
#' @return A \pkg{ggplot2} object.
#' @export
#' @examples
#' \dontrun{
#' voe_volcano(results, colour = n_adjusters)
#' }
voe_volcano <- function(results, effect = estimate, p_value = p.value,
                        colour = NULL, exponentiate = TRUE) {
  df <- dplyr::mutate(
    results,
    .eff     = if (exponentiate) exp({{ effect }}) else {{ effect }},
    .neglogp = -log10({{ p_value }})
  )
  col_q <- rlang::enquo(colour)

  p <- ggplot2::ggplot(df, ggplot2::aes(.data$.eff, .data$.neglogp))
  if (!rlang::quo_is_null(col_q)) {
    p <- p +
      ggplot2::geom_point(ggplot2::aes(colour = !!col_q), size = 1.6, alpha = 0.85) +
      ggplot2::scale_colour_viridis_c()
  } else {
    p <- p + ggplot2::geom_point(size = 1.6, alpha = 0.85, colour = "#0072B2")
  }

  xref <- if (exponentiate) 1 else 0
  p +
    ggplot2::geom_vline(xintercept = xref, linetype = "dashed") +
    ggplot2::geom_hline(yintercept = -log10(0.05), colour = "#D55E00") +
    ggplot2::labs(
      x = if (exponentiate) "Exponentiated effect (e.g. hazard ratio)" else "Effect",
      y = expression(-log[10](p))
    ) +
    ggplot2::theme_minimal(base_size = 12)
}
