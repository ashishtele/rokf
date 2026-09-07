# Install or update the okf binary

Downloads the latest pre-compiled okf binary for the current platform
into the package's inst/bin directory. Useful for development or when
the bundled binary needs updating.

## Usage

``` r
install_okf(version = "latest", force = FALSE, verbose = FALSE)
```

## Arguments

- version:

  Version to install (default: "latest" - gets v0.1.2)

- force:

  Re-download even if binary exists

- verbose:

  Show progress

## Value

Invisibly, path to installed binary

## Examples

``` r
if (FALSE) { # \dontrun{
install_okf()
install_okf(version = "v0.1.2")
} # }
```
