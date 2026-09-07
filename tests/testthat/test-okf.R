testthat::test_that("okf_bin finds binary", {
  skip_if_not_installed("processx")

  # Should find bundled binary
  bin <- okf_bin(verbose = FALSE)
  expect_true(file.exists(bin))
  expect_true(grepl("okf-", basename(bin)))
})

testthat::test_that("okf_version returns version string", {
  ver <- okf_version()
  expect_type(ver, "character")
  expect_match(ver, "okf version")
})

testthat::test_that("okf_init creates valid bundle", {
  kb <- file.path(withr::local_tempdir(), "kb")
  path <- okf_init(kb)
  expect_true(fs::file_exists(fs::path(path, "index.md")))
  expect_true(fs::file_exists(fs::path(path, "log.md")))
  expect_true(is_okf_bundle(path))
})

testthat::test_that("okf_search works on empty bundle", {
  kb <- file.path(withr::local_tempdir(), "kb")
  okf_init(kb)
  results <- okf_search("anything", bundle = kb)
  expect_s3_class(results, "tbl_df")
  expect_equal(nrow(results), 0)
})

testthat::test_that("okf_create and okf_show roundtrip", {
  kb <- file.path(withr::local_tempdir(), "kb")
  okf_init(kb)

  created <- okf_create(
    "decisions/test-decision",
    type = "Decision",
    title = "Test Decision",
    desc = "A test decision for unit testing",
    bundle = kb
  )
  expect_equal(created$status, "success")
  expect_equal(created$concept_id, "decisions/test-decision")

  shown <- okf_show("decisions/test-decision", bundle = kb)
  expect_equal(shown$type, "Decision")
  expect_equal(shown$title, "Test Decision")
  expect_equal(shown$description, "A test decision for unit testing")
})

testthat::test_that("okf_search finds created concept", {
  kb <- file.path(withr::local_tempdir(), "kb")
  okf_init(kb)
  okf_create("decisions/pools", type = "Decision",
             title = "Pool Sizing", desc = "Connection pool tuning notes",
             bundle = kb)

  results <- okf_search("pool tuning", bundle = kb)
  expect_s3_class(results, "tbl_df")
  expect_true(nrow(results) >= 1)
  expect_true("decisions/pools" %in% results$id)
  expect_true(all(c("rank", "score", "id", "type", "title", "description", "matches") %in% names(results)))
})

testthat::test_that("okf_update modifies concept", {
  kb <- file.path(withr::local_tempdir(), "kb")
  okf_init(kb)
  okf_create("decisions/test", type = "Decision", title = "Original",
             desc = "Original desc", bundle = kb)

  updated <- okf_update("decisions/test", desc = "Updated desc", bundle = kb)
  expect_equal(updated$status, "success")

  shown <- okf_show("decisions/test", bundle = kb)
  expect_equal(shown$description, "Updated desc")
})

testthat::test_that("okf_relate links concepts", {
  kb <- file.path(withr::local_tempdir(), "kb")
  okf_init(kb)
  okf_create("architecture/a", type = "Architecture", title = "A",
             desc = "Component A", bundle = kb)
  okf_create("architecture/b", type = "Architecture", title = "B",
             desc = "Component B", bundle = kb)

  linked <- okf_relate("architecture/a", "architecture/b",
                       desc = "A uses B", bundle = kb)
  expect_equal(linked$status, "success")

  # Link appears as a relative "Related Concepts" entry in the source body
  # (relative links prevent fragmentation: b.md, not architecture/b)
  shown_a <- okf_show("architecture/a", bundle = kb)
  expect_true(grepl("Related Concepts", shown_a$body))
  expect_true(grepl("A uses B", shown_a$body))
})

testthat::test_that("okf_validate passes on connected bundle", {
  kb <- file.path(withr::local_tempdir(), "kb")
  okf_init(kb)
  okf_create("decisions/test", type = "Decision", title = "Test",
             desc = "Test decision", bundle = kb)
  okf_create("architecture/sys", type = "Architecture", title = "Sys",
             desc = "System", bundle = kb)
  okf_relate("decisions/test", "architecture/sys",
             desc = "Test applies to Sys", bundle = kb)

  result <- okf_validate(kb, strict = FALSE)
  expect_true(result$is_conformant %||% result$gate_passed)

  # Strict link-gating: skipped on Windows, where the okf v0.1.2 binary
  # cannot resolve relative links (upstream bug, reports every link broken)
  testthat::skip_on_os("windows")
  strict <- okf_validate(kb, strict = TRUE)
  expect_true(strict$is_conformant %||% strict$gate_passed)
})
