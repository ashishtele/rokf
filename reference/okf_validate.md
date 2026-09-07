# Validate an OKF knowledge bundle

Runs full conformance check including graph connectivity, provenance
integrity, and optional drift/stale gates.

## Usage

``` r
okf_validate(
  bundle = "knowledge",
  strict = TRUE,
  drift = FALSE,
  stale = FALSE,
  verbose = FALSE
)
```

## Arguments

- bundle:

  Path to knowledge bundle (default: "knowledge")

- strict:

  Fail on connectivity warnings and trust gaps

- drift:

  Check index.md descriptions against concept frontmatter

- stale:

  Gate expired review dates as errors

- verbose:

  Show command output

## Value

Validation result object with errors, warnings, counts

## Note

The Windows okf binary (v0.1.2) cannot resolve relative links, so strict
validation rejects linked bundles on Windows even when the links are
correct (upstream bug). Prefer same-directory links, or validate
non-strict on Windows.

## Examples

``` r
if (FALSE) { # \dontrun{
okf_validate("knowledge", strict = TRUE)
} # }
```
