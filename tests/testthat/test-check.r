context("Check")

test_that("return messages", {
  on.exit(unlink("testHelp.Rcheck", recursive = TRUE), add = TRUE)
  check("testHelp", document = FALSE, check_dir = ".", cleanup = FALSE, quiet = TRUE)

  failures <- check_failures("testHelp.Rcheck", error = TRUE,
                             warning = TRUE, note = TRUE)
  expect_equal(failures, character())
})

test_that("aspell environment variables", {
  with_mock(
    `utils:::aspell_find_program` = function (...) "/bin/aspell",
    expect_equal(names(aspell_env_var()), "_R_CHECK_CRAN_INCOMING_USE_ASPELL_")
  )
  with_mock(
    `utils:::aspell_find_program` = function (...) NA,
    expect_warning(aspell_env_var(), "Skipping spell check")
  )
})
