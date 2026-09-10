## Shared helpers for every increment. Sourced as `source("../_shared/paths.R")`.
##
## Nothing here may contain an absolute path. The same sources are rendered from
## two different trees (the authoring folder and the published repository), and a
## path that names one machine is a reproducibility defect, not a convenience.

suppressPackageStartupMessages(library(jsonlite))

#' Locate the reproduction project by searching upward for its derived data.
#' Order: the SPPH604_REPRO environment variable, then a walk up from the working
#' directory. Errors loudly rather than guessing.
find_repro <- function(max_up = 6) {
  e <- Sys.getenv("SPPH604_REPRO", "")
  if (nzchar(e) && dir.exists(file.path(e, "data", "derived")))
    return(normalizePath(e, "/"))
  d <- normalizePath(getwd(), "/")
  for (i in seq_len(max_up)) {
    for (cand in c("example/repro", "reproduction")) {
      p <- file.path(d, cand)
      if (dir.exists(file.path(p, "data", "derived")))
        return(normalizePath(p, "/"))
    }
    d <- dirname(d)
  }
  stop("Cannot locate the reproduction project. Set SPPH604_REPRO to the folder ",
       "that contains data/derived, or render from inside the course tree.")
}

#' Locate a file that sits beside the course tree under either layout.
#' Returns NA_character_ when it is not present, so callers can degrade instead
#' of failing: the paper PDF is not redistributable everywhere.
find_beside <- function(candidates, max_up = 6) {
  d <- normalizePath(getwd(), "/")
  for (i in seq_len(max_up)) {
    for (cand in candidates) {
      p <- file.path(d, cand)
      if (file.exists(p)) return(normalizePath(p, "/"))
    }
    d <- dirname(d)
  }
  NA_character_
}

find_paper <- function()
  find_beside(c("example/e113719.full.pdf", "paper/e113719.full.pdf"))

## ---- formatting used by every fact, so the deck never reformats a number ----

## trim = TRUE: format() otherwise pads a vector to a common width, which would
## put leading spaces inside a fact and therefore inside a slide.
fmtn <- function(x) format(as.integer(x), big.mark = ",", trim = TRUE)

#' Turn the ASCII hyphen between two digits into an en dash, so an interval is
#' typeset the same way everywhere it appears.
endash <- function(s) gsub("(?<=[0-9])-(?=[0-9])", "\u2013", s, perl = TRUE)

#' A hazard ratio with its interval, formatted once, here.
ci <- function(est, lo, hi) sprintf("%.2f (%.2f–%.2f)", est, lo, hi)

#' Pull estimate + CI for one term out of a fitted (sv)coxph and format it.
ci_of <- function(fit, term = "groupIV") {
  s <- summary(fit)$conf.int
  ci(s[term, 1], s[term, 3], s[term, 4])
}

## ---- result objects -------------------------------------------------------

#' Write an increment's results.
#'
#' `facts` is a flat, named list of **formatted strings** that the M1 deck may
#' cite as {{ <name>.facts.<key> }}. Because the deck substitutes them at build
#' time, a fact is the single place a number is formatted, and an unused or
#' misspelled key fails the build rather than going unnoticed.
#' `tables` holds the fuller objects, for reading rather than citation.
emit_results <- function(name, facts, tables = list()) {
  stopifnot(is.list(facts), !is.null(names(facts)), all(nzchar(names(facts))))
  dir.create("../_results", showWarnings = FALSE)
  out <- file.path("../_results", paste0(name, ".json"))
  ## Stamp who wrote this. The deck generator refuses to cite a namespace whose
  ## `emitted_by` does not match its filename, so a hand-written JSON dropped into
  ## _results/ cannot quietly become a citable source of "facts".
  jsonlite::write_json(c(list(emitted_by = name, facts = facts), tables), out,
                       auto_unbox = TRUE, pretty = TRUE)
  cat(sprintf("wrote %s  (%d facts, %d tables)\n", out, length(facts), length(tables)))
  invisible(out)
}

#' Read an increment's result object.
read_results <- function(name) {
  p <- file.path("../_results", paste0(name, ".json"))
  if (!file.exists(p))
    stop("Missing result object: ", p,
         ". Render the increments before M1 - M1 assembles their output ",
         "and must not substitute for it.")
  jsonlite::read_json(p, simplifyVector = TRUE)
}
