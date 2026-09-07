# Agent workflow: Read-Work-Remember loop

Runs a single iteration of the core OKF workflow: search -\> work -\>
persist -\> validate. Designed to be called by an agent after completing
a substantial task.

## Usage

``` r
okf_agent_review(chat, task_description, bundle = "knowledge")
```

## Arguments

- chat:

  An ellmer chat object with okf_skill registered

- task_description:

  What the agent just worked on

- bundle:

  Path to knowledge bundle

## Value

Invisibly, the chat object
