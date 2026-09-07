# Initialize a bare OKF v0.2 bundle

Creates index.md (with okf_version: "0.2") and log.md in target
directory.

## Usage

``` r
okf_init(path = "knowledge", verbose = FALSE)
```

## Arguments

- path:

  Directory to initialize (default: "knowledge")

- verbose:

  Show command output

## Value

Invisibly, the bundle path

## Examples

``` r
if (FALSE) { # \dontrun{
okf_init("knowledge")
} # }
```
