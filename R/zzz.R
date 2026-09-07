#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import processx
#' @import jsonlite
#' @import fs
#' @import cli
#' @import rlang
#' @import withr
## usethis namespace: end
NULL

.onLoad <- function(libname, pkgname) {
  # Ensure binaries are executable on Unix
  bin_dir <- system.file("bin", package = pkgname)
  if (dir.exists(bin_dir)) {
    bins <- list.files(bin_dir, pattern = "^okf-", full.names = TRUE)
    for (bin in bins) {
      if (!grepl("\\.exe$", bin)) {
        Sys.chmod(bin, "0755")
      }
    }
  }
  invisible()
}