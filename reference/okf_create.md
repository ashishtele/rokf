# Create a new OKF concept with automated bookkeeping

Creates concept file, updates parent index.md, and appends to log.md.

## Usage

``` r
okf_create(
  id,
  type,
  title,
  desc,
  body = NULL,
  tags = NULL,
  actor = "agent/rokf",
  bundle = "knowledge",
  no_log = FALSE,
  no_index = FALSE,
  verbose = FALSE
)
```

## Arguments

- id:

  Concept ID (e.g., "decisions/auth-flow")

- type:

  OKF concept type (Decision, Architecture, Fact, Entity, Runbook, etc.)

- title:

  Human-readable title

- desc:

  One-sentence description

- body:

  Optional markdown body content

- tags:

  Comma-separated tags

- actor:

  Author string (default: "agent/rokf")

- bundle:

  Path to knowledge bundle (default: "knowledge")

- no_log:

  Skip appending to log.md

- no_index:

  Skip updating parent index.md

- verbose:

  Show command output

## Value

Created concept metadata

## Examples

``` r
if (FALSE) { # \dontrun{
okf_create(
  "decisions/cache-ttl",
  type = "Decision",
  title = "Redis Cache TTL",
  desc = "Set default TTL to 300s for session data"
)
} # }
```
