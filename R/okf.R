#' @import cli
#' @import fs
#' @import jsonlite
#' @import processx
#' @import rlang
#' @import withr
#' @importFrom magrittr %>%
#' @importFrom purrr map_dfr map_chr
#' @importFrom tibble tibble
NULL

#' Find the okf binary bundled with the package
#' @param verbose Print diagnostic info
#' @return Path to the okf binary for current platform
#' @keywords internal
okf_bin <- function(verbose = FALSE) {
  os <- Sys.info()[["sysname"]]
  arch <- Sys.info()[["machine"]]

  # Map R's arch names to our binary naming
  bin_arch <- switch(arch,
    x86_64 = "amd64",
    amd64 = "amd64",
    arm64 = "arm64",
    aarch64 = "arm64",
    stop("Unsupported architecture: ", arch)
  )

  bin_os <- switch(os,
    Linux = "linux",
    Darwin = "darwin",
    Windows = "windows",
    stop("Unsupported OS: ", os)
  )

  bin_name <- if (bin_os == "windows") {
    sprintf("okf-%s-%s.exe", bin_os, bin_arch)
  } else {
    sprintf("okf-%s-%s", bin_os, bin_arch)
  }

  # Look in inst/bin first (installed package), then system PATH
  pkg_bin <- system.file("bin", bin_name, package = "rokf", mustWork = FALSE)
  if (pkg_bin != "" && file.exists(pkg_bin)) {
    if (verbose) cli::cli_inform("Using bundled binary: {.path {pkg_bin}}")
    return(pkg_bin)
  }

  # Fallback: check PATH (for development or if user installed separately)
  sys_bin <- Sys.which("okf")
  if (sys_bin != "") {
    if (verbose) cli::cli_inform("Using system binary: {.path {sys_bin}}")
    return(sys_bin)
  }

  cli::cli_abort(c(
    "okf binary not found for {.val {bin_os}-{bin_arch}}",
    "i" = "Install the binary with {.code rokf::install_okf()} or ensure it's in PATH"
  ))
}

#' Run okf command and parse JSON output
#' @param args Command arguments
#' @param bundle Path to knowledge bundle (default: "knowledge")
#' @param verbose Show command being run
#' @return Parsed JSON or raw output
#' @keywords internal
okf_run <- function(args, bundle = "knowledge", verbose = FALSE, parse_json = TRUE) {
  bin <- okf_bin(verbose = verbose)

  # Normalize bundle path
  bundle <- fs::path_abs(bundle)

  full_args <- c(args, bundle)
  if (verbose) cli::cli_inform("Running: {.code {bin}} {paste(full_args, collapse = ' ')}")

  res <- processx::run(bin, full_args, error_on_status = FALSE, timeout = 30000)

  if (res$status != 0) {
    cli::cli_abort(c(
      "okf command failed with exit code {res$status}",
      "x" = "Command: {.code {bin} {paste(full_args, collapse = ' ')}}",
      "x" = "stderr: {res$stderr}"
    ))
  }

  out <- res$stdout

  if (parse_json && length(out) > 0 && nzchar(out)) {
    tryCatch(
      jsonlite::fromJSON(out, simplifyVector = FALSE),
      error = function(e) {
        cli::cli_warn("Failed to parse JSON output: {e$message}")
        out
      }
    )
  } else {
    out
  }
}

#' Check if a path is a valid OKF knowledge bundle
#' @param path Path to check
#' @return TRUE if valid bundle
#' @keywords internal
is_okf_bundle <- function(path = "knowledge") {
  path <- fs::path_abs(path)
  fs::file_exists(fs::path(path, "index.md")) &&
    fs::file_exists(fs::path(path, "log.md"))
}

#' Validate an OKF knowledge bundle
#'
#' Runs full conformance check including graph connectivity, provenance integrity,
#' and optional drift/stale gates.
#'
#' @param bundle Path to knowledge bundle (default: "knowledge")
#' @param strict Fail on connectivity warnings and trust gaps
#' @param drift Check index.md descriptions against concept frontmatter
#' @param stale Gate expired review dates as errors
#' @param verbose Show command output
#' @return Validation result object with errors, warnings, counts
#' @export
#' @examples
#' \dontrun{
#' okf_validate("knowledge", strict = TRUE)
#' }
okf_validate <- function(bundle = "knowledge", strict = TRUE, drift = FALSE, stale = FALSE, verbose = FALSE) {
  args <- c("validate")
  if (strict) args <- c(args, "--strict")
  if (drift) args <- c(args, "--drift")
  if (stale) args <- c(args, "--stale")
  args <- c(args, "--json")

  okf_run(args, bundle = bundle, verbose = verbose)
}

#' Search knowledge concepts using BM25 ranking
#'
#' Fast in-memory lexical search across concept titles, descriptions, tags, IDs, and body text.
#' Returns ranked results with scores.
#'
#' @param query Search terms or keywords
#' @param bundle Path to knowledge bundle (default: "knowledge")
#' @param limit Maximum results to return (default: 10)
#' @param verbose Show command output
#' @return Data frame with columns: rank, score, id, type, title, description, matches
#' @export
#' @examples
#' \dontrun{
#' okf_search("architecture layers", limit = 5)
#' }
okf_search <- function(query, bundle = "knowledge", limit = 10, verbose = FALSE) {
  args <- c("search", shQuote(query), "--limit", as.character(limit), "--json")
  res <- okf_run(args, bundle = bundle, verbose = verbose)

  if (is.list(res) && "results" %in% names(res)) {
    # Convert to tidy data frame
    results <- purrr::map_dfr(res$results, function(r) {
      tibble::tibble(
        rank = r$rank %||% NA_integer_,
        score = r$score %||% NA_real_,
        id = r$id %||% NA_character_,
        type = r$type %||% NA_character_,
        title = r$title %||% NA_character_,
        description = r$description %||% NA_character_,
        matches = paste(r$matches %||% character(), collapse = ", ")
      )
    })
    return(results)
  }

  tibble::tibble()
}

#' Show full concept details including frontmatter, body, and graph links
#'
#' @param id Concept ID (bundle-relative path without .md, e.g. "architecture/layers")
#' @param bundle Path to knowledge bundle (default: "knowledge")
#' @param raw Return raw markdown file instead of parsed structure
#' @param verbose Show command output
#' @return List with frontmatter, body, inbound/outbound links, or raw markdown string
#' @export
#' @examples
#' \dontrun{
#' okf_show("architecture/layers")
#' okf_show("decisions/auth-flow", raw = TRUE)
#' }
okf_show <- function(id, bundle = "knowledge", raw = FALSE, verbose = FALSE) {
  args <- c("show", id)
  if (raw) args <- c(args, "--raw")
  else args <- c(args, "--json")

  okf_run(args, bundle = bundle, verbose = verbose)
}

#' Create a new OKF concept with automated bookkeeping
#'
#' Creates concept file, updates parent index.md, and appends to log.md.
#'
#' @param id Concept ID (e.g., "decisions/auth-flow")
#' @param type OKF concept type (Decision, Architecture, Fact, Entity, Runbook, etc.)
#' @param title Human-readable title
#' @param desc One-sentence description
#' @param body Optional markdown body content
#' @param tags Comma-separated tags
#' @param actor Author string (default: "agent/rokf")
#' @param bundle Path to knowledge bundle (default: "knowledge")
#' @param no_log Skip appending to log.md
#' @param no_index Skip updating parent index.md
#' @param verbose Show command output
#' @return Created concept metadata
#' @export
#' @examples
#' \dontrun{
#' okf_create(
#'   "decisions/cache-ttl",
#'   type = "Decision",
#'   title = "Redis Cache TTL",
#'   desc = "Set default TTL to 300s for session data"
#' )
#' }
okf_create <- function(id, type, title, desc, body = NULL, tags = NULL,
                       actor = "agent/rokf", bundle = "knowledge",
                       no_log = FALSE, no_index = FALSE, verbose = FALSE) {
  args <- c("create", id, "--type", type, "--title", title, "--desc", desc, "--actor", actor, "--json")

  if (!is.null(body)) args <- c(args, "--body", body)
  if (!is.null(tags)) args <- c(args, "--tags", tags)
  if (no_log) args <- c(args, "--no-log")
  if (no_index) args <- c(args, "--no-index")

  okf_run(args, bundle = bundle, verbose = verbose)
}

#' Update an existing concept
#'
#' Modifies metadata or body, updates timestamps, records change in log.md.
#'
#' @param id Concept ID
#' @param title New title (optional)
#' @param desc New description (optional)
#' @param body New markdown body (optional)
#' @param actor Author string (default: "agent/rokf")
#' @param bundle Path to knowledge bundle (default: "knowledge")
#' @param no_log Skip log.md entry
#' @param no_index Skip index.md update
#' @param verbose Show command output
#' @return Updated concept metadata
#' @export
okf_update <- function(id, title = NULL, desc = NULL, body = NULL,
                       actor = "agent/rokf", bundle = "knowledge",
                       no_log = FALSE, no_index = FALSE, verbose = FALSE) {
  args <- c("update", id, "--actor", actor, "--json")

  if (!is.null(title)) args <- c(args, "--title", title)
  if (!is.null(desc)) args <- c(args, "--desc", desc)
  if (!is.null(body)) args <- c(args, "--body", body)
  if (no_log) args <- c(args, "--no-log")
  if (no_index) args <- c(args, "--no-index")

  okf_run(args, bundle = bundle, verbose = verbose)
}

#' Link two concepts together
#'
#' Adds a relative markdown link preventing link fragmentation and orphans.
#'
#' @param source_id Source concept ID
#' @param target_id Target concept ID
#' @param desc Context/description for the link
#' @param actor Author string (default: "agent/rokf")
#' @param bundle Path to knowledge bundle (default: "knowledge")
#' @param verbose Show command output
#' @return Link metadata
#' @export
#' @examples
#' \dontrun{
#' okf_relate("architecture/tooling", "architecture/layers",
#'            desc = "Tooling implements the 5-layer architecture")
#' }
okf_relate <- function(source_id, target_id, desc = NULL, actor = "agent/rokf",
                       bundle = "knowledge", verbose = FALSE) {
  args <- c("relate", source_id, target_id, "--actor", actor, "--json")
  if (!is.null(desc)) args <- c(args, "--desc", desc)

  okf_run(args, bundle = bundle, verbose = verbose)
}

#' Initialize a bare OKF v0.2 bundle
#'
#' Creates index.md (with okf_version: "0.2") and log.md in target directory.
#'
#' @param path Directory to initialize (default: "knowledge")
#' @param verbose Show command output
#' @return Invisibly, the bundle path
#' @export
#' @examples
#' \dontrun{
#' okf_init("knowledge")
#' }
okf_init <- function(path = "knowledge", verbose = FALSE) {
  args <- c("init")
  okf_run(args, bundle = path, verbose = verbose, parse_json = FALSE)
  invisible(fs::path_abs(path))
}

#' Bootstrap complete OKF Agent Memory stack into a project
#'
#' Scaffolds knowledge/, .agents/skills/okf-memory/, AGENTS.md, and Makefile.
#'
#' @param target_dir Target project directory (default: current directory)
#' @param name Project name (defaults to directory name)
#' @param overwrite_agents_md Overwrite existing AGENTS.md
#' @param no_skill Skip installing .agents/skills/okf-memory/
#' @param no_agents_md Skip creating AGENTS.md
#' @param no_makefile Skip installing Makefile
#' @param no_bundle Skip initializing knowledge/ bundle
#' @param verbose Show command output
#' @return Invisibly, the target directory
#' @export
#' @examples
#' \dontrun{
#' okf_bootstrap(".", name = "My Project")
#' }
okf_bootstrap <- function(target_dir = ".", name = NULL,
                          overwrite_agents_md = FALSE, no_skill = FALSE,
                          no_agents_md = FALSE, no_makefile = FALSE,
                          no_bundle = FALSE, verbose = FALSE) {
  args <- c("bootstrap", target_dir)

  if (!is.null(name)) args <- c(args, "--name", name)
  if (overwrite_agents_md) args <- c(args, "--overwrite-agents-md")
  if (no_skill) args <- c(args, "--no-skill")
  if (no_agents_md) args <- c(args, "--no-agents-md")
  if (no_makefile) args <- c(args, "--no-makefile")
  if (no_bundle) args <- c(args, "--no-bundle")

  okf_run(args, bundle = ".", verbose = verbose, parse_json = FALSE)
  invisible(fs::path_abs(target_dir))
}

#' Get okf version
#' @export
okf_version <- function() {
  bin <- okf_bin()
  res <- processx::run(bin, c("version"), error_on_status = FALSE)
  if (res$status == 0) {
    trimws(res$stdout)
  } else {
    cli::cli_abort("Failed to get okf version: {res$stderr}")
  }
}