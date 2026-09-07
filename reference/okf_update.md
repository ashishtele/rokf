# Update an existing concept

Modifies metadata or body, updates timestamps, records change in log.md.

## Usage

``` r
okf_update(
  id,
  title = NULL,
  desc = NULL,
  body = NULL,
  actor = "agent/rokf",
  bundle = "knowledge",
  no_log = FALSE,
  no_index = FALSE,
  verbose = FALSE
)
```

## Arguments

- id:

  Concept ID

- title:

  New title (optional)

- desc:

  New description (optional)

- body:

  New markdown body (optional)

- actor:

  Author string (default: "agent/rokf")

- bundle:

  Path to knowledge bundle (default: "knowledge")

- no_log:

  Skip log.md entry

- no_index:

  Skip index.md update

- verbose:

  Show command output

## Value

Updated concept metadata
