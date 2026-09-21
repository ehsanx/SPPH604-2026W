## 07_variable_map.R ---------------------------------------------------------
## Emits ../VARIABLE_MAP.md: the student-facing crosswalk from
##   concept -> NHANES variable -> component file -> CDC codebook -> our code.
##
## NOTHING IN THE OUTPUT IS HAND-TYPED except the ROLES table below. Cycle
## availability, SAS labels, value ranges and the missing-value convention are
## all read out of the raw .xpt files in data/raw/, so this file cannot drift
## from the data the way a hand-maintained table would.
##
## Run:  Rscript R/07_variable_map.R
## Needs data/raw/ present (01_download.R). Not part of run_all.R -- this is
## documentation, not analysis, and it is regenerated on demand.

suppressPackageStartupMessages({library(haven); library(dplyr)})

HERE <- tryCatch(dirname(normalizePath(sys.frame(1)$ofile)), error = function(e) "R")
PROJ <- normalizePath(file.path(HERE, ".."), mustWork = FALSE)
if (!dir.exists(file.path(PROJ, "data"))) PROJ <- normalizePath(".", mustWork = FALSE)
RAW  <- file.path(PROJ, "data", "raw")
OUT  <- file.path(PROJ, "VARIABLE_MAP.md")

CY <- data.frame(
  cycle  = c("2007-2008","2009-2010","2011-2012","2013-2014","2015-2016","2017-2018"),
  sfx    = c("E","F","G","H","I","J"),
  year1  = c("2007","2009","2011","2013","2015","2017"),
  stringsAsFactors = FALSE)

## ---- the only hand-authored part: what each variable is FOR ---------------
## role is the analysis decision the variable serves. This is the column a
## student cannot recover from CDC documentation, which is why it is here.
ROLES <- read.csv(text = "
role,concept,variable,component
Join key,Respondent ID,SEQN,DEMO
Eligibility,Age,RIDAGEYR,DEMO
Survey design,MEC weight,WTMEC2YR,DEMO
Survey design,Interview weight,WTINT2YR,DEMO
Survey design,Cycle indicator,SDDSRVYR,DEMO
Survey design,Fasting subsample weight,WTSAF2YR,TRIGLY
Survey design,Stratum,SDMVSTRA,DEMO
Survey design,PSU,SDMVPSU,DEMO
Case definition (FLI),Triglycerides,LBXTR,TRIGLY
Case definition (FLI),BMI,BMXBMI,BMX
Case definition (FLI),GGT,LBXSGTSI,BIOPRO
Case definition (FLI),Waist circumference,BMXWAIST,BMX
Cardiometabolic 1 (adiposity),BMI,BMXBMI,BMX
Cardiometabolic 1 (adiposity),Waist circumference,BMXWAIST,BMX
Cardiometabolic 2 (glycaemia),Fasting glucose,LBXGLU,GLU
Cardiometabolic 2 (glycaemia),HbA1c,LBXGH,GHB
Cardiometabolic 2 (glycaemia),Diabetes diagnosis,DIQ010,DIQ
Cardiometabolic 2 (glycaemia),Insulin,DIQ050,DIQ
Cardiometabolic 2 (glycaemia),Oral hypoglycaemics,DIQ070,DIQ
Cardiometabolic 3 (blood pressure),Systolic (reading 1 of 4),BPXSY1,BPX
Cardiometabolic 3 (blood pressure),Diastolic (reading 1 of 4),BPXDI1,BPX
Cardiometabolic 3 (blood pressure),On BP medication,BPQ050A,BPQ
Cardiometabolic 4 (triglycerides),Triglycerides,LBXTR,TRIGLY
Cardiometabolic 4 (triglycerides),On lipid medication,BPQ100D,BPQ
Cardiometabolic 5 (HDL),HDL cholesterol,LBDHDD,HDL
Exposure,Height (for WHtR),BMXHT,BMX
Exposure,Race/ethnicity (Asian BMI cut),RIDRETH3,DEMO
Alcohol exclusion,Drinks per drinking day,ALQ130,ALQ
Alcohol exclusion,Drinking frequency (quantity),ALQ120Q,ALQ
Alcohol exclusion,Drinking frequency (unit),ALQ120U,ALQ
Alcohol exclusion,Drinking frequency (2017-18 redesign),ALQ121,ALQ
Covariate,Sex,RIAGENDR,DEMO
Covariate,Race/ethnicity (all cycles),RIDRETH1,DEMO
Covariate,Income-to-poverty ratio,INDFMPIR,DEMO
Covariate,Ever smoked 100 cigarettes,SMQ020,SMQ
Covariate,Current smoking,SMQ040,SMQ
Covariate,Coronary heart disease,MCQ160C,MCQ
Covariate,Heart failure,MCQ160B,MCQ
Covariate,Stroke,MCQ160F,MCQ
Covariate,Cancer,MCQ220,MCQ
Covariate,Weak/failing kidneys,KIQ022,KIQ_U
Covariate,Serum creatinine,LBXSCR,BIOPRO
Covariate,Urine albumin,URXUMA,ALB_CR
Covariate,Urine creatinine,URXUCR,ALB_CR
Covariate,Albumin-creatinine ratio,URDACT,ALB_CR
Covariate,Sedentary minutes,PAD680,PAQ
Covariate,Total cholesterol,LBXTC,TCHOL
Covariate,LDL cholesterol,LBDLDL,TRIGLY
", stringsAsFactors = FALSE, strip.white = TRUE)
ROLES <- ROLES[ROLES$variable != "", ]

SENT <- c(7, 9, 77, 99, 777, 999, 7777, 9999)

doc_url  <- function(comp, i, v) sprintf(
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/%s/DataFiles/%s_%s.htm#%s",
  CY$year1[i], comp, CY$sfx[i], v)
data_url <- function(comp, i) sprintf(
  "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/%s/DataFiles/%s_%s.xpt",
  CY$year1[i], comp, CY$sfx[i])

## ---- scan the raw files ----------------------------------------------------
scan_one <- function(comp, v) {
  present <- character(0); lab <- NA_character_
  vals <- numeric(0); nd <- 0
  for (i in seq_len(nrow(CY))) {
    f <- file.path(RAW, CY$cycle[i], sprintf("%s_%s.xpt", comp, CY$sfx[i]))
    if (!file.exists(f)) next
    d <- tryCatch(read_xpt(f), error = function(e) NULL); if (is.null(d)) next
    if (!v %in% names(d)) next
    present <- c(present, CY$sfx[i])
    if (is.na(lab)) { l <- attr(d[[v]], "label"); if (!is.null(l)) lab <- as.character(l) }
    x <- suppressWarnings(as.numeric(d[[v]])); vals <- c(vals, x[!is.na(x)])
  }
  if (!length(present)) return(NULL)
  nd <- length(unique(vals))
  # A sentinel is a RESERVED CODE only if it sits far outside the variable's own
  # legitimate range. Otherwise it is a measurement that merely looks like one.
  nonsent <- vals[!vals %in% SENT]
  ceiling_ok <- if (length(nonsent)) max(nonsent) else 0
  hits <- SENT[SENT %in% unique(vals)]
  codes <- hits[hits > 2 * ceiling_ok]
  reals <- setdiff(hits, codes)
  list(present = present, label = lab, n_distinct = nd,
       codes = codes, code_n = sapply(codes, function(s) sum(vals == s)),
       reals = reals, real_n = sapply(reals, function(s) sum(vals == s)),
       vmax = if (length(nonsent)) max(nonsent) else NA)
}

## ---- where each variable is used in our own code ---------------------------
rfiles <- list.files(file.path(PROJ, "R"), pattern = "\\.R$", full.names = TRUE)
rfiles <- rfiles[!grepl("07_variable_map", rfiles)]
provenance <- function(v) {
  for (f in rfiles) {
    txt <- readLines(f, warn = FALSE)
    ln  <- grep(paste0("\\b", v, "\\b"), txt)
    ln  <- ln[!grepl("^\\s*#", txt[ln])]        # a comment is not provenance
    if (length(ln)) return(sprintf("`R/%s:%d`", basename(f), ln[1]))
  }
  "—"
}

## ---- variables whose own CDC label will mislead you ------------------------
## Hand-authored, because it is a judgement about the documentation, not a fact
## readable from it. Each is a trap this project actually fell into.
CAUTION <- c(
  ALQ130 = paste(
    "CDC's **SAS Label** reads *\"Avg # alcohol drinks/day - past 12 mos\"*. CDC's",
    "**English Text** for the same variable reads *\"During the past 12 months, on those",
    "days that {you} drank alcoholic beverages, on the average, how many drinks did",
    "{you} have?\"* \u2014 that is drinks per *drinking* day. Applying a per-day",
    "threshold to it directly over-excludes ~2,000 people here; average intake needs",
    "frequency x quantity. **The short label is not the question.** Read the English",
    "Text, every time."),
  ALQ121 = paste(
    "Its reserved codes are **`77` (Refused) and `99` (Don't know)**, not the",
    "`777`/`999` used by `ALQ130` \u2014 a rule hard-coded to `c(777, 999)` misses",
    "them. And `7` and `9` are ordinary answers here: **7 = \"Once a month\"**,",
    "**9 = \"3 to 6 times in the last year\"**. CDC's own Analytic Notes state",
    "*\"ALQ120Q and ALQ120U became ALQ121\"* in 2017-18, so this is an instrument",
    "change, not a missing column."),
  BPXDI1 = paste("A diastolic reading of **0 is a measurement**. NHANES records a failure",
                 "to obtain a reading as `NA`, separately. Do not `na_if(., 0)`."),
  RIDRETH3 = paste("This is what identifies Asian participants for the paper's lower BMI",
                   "threshold - so the rule cannot be applied in 2007-2010 at all."),
  WTSAF2YR = paste("A **design** variable living in a laboratory file. Build the survey",
                   "design on the full frame, then `subset()` - never on the subsample alone.")
)

## Present in every cycle, but the instrument around them still changed, so the
## cycle-specific codebook matters even though the column never disappears.
CYCLE_SENSITIVE <- list(ALQ130 = "ALQ")

message("Scanning ", length(unique(ROLES$variable)), " variables across 6 cycles ...")
info <- list()
for (k in seq_len(nrow(ROLES))) {
  key <- paste(ROLES$component[k], ROLES$variable[k])
  if (is.null(info[[key]])) info[[key]] <- scan_one(ROLES$component[k], ROLES$variable[k])
}

## ---- emit ------------------------------------------------------------------
z <- file(OUT, open = "w", encoding = "UTF-8")
wr <- function(...) cat(..., "\n", sep = "", file = z)

wr("# NHANES variable map — the reproduction's own crosswalk\n")
wr("*Generated by `R/07_variable_map.R` from the files in `data/raw/`. Do not edit by hand.*")
wr("*Cycle availability, labels and missing-value conventions below were read out of the")
wr(".xpt files, not copied from documentation.*\n")
wr("Every variable this reproduction touches, and for each one the four things students")
wr("most often get wrong:\n")
wr("1. **Where it lives** — which component file, and therefore which download")
wr("2. **What its raw codes mean** — and whether a `77`-looking value is a code or a measurement")
wr("3. **Whether it exists in every cycle** — several do not")
wr("4. **What we did to it** — the line in our pipeline that reads or transforms it\n")
wr("> **This page is a method, not just an answer.** When you meet an unfamiliar NHANES")
wr("> variable in *your own* paper, these are the questions to ask of it, in this order.")
wr("> The loop runs: paper sentence \u2192 operational concept \u2192 NHANES variable")
wr("> \u2192 component \u2192 **that cycle's** codebook \u2192 raw `.xpt` \u2192 your")
wr("> implementation \u2192 cohort consequence.\n")
wr("Three different kinds of link, which are easy to conflate:\n")
wr("| Link | Goes to | Use it when |")
wr("|---|---|---|")
wr("| **codebook** | the CDC documentation page, anchored at that variable | you need the official definition, the value labels, or the frequencies |")
wr("| **.xpt** | the raw data file for that cycle | you are downloading it yourself |")
wr("| **our code** | the line in this pipeline that reads or derives it | you want to see what *we* did, and disagree with it |\n")
wr("Cycle letters: **E** 2007-08 · **F** 2009-10 · **G** 2011-12 · **H** 2013-14 ·")
wr("**I** 2015-16 · **J** 2017-18. The *file* name carries the suffix (`BMX_H.xpt`);")
wr("the *variable* name inside usually does not (`BMXBMI` in every cycle).\n")
wr("---\n")

for (r in unique(ROLES$role)) {
  sub <- ROLES[ROLES$role == r, ]
  wr("## ", r, "\n")
  wr("| Concept | Variable | Component | Cycles | Label (from the file) | Missing convention | Links |")
  wr("|---|---|---|---|---|---|---|")
  for (k in seq_len(nrow(sub))) {
    v <- sub$variable[k]; comp <- sub$component[k]
    nfo <- info[[paste(comp, v)]]
    if (is.null(nfo)) {
      wr("| ", sub$concept[k], " | `", v, "` | `", comp, "` | — | *not scanned* | — | — |"); next }
    allsix <- length(nfo$present) == 6
    cyc <- if (allsix) "all six" else paste0("**", paste(nfo$present, collapse = ""), " only**")
    conv <- if (length(nfo$codes))
      paste0("**reserved `", paste(nfo$codes, collapse = "`, `"), "`** (n=",
             paste(nfo$code_n, collapse = ", "), ") — strip before any rule")
    else "`NA` only"
    if (length(nfo$reals))
      conv <- paste0(conv, if (length(nfo$codes)) ", but " else " — ",
                     "`", paste(nfo$reals, collapse = "`, `"), "` ",
                     if (length(nfo$reals) > 1) "are real values" else "is a real value",
                     " (n=", paste(nfo$real_n, collapse = ", "), "): do **not** strip")
    i1 <- match(nfo$present[1], CY$sfx)
    wr("| ", sub$concept[k], " | `", v, "` | `", comp, "` | ", cyc, " | ",
       ifelse(is.na(nfo$label), "—", nfo$label),
       if (v %in% names(CAUTION)) " ⚠" else "", " | ", conv,
       " | [codebook](", doc_url(comp, i1, v), ") · [.xpt](", data_url(comp, i1),
       ") · ", provenance(v), " |")
  }
  wr("")
  caut <- intersect(unique(sub$variable), names(CAUTION))
  for (v in caut) wr("> ⚠ **`", v, "`** — ", CAUTION[[v]], "\n")
}

## ---- the two sections worth reading even if you skip the tables ------------
gaps <- do.call(rbind, lapply(names(info), function(k) {
  n <- info[[k]]; if (is.null(n) || length(n$present) == 6) return(NULL)
  data.frame(variable = sub(".* ", "", k), component = sub(" .*", "", k),
             present = paste(n$present, collapse = ""),
             absent = paste(setdiff(CY$sfx, n$present), collapse = ""),
             stringsAsFactors = FALSE) }))
wr("---\n\n## Not every variable exists in every cycle\n")
wr("Verified against the files, not assumed. `bind_rows()` will happily fill an absent")
wr("column with `NA` for a third of your sample, and that is **a changing instrument, not")
wr("**Which cycle's codebook are you reading?** For these variables that is not a")
wr("rhetorical question, so every applicable cycle is linked separately.\n")
wr("| Variable | Component | Present in | **Absent in** | Codebook, by cycle |")
wr("|---|---|---|---|---|")
percyc <- function(comp, sfxs) paste(vapply(sfxs, function(sx) {
    i <- match(sx, CY$sfx); sprintf("[%s](%s)", sx, sub("#$", "", doc_url(comp, i, "")))
  }, ""), collapse = " \u00b7 ")
if (!is.null(gaps)) for (k in seq_len(nrow(gaps)))
  wr("| `", gaps$variable[k], "` | `", gaps$component[k], "` | ", gaps$present[k],
     " | **", gaps$absent[k], "** | ",
     percyc(gaps$component[k], strsplit(gaps$present[k], "")[[1]]), " |")
for (v in names(CYCLE_SENSITIVE)) {
  nfo <- info[[paste(CYCLE_SENSITIVE[[v]], v)]]; if (is.null(nfo)) next
  wr("| `", v, "` | `", CYCLE_SENSITIVE[[v]], "` | all six | *none \u2014 but the ",
     "instrument around it changed in J* | ",
     percyc(CYCLE_SENSITIVE[[v]], nfo$present), " |")
}

wr("\n## Reserved codes are not a property of NHANES. They are a property of the variable.\n")
wr("The single most dangerous piece of half-learned NHANES advice is *\"strip 777 and 999\"*.")
wr("Applied to a laboratory variable it deletes real measurements. Below, every")
wr("sentinel-looking value this reproduction's variables actually contain, classified by")
wr("whether it sits outside the variable's own legitimate range.\n")
wr("| Variable | Reserved codes | Sentinel-looking values that are **real** | Largest legitimate value |")
wr("|---|---|---|---|")
for (k in names(info)) {
  n <- info[[k]]; if (is.null(n)) next
  if (!length(n$codes) && !length(n$reals)) next
  wr("| `", sub(".* ", "", k), "` | ",
     if (length(n$codes)) paste0("`", paste(n$codes, collapse = "`, `"), "`") else "none", " | ",
     if (length(n$reals)) paste0("`", paste(n$reals, collapse = "`, `"), "` (n=",
                                 paste(n$real_n, collapse = ", "), ")") else "—",
     " | ", ifelse(is.na(n$vmax), "—", format(n$vmax, big.mark = ",")), " |")
}
wr("\n> **What this table does and does not license.** For the variables used in this")
wr("> reproduction, the laboratory and examination measurements shown above use `NA` for")
wr("> missing, while several questionnaire variables use variable-specific reserved")
wr("> codes. **Do not generalise either pattern to another variable** \u2014 including")
wr("> another variable in the same component, or the same variable in another cycle.")
wr("> Check its codebook.")
wr(">")
wr("> A `77` in `LBXTR` is a triglyceride of 77 mg/dL. A `77` in `ALQ121` is a refusal.")
wr("> Same digits, opposite meaning. The point of this table is not a replacement rule")
wr("> to memorise; it is that **there is no such rule**, and the codebook decides.\n")

wr("\n## The outcome does not live in NHANES\n")
wr("| Concept | Variable | Source | Notes |")
wr("|---|---|---|---|")
wr("| Vital status | `MORTSTAT` | NCHS Linked Mortality File | separate fixed-width file, not an `.xpt` |")
wr("| Person-months from exam | `PERMTH_EXM` | NCHS Linked Mortality File | the clock for time-to-event |")
wr("| Linkage eligibility | `ELIGSTAT` | NCHS Linked Mortality File | not everyone is eligible for linkage |")
wr("\nDownloaded by `R/01_download.R` from")
wr("<https://ftp.cdc.gov/pub/Health_Statistics/NCHS/datalinkage/linked_mortality>.")
wr("Follow-up ends **31 December 2019**, per the NCHS 2019 linkage methodology document —")
wr("not inferred from the filename.\n")
wr("
---
")
wr("*Regenerate with `Rscript R/07_variable_map.R`. Codebook links use the current CDC")
wr("path `.../Public/<year>/DataFiles/<COMP>_<suffix>.htm#<VARIABLE>`; the older")
wr("`wwwn.cdc.gov/Nchs/Nhanes/<cycle>/` form no longer resolves.*")
close(z)
message("Wrote ", OUT)
