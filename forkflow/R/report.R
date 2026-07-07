#' Write a reproducible summary of a multiverse
#'
#' `report_multiverse()` computes the vibration-of-effects summary, saves a
#' specification curve and a vibration-of-effects volcano, and writes the
#' summary to a CSV file. It is a convenience wrapper around [voe()],
#' [spec_curve()], and [voe_volcano()] for producing shareable artifacts.
#'
#' @param results A tibble of per-specification results, for example from
#'   [fit_multiverse()].
#' @param dir Output directory. Created if it does not exist.
#' @param prefix File-name prefix for the outputs.
#' @param estimate,p_value <[`data-masking`][dplyr::dplyr_data_masking]> columns
#'   for the estimate and its p-value.
#'
#' @return The `voe_summary` tibble, invisibly. Writes three files to `dir`.
#' @export
#' @examples
#' \dontrun{
#' report_multiverse(results, dir = "outputs")
#' }
report_multiverse <- function(results, dir = ".", prefix = "multiverse",
                              estimate = estimate, p_value = p.value) {
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)

  summary_tbl <- voe(results, {{ estimate }}, {{ p_value }})
  curve       <- spec_curve(results, {{ estimate }})
  volcano     <- voe_volcano(results, {{ estimate }}, {{ p_value }})

  ggplot2::ggsave(file.path(dir, paste0(prefix, "-spec-curve.png")),
                  curve, width = 8, height = 5, dpi = 200)
  ggplot2::ggsave(file.path(dir, paste0(prefix, "-voe-volcano.png")),
                  volcano, width = 8, height = 5, dpi = 200)
  utils::write.csv(as.data.frame(summary_tbl),
                   file.path(dir, paste0(prefix, "-voe-summary.csv")),
                   row.names = FALSE)

  message("forkflow: wrote ", prefix,
          "-spec-curve.png, ", prefix, "-voe-volcano.png, and ",
          prefix, "-voe-summary.csv to ", normalizePath(dir))
  invisible(summary_tbl)
}
