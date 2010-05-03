run_examples <- function(pkg) {
  pkg <- as.package(pkg)
  
  path_man <- file.path(pkg$path, "man")
  files <- dir(path_man, pattern = "\\.Rd$", full = TRUE)

  parsed <- llply(files, tools::parse_Rd)
  names(parsed) <- basename(files)

  extract_examples <- function(rd) {
    tags <- tools:::RdTags(rd)
    paste(unlist(rd[tags == "\\examples"]), collapse = "")
  }

  examples <- llply(parsed, extract_examples)
  m_ply(cbind(file = names(examples), example = examples), 
    function(file, example) {
      cat("Checking ", file, "...\n", sep = "")
      eval(parse(text = example))
    }
  )  
}


# If an error occurs, should print out the suspect line of code, and offer
# the following options:
#   * skip to the next example
#   * quit
#   * rerun roxygen and rerun example
#   * reload code and rerun example