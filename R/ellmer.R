#' Ellmer integration: OKF Agent Memory skill for AI agents
#'
#' Provides a ready-to-use skill definition that teaches an ellmer chat agent
#' how to use OKF Agent Memory for persistent project knowledge.
#'
#' @param bundle Path to knowledge bundle (default: "knowledge")
#' @return A skill object compatible with ellmer::chat_*()$register_skill()
#' @export
#' @examples
#' \dontrun{
#' library(ellmer)
#' chat <- chat_openai()
#' chat$register_skill(okf_skill())
#' chat$chat("Search for architecture decisions in our knowledge base")
#' }
okf_skill <- function(bundle = "knowledge") {
  bundle_path <- fs::path_abs(bundle)

  ellmer::skill(
    name = "okf_memory",
    description = sprintf("Persistent project knowledge via OKF Agent Memory (bundle: %s)", bundle_path),
    functions = list(
      search = ellmer::tool(
        function = function(query, limit = 10) {
          okf_search(query, bundle = bundle_path, limit = limit)
        },
        description = "Search project knowledge concepts using BM25 ranking. Use before creating new concepts.",
        arguments = list(
          query = ellmer::argument_string("Search terms or keywords"),
          limit = ellmer::argument_integer("Maximum results", default = 10)
        )
      ),
      show = ellmer::tool(
        function = function(id) {
          okf_show(id, bundle = bundle_path)
        },
        description = "Get full concept details including frontmatter, body, and graph links",
        arguments = list(
          id = ellmer::argument_string("Concept ID (e.g., 'architecture/layers')")
        )
      ),
      create = ellmer::tool(
        function = function(id, type, title, description, body = NULL, tags = NULL) {
          okf_create(id, type = type, title = title, desc = description, body = body, tags = tags, bundle = bundle_path)
        },
        description = "Create a new knowledge concept with automated bookkeeping. Search first!",
        arguments = list(
          id = ellmer::argument_string("Concept ID (e.g., 'decisions/auth-flow')"),
          type = ellmer::argument_string("Concept type (Decision, Architecture, Fact, Entity, Runbook, etc.)"),
          title = ellmer::argument_string("Human-readable title"),
          description = ellmer::argument_string("One-sentence description"),
          body = ellmer::argument_string("Optional markdown body content", required = FALSE),
          tags = ellmer::argument_string("Optional comma-separated tags", required = FALSE)
        )
      ),
      update = ellmer::tool(
        function = function(id, title = NULL, description = NULL, body = NULL) {
          okf_update(id, title = title, desc = description, body = body, bundle = bundle_path)
        },
        description = "Update an existing concept's metadata or body",
        arguments = list(
          id = ellmer::argument_string("Concept ID"),
          title = ellmer::argument_string("New title", required = FALSE),
          description = ellmer::argument_string("New description", required = FALSE),
          body = ellmer::argument_string("New markdown body", required = FALSE)
        )
      ),
      validate = ellmer::tool(
        function = function(strict = TRUE, drift = FALSE) {
          okf_validate(bundle = bundle_path, strict = strict, drift = drift)
        },
        description = "Validate knowledge bundle conformance and graph health",
        arguments = list(
          strict = ellmer::argument_logical("Fail on warnings", default = TRUE),
          drift = ellmer::argument_logical("Check index descriptions", default = FALSE)
        )
      )
    )
  )
}

#' Agent workflow: Read-Work-Remember loop
#'
#' Runs a single iteration of the core OKF workflow: search -> work -> persist -> validate.
#' Designed to be called by an agent after completing a substantial task.
#'
#' @param chat An ellmer chat object with okf_skill registered
#' @param task_description What the agent just worked on
#' @param bundle Path to knowledge bundle
#' @return Invisibly, the chat object
#' @export
okf_agent_review <- function(chat, task_description, bundle = "knowledge") {
  # This is a prompt template for the agent to self-review
  prompt <- sprintf(
    'I just completed this task: "%s"

Perform a knowledge review following the OKF Agent Memory Convention:

1. What did I learn that future agents/humans should know?
2. What changed architecturally or decision-wise?
3. Did I make important decisions? (type: Decision)
4. Did I discover something non-obvious? (type: Fact/Observation)
5. Did an existing assumption become invalid?
6. Did relationships between concepts change?
7. Did I create artifacts future work should know about?
8. Is there information a future agent would otherwise have to rediscover?

For each YES answer:
- Search existing knowledge first (okf_search)
- Create or update concepts (okf_create / okf_update)
- Link related concepts (okf_relate)

Finally, validate the bundle (okf_validate with strict=true).

Report what you persisted.', task_description)

  chat$chat(prompt)
  invisible(chat)
}