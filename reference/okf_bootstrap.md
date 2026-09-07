# Bootstrap complete OKF Agent Memory stack into a project

Scaffolds knowledge/, .agents/skills/okf-memory/, AGENTS.md, and
Makefile.

## Usage

``` r
okf_bootstrap(
  target_dir = ".",
  name = NULL,
  overwrite_agents_md = FALSE,
  no_skill = FALSE,
  no_agents_md = FALSE,
  no_makefile = FALSE,
  no_bundle = FALSE,
  verbose = FALSE
)
```

## Arguments

- target_dir:

  Target project directory (default: current directory)

- name:

  Project name (defaults to directory name)

- overwrite_agents_md:

  Overwrite existing AGENTS.md

- no_skill:

  Skip installing .agents/skills/okf-memory/

- no_agents_md:

  Skip creating AGENTS.md

- no_makefile:

  Skip installing Makefile

- no_bundle:

  Skip initializing knowledge/ bundle

- verbose:

  Show command output

## Value

Invisibly, the target directory

## Examples

``` r
if (FALSE) { # \dontrun{
okf_bootstrap(".", name = "My Project")
} # }
```
