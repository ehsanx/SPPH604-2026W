# ============================================================================
# 01_download.R  --  Download all raw NHANES data + linked mortality files
# Saves untouched raw files under data/raw/<cycle>/ and data/raw/mortality/
# Writes a manifest (data/raw/_download_manifest.csv) recording URL/size/status
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
source(file.path(PROJ, "R", "00_setup.R"))

options(timeout = 600)

BASE_DATA <- "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public"  # /<year1>/DataFiles/<FILE>_<suf>.xpt
BASE_MORT <- "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/datalinkage/linked_mortality"

manifest <- list()
record <- function(url, dest, status, bytes) {
  manifest[[length(manifest) + 1]] <<- data.frame(
    url = url, dest = dest, status = status, bytes = bytes,
    stringsAsFactors = FALSE)
}

dl <- function(url, dest) {
  if (file.exists(dest) && file.info(dest)$size > 2000) {
    record(url, dest, "exists", file.info(dest)$size); return("exists")
  }
  ok <- tryCatch({
    download.file(url, dest, mode = "wb", quiet = TRUE); TRUE
  }, error = function(e) FALSE, warning = function(w) FALSE)
  sz <- if (file.exists(dest)) file.info(dest)$size else 0
  # A CDC 404 returns a small HTML page; treat <2 KB as a miss
  if (!ok || sz < 2000) {
    if (file.exists(dest)) file.remove(dest)
    record(url, dest, "MISSING", 0); return("MISSING")
  }
  record(url, dest, "ok", sz); return("ok")
}

## ---- 1. NHANES data components --------------------------------------------
for (i in seq_len(nrow(CYCLES))) {
  cyc <- CYCLES$cycle[i]; suf <- CYCLES$suffix[i]; yr <- CYCLES$year1[i]
  outdir <- file.path(DIR_RAW, cyc); dir.create(outdir, showWarnings = FALSE)
  for (comp in COMPONENTS) {
    fn  <- sprintf("%s_%s.xpt", comp, suf)
    url <- sprintf("%s/%s/DataFiles/%s", BASE_DATA, yr, fn)
    st  <- dl(url, file.path(outdir, fn))
    message(sprintf("[%s] %-12s %s", cyc, comp, st))
  }
}

## ---- 2. Multum drug lexicon (maps drug -> therapeutic category) ------------
# Single non-cycle file; try a couple of known locations.
lex_dest <- file.path(DIR_RAW, "RXQ_DRUG.xpt")
for (u in c(sprintf("%s/2015/DataFiles/RXQ_DRUG.xpt", BASE_DATA),
            sprintf("%s/2017/DataFiles/RXQ_DRUG.xpt", BASE_DATA),
            sprintf("%s/2013/DataFiles/RXQ_DRUG.xpt", BASE_DATA))) {
  if (dl(u, lex_dest) == "ok") { message("RXQ_DRUG lexicon: ok (", u, ")"); break }
}

## ---- 3. Linked public-use mortality files (fixed-width .dat) ---------------
mdir <- file.path(DIR_RAW, "mortality"); dir.create(mdir, showWarnings = FALSE)
for (i in seq_len(nrow(CYCLES))) {
  cyc <- gsub("-", "_", CYCLES$cycle[i])
  fn  <- sprintf("NHANES_%s_MORT_2019_PUBLIC.dat", cyc)
  st  <- dl(sprintf("%s/%s", BASE_MORT, fn), file.path(mdir, fn))
  message(sprintf("[mortality] %s %s", CYCLES$cycle[i], st))
}

## ---- Write manifest --------------------------------------------------------
man <- do.call(rbind, manifest)
write.csv(man, file.path(DIR_RAW, "_download_manifest.csv"), row.names = FALSE)
message("\n==== Download summary ====")
print(table(man$status))
message("Total downloaded (MB): ",
        round(sum(man$bytes[man$status %in% c("ok","exists")]) / 1e6, 1))
message("MISSING files:")
print(man[man$status == "MISSING", c("dest")])
