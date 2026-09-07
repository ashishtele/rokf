# Tidyllm integration: OKF Agent Memory verbs

Provides tidyverse-style verbs for working with OKF knowledge from
within a tidyllm chat pipeline.

## Usage

``` r
okf_verbs(bundle = "knowledge")
```

## Arguments

- bundle:

  Path to knowledge bundle (default: "knowledge")

## Value

A list of tidyllm-compatible functions

## Examples

``` r
if (FALSE) { # \dontrun{
library(tidyllm)
okf <- okf_verbs()

# Search and use in a chat
chat_openai() %>%
  okf$search("auth architecture") %>%
  chat("Summarize these concepts") %>%
  okf$persist_as("decisions/auth-summary", type = "Fact")
} # }
```
