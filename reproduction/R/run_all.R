# ============================================================================
# run_all.R  --  Reproduce the full pipeline end to end.
#   From a fresh machine: source this file. The project root is detected
#   automatically, so the folder can live anywhere.
#   Internet is needed for 01_download.R only if data/raw/ is not bundled.
# ============================================================================
## ---- Project root: auto-detected, no editing needed -----------------------
## Resolves to the folder containing R/, whether this file is source()d, run via
## Rscript, sourced from RStudio, or pasted with the working directory set to the
## project root (or to R/).
if (!exists("PROJ")) {
  .of <- NULL
  for (.i in seq_len(sys.nframe())) {
    .of <- get0("ofile", envir = sys.frame(.i), inherits = FALSE)
    if (!is.null(.of)) break
  }
  if (is.null(.of)) {
    .cl <- grep("^--file=", commandArgs(FALSE), value = TRUE)
    if (length(.cl)) .of <- sub("^--file=", "", .cl[1])
  }
  PROJ <- if (!is.null(.of))
            dirname(dirname(normalizePath(.of, "/", FALSE))) else getwd()
  if (!dir.exists(file.path(PROJ, "R")) &&
      dir.exists(file.path(dirname(PROJ), "R"))) PROJ <- dirname(PROJ)
  rm(list = intersect(c(".of", ".i", ".cl"), ls(all.names = TRUE)))
}
R <- file.path(PROJ, "R")

source(file.path(R, "00_setup.R"))         # paths, cycles, components
source(file.path(R, "01_download.R"))      # download raw NHANES + mortality (once)
source(file.path(R, "02_build_analytic.R"))# merge, FLI, MASLD, groups, mortality
source(file.path(R, "03_table1.R"))        # Table 1
source(file.path(R, "04_table2_cox.R"))    # Table 2 (Cox)
source(file.path(R, "05_figure1_km.R"))    # Figure 1 (Kaplan-Meier)
source(file.path(R, "06_figure2_rcs.R"))   # Figure 2 (restricted cubic splines)

message("\nDONE. Outputs in output/tables and output/figures.")
