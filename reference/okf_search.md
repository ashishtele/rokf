# Search knowledge concepts using BM25 ranking

Fast in-memory lexical search across concept titles, descriptions, tags,
IDs, and body text. Returns ranked results with scores.

## Usage

``` r
okf_search(query, bundle = "knowledge", limit = 10, verbose = FALSE)
```

## Arguments

- query:

  Search terms or keywords

- bundle:

  Path to knowledge bundle (default: "knowledge")

- limit:

  Maximum results to return (default: 10)

- verbose:

  Show command output

## Value

Data frame with columns: rank, score, id, type, title, description,
matches

## Examples

``` r
if (FALSE) { # \dontrun{
okf_search("architecture layers", limit = 5)
} # }
```
