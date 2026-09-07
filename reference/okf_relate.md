# Link two concepts together

Adds a relative markdown link preventing link fragmentation and orphans.

## Usage

``` r
okf_relate(
  source_id,
  target_id,
  desc = NULL,
  actor = "agent/rokf",
  bundle = "knowledge",
  verbose = FALSE
)
```

## Arguments

- source_id:

  Source concept ID

- target_id:

  Target concept ID

- desc:

  Context/description for the link

- actor:

  Author string (default: "agent/rokf")

- bundle:

  Path to knowledge bundle (default: "knowledge")

- verbose:

  Show command output

## Value

Link metadata

## Examples

``` r
if (FALSE) { # \dontrun{
okf_relate("architecture/tooling", "architecture/layers",
           desc = "Tooling implements the 5-layer architecture")
} # }
```
