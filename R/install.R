#' Install or update the okf binary
#'
#' Downloads the latest pre-compiled okf binary for the current platform
#' into the package's inst/bin directory. Useful for development or when
#' the bundled binary needs updating.
#'
#' @param version Version to install (default: "latest" - gets v0.1.2)
#' @param force Re-download even if binary exists
#' @param verbose Show progress
#' @return Invisibly, path to installed binary
#' @export
#' @examples
#' \dontrun{
#' install_okf()
#' install_okf(version = "v0.1.2")
#' }
install_okf <- function(version = "latest", force = FALSE, verbose = FALSE) {
  os <- Sys.info()[["sysname"]]
  arch <- Sys.info()[["machine"]]

  bin_arch <- switch(arch,
    x86_64 = "amd64", amd64 = "amd64",
    arm64 = "arm64", aarch64 = "arm64",
    stop("Unsupported architecture: ", arch)
  )

  bin_os <- switch(os,
    Linux = "linux", Darwin = "darwin", Windows = "windows",
    stop("Unsupported OS: ", os)
  )

  if (version == "latest") version <- "v0.1.2"

  bin_name <- if (bin_os == "windows") {
    sprintf("okf-%s-%s.exe", bin_os, bin_arch)
  } else {
    sprintf("okf-%s-%s", bin_os, bin_arch)
  }

  url <- sprintf("https://github.com/okf-memory/okf-agent-memory/releases/download/%s/%s", version, bin_name)
  dest_dir <- system.file("bin", package = "rokf")
  dest <- file.path(dest_dir, bin_name)

  if (!force && file.exists(dest)) {
    if (verbose) cli::cli_inform("Binary already exists at {.path {dest}} (use force=TRUE to re-download)")
    return(invisible(dest))
  }

  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE)

  if (verbose) cli::cli_inform("Downloading {.url {url}} -> {.path {dest}}")

  tryCatch({
    utils::download.file(url, dest, mode = "wb", quiet = !verbose)
    if (bin_os != "windows") Sys.chmod(dest, "0755")
    if (verbose) cli::cli_alert_success("Installed okf binary: {.path {dest}}")
  }, error = function(e) {
    cli::cli_abort("Failed to download okf binary: {e$message}")
  })

  invisible(dest)
}

#' Check if okf binary is available
#' @param verbose Print diagnostic info
#' @return TRUE if binary found
#' @export
okf_available <- function(verbose = FALSE) {
  tryCatch({
    okf_bin(verbose = verbose)
    TRUE
  }, error = function(e) {
    if (verbose) cli::cli_inform("okf not available: {e$message}")
    FALSE
  })
}