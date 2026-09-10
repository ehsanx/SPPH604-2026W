# ============================================================================
# 00_setup.R  --  Paths, configuration, and shared constants
# Reproduction of: Kueh MTW et al. (2026) BMJ Open 16:e113719
#   "Body weight categories and fat distribution in relation to all-cause
#    mortality among adults with MASLD: NHANES 2007-2018"
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

DIR_RAW     <- file.path(PROJ, "data", "raw")
DIR_DERIVED <- file.path(PROJ, "data", "derived")
DIR_TABLES  <- file.path(PROJ, "output", "tables")
DIR_FIGURES <- file.path(PROJ, "output", "figures")
DIR_LOGS    <- file.path(PROJ, "logs")
for (d in c(DIR_RAW, DIR_DERIVED, DIR_TABLES, DIR_FIGURES, DIR_LOGS))
  dir.create(d, recursive = TRUE, showWarnings = FALSE)

## ---- NHANES cycles included (2007-2018) -----------------------------------
# CDC file suffix per 2-year cycle
CYCLES <- data.frame(
  cycle  = c("2007-2008","2009-2010","2011-2012","2013-2014","2015-2016","2017-2018"),
  suffix = c("E","F","G","H","I","J"),
  year1  = c("2007","2009","2011","2013","2015","2017"),  # CDC DataFiles folder
  stringsAsFactors = FALSE
)

## ---- NHANES data components needed ----------------------------------------
# base component name -> gets "_<suffix>.XPT" appended per cycle
COMPONENTS <- c(
  "DEMO",     # demographics: age, sex, race, PIR, survey design
  "BMX",      # body measures: BMI, waist, height
  "BPX",      # blood pressure (measured)
  "TRIGLY",   # triglycerides / LDL (fasting subsample)  -> LBXTR
  "BIOPRO",   # standard biochemistry -> GGT (LBXSGTSI), creatinine (LBXSCR)
  "GHB",      # glycohemoglobin -> HbA1c (LBXGH)
  "GLU",      # fasting plasma glucose (LBXGLU)
  "HDL",      # HDL cholesterol (LBDHDD)
  "TCHOL",    # total cholesterol (LBXTC)
  "ALQ",      # alcohol use (exclusion criterion)
  "SMQ",      # smoking
  "BPQ",      # BP & cholesterol questionnaire (dx + meds)
  "DIQ",      # diabetes questionnaire
  "MCQ",      # medical conditions (MI, stroke, HF, COPD, cancer, family hx)
  "KIQ_U",    # kidney conditions
  "PAQ",      # physical activity (sedentary minutes, Model 2)
  "ALB_CR",   # urine albumin/creatinine (CKD via ACR)
  "RXQ_RX"    # prescription medications (med classes for Cox models)
)

message("Setup loaded. PROJ = ", PROJ)
message("Cycles: ", paste(CYCLES$cycle, collapse = ", "))
