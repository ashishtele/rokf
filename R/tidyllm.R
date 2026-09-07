#' Tidyllm integration: OKF Agent Memory verbs
#'
#' Provides tidyverse-style verbs for working with OKF knowledge from within
#' a tidyllm chat pipeline.
#'
#' @param bundle Path to knowledge bundle (default: "knowledge")
#' @return A list of tidyllm-compatible functions
#' @export
#' @examples
#' \dontrun{
#' library(tidyllm)
#' okf <- okf_verbs()
#'
#' # Search and use in a chat
#' chat_openai() %>%
#'   okf$search("auth architecture") %>%
#'   chat("Summarize these concepts") %>%
#'   okf$persist_as("decisions/auth-summary", type = "Fact")
#' }
okf_verbs <- function(bundle = "knowledge") {
  bundle_path <- fs::path_abs(bundle)

  list(
    # Search and inject results into conversation
    search = function(chat, query, limit = 5) {
      results <- okf_search(query, bundle = bundle_path, limit = limit)
      if (nrow(results) == 0) {
        chat %>% tidyllm::add_message("system", "No matching concepts found in knowledge base.")
      } else {
        context <- purrr::map_chr(seq_len(nrow(results)), function(i) {
          r <- results[i, ]
          sprintf("## %s (%s)\n%s\n[Score: %.2f]", r$title, r$type, r$description, r$score)
        }) %>% paste(collapse = "\n\n")

        chat %>% tidyllm::add_message("system",
          sprintf("Relevant knowledge from OKF memory (query: '%s'):\n\n%s", query, context))
      }
    },

    # Show a concept and inject
    show = function(chat, id) {
      concept <- okf_show(id, bundle = bundle_path)
      if (is.list(concept) && !is.null(concept$id)) {
        context <- sprintf(
          "## %s (%s)\n%s\n\n---\n%s",
          concept$title %||% id, concept$type %||% "Concept",
          concept$description %||% "",
          concept$body %||% ""
        )

        chat %>% tidyllm::add_message("system", sprintf("Concept: %s\n\n%s", id, context))
      } else {
        chat %>% tidyllm::add_message("system", sprintf("Concept not found: %s", id))
      }
    },

    # Persist last assistant message as a concept
    persist_as = function(chat, id, type = "Fact", title = NULL, description = NULL, tags = NULL) {
      last_msg <- chat$messages[[length(chat$messages)]]
      if (last_msg$role != "assistant") {
        cli::cli_warn("Last message is not from assistant; nothing to persist")
        return(chat)
      }

      body <- last_msg$content
      if (is.null(title)) title <- id
      if (is.null(description)) description <- sprintf("Captured from agent conversation on %s", Sys.Date())

      okf_create(id, type = type, title = title, desc = description, body = body, tags = tags, bundle = bundle_path)

      chat %>% tidyllm::add_message("system", sprintf("Persisted as %s (%s)", id, type))
    },

    # Validate and report
    validate = function(chat, strict = TRUE, drift = FALSE) {
      result <- okf_validate(bundle = bundle_path, strict = strict, drift = drift)

      msg <- if (result$gate_passed %||% result$is_conformant) {
              sprintf("[OK] Knowledge bundle valid: %d concepts, 0 errors", result$concept_count %||% 0)
            } else {
              errors <- result$errors %||% list()
              warnings <- result$warnings %||% list()
              sprintf("[ERROR] Knowledge bundle has issues:\nErrors: %d\nWarnings: %d\n%s",
                length(errors), length(warnings),
                paste(c(errors, warnings), collapse = "\n"))
            }

      chat %>% tidyllm::add_message("system", msg)
    }
  )
}