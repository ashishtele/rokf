testthat::test_that("okf_bin finds binary", {
  skip_if_not_installed("processx")
  skip_on_cran()

  # Should find bundled binary
  bin <- okf_bin(verbose = FALSE)
  expect_true(file.exists(bin))
  expect_true(grepl("okf-", basename(bin)))
})

testthat::test_that("okf_version returns version string", {
  skip_on_cran()
  ver <- okf_version()
  expect_type(ver, "character")
  expect_match(ver, "okf version")
})

testthat::test_that("okf_init creates valid bundle", {
  skip_on_cran()
  withr::local_tempdir()
  path <- okf_init("test-knowledge")
  expect_true(fs::file_exists(fs::path(path, "index.md")))
  expect_true(fs::file_exists(fs::path(path, "log.md")))
  expect_true(is_okf_bundle(path))
})

testthat::test_that("okf_search works on empty bundle", {
  skip_on_cran()
  withr::local_tempdir()
  okf_init("kb")
  results <- okf_search("anything", bundle = "kb")
  expect_s3_class(results, "tbl_df")
  expect_equal(nrow(results), 0)
})

testthat::test_that("okf_create and okf_show roundtrip", {
  skip_on_cran()
  withr::local_tempdir()
  okf_init("kb")

  created <- okf_create(
    "decisions/test-decision",
    type = "Decision",
    title = "Test Decision",
    desc = "A test decision for unit testing",
    bundle = "kb"
  )
  expect_type(created, "list")

  shown <- okf_show("decisions/test-decision", bundle = "kb")
  expect_type(shown, "list")
  expect_equal(shown$frontmatter$title, "Test Decision")
  expect_equal(shown$frontmatter$type, "Decision")
})

testthat::test_that("okf_update modifies concept", {
  skip_on_cran()
  withr::local_tempdir()
  okf_init("kb")
  okf_create("decisions/test", type = "Decision", title = "Original", desc = "Original desc", bundle = "kb")

  updated <- okf_update("decisions/test", desc = "Updated desc", bundle = "kb")
  expect_type(updated, "list")

  shown <- okf_show("decisions/test", bundle = "kb")
  expect_equal(shown$frontmatter$description, "Updated desc")
})

testthat::test_that("okf_relate links concepts", {
  skip_on_cran()
  withr::local_tempdir()
  okf_init("kb")
  okf_create("architecture/a", type = "Architecture", title = "A", desc = "Component A", bundle = "kb")
  okf_create("architecture/b", type = "Architecture", title = "B", desc = "Component B", bundle = "kb")

  linked <- okf_relate("architecture/a", "architecture/b", desc = "A uses B", bundle = "kb")
  expect_type(linked, "list")

  # Check link appears in show
  shown_a <- okf_show("architecture/a", bundle = "kb")
  expect_true(any(grepl("architecture/b", shown_a$outbound %||% character())))
})

testthat::test_that("okf_validate passes on valid bundle", {
  skip_on_cran()
  withr::local_tempdir()
  okf_init("kb")
  okf_create("decisions/test", type = "Decision", title = "Test", desc = "Test decision", bundle = "kb")

  result <- okf_validate("kb", strict = TRUE)
  expect_true(result$is_conformant %||% result$gate_passed)
})