# @param arg a vector of command arguments.
# @param env a named character vector.  Will be quoted
system_check <- function(cmd, args = character(), env = character(),
                         quiet = FALSE, ...) {
  full <- paste(cmd, " ", paste(args, collapse = ", "), sep = "")

  if (!quiet) {
    message(wrap_command(full))
    message()
  }

  out <- if (quiet) NULL else ""
  with_env(env, {
    res <- system2(cmd, args = args, stderr = out, stdout = out, ...)
  })
  if (res != 0) {
    stop("Command failed (", res, ")", call. = FALSE)
  }

  invisible(TRUE)
}

# R("-e 'str(as.list(Sys.getenv()))' --slave")
R <- function(options, path = tempdir(), env_vars = NULL, ...) {
  options <- paste("--vanilla", options)
  r_path <- file.path(R.home("bin"), "R")

  env <- c(
    "LC_ALL" = "C",
    "R_LIBS" = paste(.libPaths(), collapse = .Platform$path.sep),
    "CYGWIN" = "nodosfilewarning",
    "R_TESTS" = "",
    "NOT_CRAN" = "true",
    "TAR" = auto_tar(),
    env_vars)
    # When R CMD check runs tests, it sets R_TESTS. When the tests
    # themeselves run R CMD xxxx, as is the case with the tests in
    # devtools, having R_TESTS set causes errors because it confuses
    # the R subprocesses. Unsetting it here avoids those problems.

  # If rtools has been detected, add it to the path only when running R...
  if (!is.null(get_rtools_path())) {
    old <- add_path(get_rtools_path(), 0)
    on.exit(set_path(old))
  }

  in_dir(path, system_check(r_path, options, env, ...))
}

# Determine the best setting for the TAR environmental variable
auto_tar <- function() {
  tar <- Sys.getenv("TAR", unset = NA)
  if (!is.na(tar)) return(tar)

  if (.Platform$OS.type == "windows") "internal" else ""
}

RCMD <- function(cmd, options, path = tempdir(), env_vars = NULL, ...) {
  options <- paste(options, collapse = " ")
  R(paste("CMD", cmd, options), path = path, env_vars = env_vars, ...)
}

wrap_command <- function(x) {
  lines <- strwrap(x, getOption("width") - 2, exdent = 2)
  continue <- c(rep(" \\", length(lines) - 1), "")
  paste(lines, continue, collapse = "\n")
}
