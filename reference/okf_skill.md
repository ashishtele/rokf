# Ellmer integration: OKF Agent Memory skill for AI agents

Provides a ready-to-use skill definition that teaches an ellmer chat
agent how to use OKF Agent Memory for persistent project knowledge.

## Usage

``` r
okf_skill(bundle = "knowledge")
```

## Arguments

- bundle:

  Path to knowledge bundle (default: "knowledge")

## Value

A skill object compatible with ellmer::chat\_\*()\$register_skill()

## Examples

``` r
if (FALSE) { # \dontrun{
library(ellmer)
chat <- chat_openai()
chat$register_skill(okf_skill())
chat$chat("Search for architecture decisions in our knowledge base")
} # }
```
