# rokf: R Interface to OKF Agent Memory

## The problem

AI agent conversations are ephemeral. When the context window resets,
architectural decisions, domain discoveries, and operational facts are
lost. OKF Agent Memory persists that knowledge as plain Markdown + YAML
inside your repository (`knowledge/`), so it is Git-tracked,
human-readable, and auditable via `git diff`. Retrieval is local BM25 —
no vector database, no embeddings, no per-query API cost.

`rokf` is the R interface to the `okf` CLI. The package vendors
pre-compiled binaries, so there are no system dependencies to install.

## The workflow: Read — Work — Remember

Every agent session follows one loop: **search before you create**, do
the work, persist what you learned, validate.

### 1. Initialize a bundle

``` r

okf_init(kb)
rokf:::is_okf_bundle(kb)
#> [1] TRUE
```

### 2. Create concepts (only after searching)

``` r

okf_create("decisions/cache-ttl", bundle = kb,
  type  = "Decision",
  title = "Redis Cache TTL",
  desc  = "Default TTL 300s for session data")
#> $concept_id
#> [1] "decisions/cache-ttl"
#> 
#> $path
#> [1] "decisions/cache-ttl.md"
#> 
#> $status
#> [1] "success"

okf_create("architecture/sessions", bundle = kb,
  type  = "Architecture",
  title = "Session Store",
  desc  = "Sessions live in Redis behind the API gateway")
#> $concept_id
#> [1] "architecture/sessions"
#> 
#> $path
#> [1] "architecture/sessions.md"
#> 
#> $status
#> [1] "success"
```

### 3. Search existing knowledge

``` r

okf_search("session TTL", bundle = kb, limit = 5)
#> # A tibble: 2 × 7
#>    rank score id                    type         title       description matches
#>   <int> <dbl> <chr>                 <chr>        <chr>       <chr>       <chr>  
#> 1     1  6.35 decisions/cache-ttl   Decision     Redis Cach… Default TT… descri…
#> 2     2  1.55 architecture/sessions Architecture Session St… Sessions l… title,…
```

Search returns a tibble (`rank`, `score`, `id`, `type`, `title`,
`description`, `matches`) — empty when nothing is relevant.

### 4. Read a concept in full

``` r

concept <- okf_show("decisions/cache-ttl", bundle = kb)
concept$title
#> [1] "Redis Cache TTL"
concept$description
#> [1] "Default TTL 300s for session data"
```

### 5. Link related concepts

Links are stored as relative Markdown links inside the source concept’s
body, so the graph can never fragment into orphans:

``` r

okf_relate("decisions/cache-ttl", "architecture/sessions", bundle = kb,
  desc = "TTL applies to the session store")
#> $source
#> [1] "decisions/cache-ttl"
#> 
#> $status
#> [1] "success"
#> 
#> $target
#> [1] "architecture/sessions"

# The link is a relative Markdown link in the source concept's body
cat(okf_show("decisions/cache-ttl", bundle = kb)$body)
#> 
#> # Related Concepts
#> - [Session Store](../architecture/sessions.md): TTL applies to the session store
```

### 6. Validate before you commit

``` r

result <- okf_validate(kb, strict = FALSE)
result$is_conformant
#> [1] TRUE
result$concept_count
#> [1] 2
```

`okf_validate(kb, strict = TRUE)` additionally gates broken links,
orphans, and provenance gaps as errors — run that in CI or as a
pre-commit hook. Note: the Windows `okf` binary (v0.1.2) fails to
resolve relative links, so strict validation rejects linked bundles on
Windows even when the links are correct. Same-directory links validate
strictly on Linux and macOS.

## Agent integrations

For `ellmer` chat agents,
[`okf_skill()`](https://ashishtele.github.io/rokf/reference/okf_skill.md)
registers search/show/create/update/ validate as tools. For `tidyllm`
pipelines,
[`okf_verbs()`](https://ashishtele.github.io/rokf/reference/okf_verbs.md)
provides search/show/persist/validate verbs that inject results as
system messages. Both follow the same search-before-create contract
enforced above.
