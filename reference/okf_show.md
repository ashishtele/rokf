# Show full concept details including frontmatter, body, and graph links

Show full concept details including frontmatter, body, and graph links

## Usage

``` r
okf_show(id, bundle = "knowledge", raw = FALSE, verbose = FALSE)
```

## Arguments

- id:

  Concept ID (bundle-relative path without .md, e.g.
  "architecture/layers")

- bundle:

  Path to knowledge bundle (default: "knowledge")

- raw:

  Return raw markdown file instead of parsed structure

- verbose:

  Show command output

## Value

List with id, path, type, title, description, generated, body,
raw_content (links appear as a "Related Concepts" section in body), or
raw markdown string when raw = TRUE

## Examples

``` r
if (FALSE) { # \dontrun{
okf_show("architecture/layers")
okf_show("decisions/auth-flow", raw = TRUE)
} # }
```
