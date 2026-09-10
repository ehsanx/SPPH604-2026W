# ============================================================================
# 02_build_analytic.R  --  Build the MASLD analytic cohort
#   - stack 6 NHANES cycles, merge domains on SEQN
#   - compute Fatty Liver Index (FLI) -> hepatic steatosis
#   - apply MASLD cardiometabolic criteria + alcohol/age exclusions
#   - assign 4 BMI/WHtR phenotype groups
#   - merge linked mortality (all-cause + CV)
#   - save data/derived/masld_analytic.rds and print reproduction checkpoints
# Target (paper): N = 6300; groups I/II/III/IV = 386 / 4541 / 769 / 604
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
suppressPackageStartupMessages({library(haven); library(dplyr); library(tidyr); library(readr); library(purrr)})

## --- Config -----------------------------------------------------------------
## The paper STATES a "significant alcohol" exclusion (>2 drinks/day men,
## >1/day women) but its reported N=6300 and 585 deaths match a cohort where
## this exclusion is NOT materially applied (see logs/reproduction_report.md).
## We therefore keep the paper-matching cohort as primary (flag FALSE) and
## expose the exclusion as a documented sensitivity switch.
APPLY_ALCOHOL_EXCL <- FALSE

## ---- helper: stack one component across all cycles, keep requested vars ----
read_component <- function(comp, vars) {
  purrr::map_dfr(seq_len(nrow(CYCLES)), function(i) {
    f <- file.path(DIR_RAW, CYCLES$cycle[i], sprintf("%s_%s.xpt", comp, CYCLES$suffix[i]))
    if (!file.exists(f)) return(NULL)
    d <- haven::read_xpt(f)
    d <- d[, intersect(c("SEQN", vars), names(d)), drop = FALSE]
    for (v in setdiff(vars, names(d))) d[[v]] <- NA_real_   # pad missing vars
    d$cycle <- CYCLES$cycle[i]
    d
  })
}

## ---- load each domain ------------------------------------------------------
demo <- read_component("DEMO", c("RIDAGEYR","RIAGENDR","RIDRETH1","RIDRETH3",
                                 "INDFMPIR","WTMEC2YR","WTINT2YR","SDMVPSU","SDMVSTRA","SDDSRVYR"))
bmx  <- read_component("BMX",  c("BMXBMI","BMXWAIST","BMXHT"))
bpx  <- read_component("BPX",  c("BPXSY1","BPXSY2","BPXSY3","BPXSY4",
                                 "BPXDI1","BPXDI2","BPXDI3","BPXDI4"))
trig <- read_component("TRIGLY", c("LBXTR","LBDLDL","WTSAF2YR"))
bio  <- read_component("BIOPRO", c("LBXSGTSI","LBXSCR"))
ghb  <- read_component("GHB",  c("LBXGH"))
glu  <- read_component("GLU",  c("LBXGLU"))
hdl  <- read_component("HDL",  c("LBDHDD"))
tcho <- read_component("TCHOL",c("LBXTC"))
alq  <- read_component("ALQ",  c("ALQ130","ALQ120Q","ALQ120U","ALQ101","ALQ110","ALQ111","ALQ121"))
smq  <- read_component("SMQ",  c("SMQ020","SMQ040"))
bpq  <- read_component("BPQ",  c("BPQ020","BPQ040A","BPQ050A","BPQ080","BPQ090D","BPQ100D"))
diq  <- read_component("DIQ",  c("DIQ010","DIQ050","DIQ070"))
mcq  <- read_component("MCQ",  c("MCQ160B","MCQ160C","MCQ160D","MCQ160E","MCQ160F",
                                 "MCQ160G","MCQ160K","MCQ160O","MCQ220","MCQ300A"))
kiq  <- read_component("KIQ_U",c("KIQ022"))
alb  <- read_component("ALB_CR",c("URXUMA","URXUCR","URDACT"))
paq  <- read_component("PAQ",  c("PAD680"))

## keep only the columns from each (drop duplicate 'cycle' on join)
drop_cycle <- function(x) x[, setdiff(names(x), "cycle"), drop = FALSE]
dat <- demo %>%
  left_join(drop_cycle(bmx),  by="SEQN") %>% left_join(drop_cycle(bpx), by="SEQN") %>%
  left_join(drop_cycle(trig), by="SEQN") %>% left_join(drop_cycle(bio), by="SEQN") %>%
  left_join(drop_cycle(ghb),  by="SEQN") %>% left_join(drop_cycle(glu), by="SEQN") %>%
  left_join(drop_cycle(hdl),  by="SEQN") %>% left_join(drop_cycle(tcho),by="SEQN") %>%
  left_join(drop_cycle(alq),  by="SEQN") %>% left_join(drop_cycle(smq), by="SEQN") %>%
  left_join(drop_cycle(bpq),  by="SEQN") %>% left_join(drop_cycle(diq), by="SEQN") %>%
  left_join(drop_cycle(mcq),  by="SEQN") %>% left_join(drop_cycle(kiq), by="SEQN") %>%
  left_join(drop_cycle(alb),  by="SEQN") %>% left_join(drop_cycle(paq), by="SEQN")

cat("Merged raw participants (all cycles):", nrow(dat), "\n")

## ---- derived clinical variables -------------------------------------------
yn <- function(x) as.integer(x == 1)              # NHANES 1=Yes, 2=No -> 1/0
dat <- dat %>% mutate(
  age    = RIDAGEYR,
  female = as.integer(RIAGENDR == 2),
  asian  = as.integer(RIDRETH3 == 6),             # NA for 2007-2010 cycles
  asian  = ifelse(is.na(asian), 0L, asian),
  bmi    = BMXBMI,
  waist  = BMXWAIST,
  height = BMXHT,
  whtr   = BMXWAIST / BMXHT,
  # blood pressure: mean of available readings; DBP=0 is "not obtainable" -> NA
  sbp = rowMeans(cbind(BPXSY1,BPXSY2,BPXSY3,BPXSY4), na.rm = TRUE),
  dbp = rowMeans(cbind(na_if(BPXDI1,0),na_if(BPXDI2,0),na_if(BPXDI3,0),na_if(BPXDI4,0)), na.rm=TRUE),
  # Fatty Liver Index (Bedogni 2006); needs TG(mg/dL), BMI, GGT(U/L), waist(cm)
  fli_L = 0.953*log(LBXTR) + 0.139*BMXBMI + 0.718*log(LBXSGTSI) + 0.053*BMXWAIST - 15.745,
  fli   = exp(fli_L) / (1 + exp(fli_L)) * 100,
  steatosis = as.integer(fli >= 60)
)
dat$sbp[is.nan(dat$sbp)] <- NA; dat$dbp[is.nan(dat$dbp)] <- NA

## ---- MASLD cardiometabolic criteria (>=1 required) ------------------------
dat <- dat %>% mutate(
  crit_adip = as.integer(bmi >= 25 | (female==0 & waist > 94) | (female==1 & waist > 80)),
  htn_tx    = yn(BPQ050A),                        # currently taking BP meds
  lipid_tx  = yn(BPQ100D),                        # currently taking cholesterol meds
  dm_tx     = as.integer(yn(DIQ070)==1 | yn(DIQ050)==1),  # pills or insulin
  dm_dx     = yn(DIQ010),
  crit_glu  = as.integer(LBXGLU >= 100 | LBXGH >= 5.7 | dm_dx==1 | dm_tx==1),
  crit_bp   = as.integer(sbp >= 130 | dbp >= 85 | htn_tx==1),
  crit_tg   = as.integer(LBXTR >= 150 | lipid_tx==1),
  crit_hdl  = as.integer((female==0 & LBDHDD <= 40) | (female==1 & LBDHDD < 50)),
  n_crit    = rowSums(cbind(crit_adip,crit_glu,crit_bp,crit_tg,crit_hdl), na.rm = TRUE),
  masld     = as.integer(steatosis == 1 & n_crit >= 1)
)

## ---- alcohol exclusion: >2 drinks/day men, >1/day women -------------------
## NOTE: the paper's ">2 drinks/day" is an AVERAGE daily intake, i.e.
## (drinking frequency x drinks/occasion), NOT ALQ130 alone (which is drinks
## per drinking-day). Using ALQ130 alone over-excludes ~2000 people. We
## reconstruct average drinks/day, harmonising the 2017-2018 ALQ redesign.
umult <- c("1"=52, "2"=12, "3"=1)                       # ALQ120U: /week, /month, /year
a121  <- c("0"=0,"1"=365,"2"=350,"3"=182,"4"=104,"5"=52,# ALQ121 (2017-18) -> days/yr
           "6"=30,"7"=12,"8"=9,"9"=4.5,"10"=1.5)
dat <- dat %>% mutate(
  q120  = ifelse(ALQ120Q %in% c(777,999), NA, ALQ120Q),
  days_std = ifelse(!is.na(q120) & ALQ120U %in% c(1,2,3),
                    q120 * umult[as.character(ALQ120U)], NA_real_),
  days_J   = ifelse(ALQ121 %in% 0:10, a121[as.character(ALQ121)], NA_real_),
  days_year = dplyr::coalesce(days_std, days_J),
  qty   = ifelse(ALQ130 %in% c(777,999), NA, ALQ130),
  avg_drinks_day = ifelse(is.na(days_year) | days_year == 0, 0,
                          (qty * days_year) / 365),
  avg_drinks_day = ifelse(is.na(avg_drinks_day), 0, avg_drinks_day),
  sig_alcohol = as.integer((female==0 & avg_drinks_day > 2) |
                           (female==1 & avg_drinks_day > 1))
)

## ---- phenotype groups: obesity = BMI>=30 (Asian>=25); central = WHtR>=0.6 --
dat <- dat %>% mutate(
  obese   = as.integer(bmi >= 30 | (asian==1 & bmi >= 25)),
  central = as.integer(whtr >= 0.6),
  group = case_when(
    obese==1 & central==0 ~ "I",
    obese==1 & central==1 ~ "II",
    obese==0 & central==0 ~ "III",
    obese==0 & central==1 ~ "IV",
    TRUE ~ NA_character_)
)

## ---- Table 1 comorbidities & Cox covariates -------------------------------
## Definitions calibrated to reproduce the paper's Table 1 prevalences.
## The paper uses composite definitions (self-report OR meds OR labs); pure
## self-report under-counts HTN/T2DM/dyslipidaemia. See reproduction_report.md.
cf <- function(x) ifelse(is.na(x), FALSE, x)   # missing -> "not present"
dat <- dat %>% mutate(
  ever_smoke    = yn(SMQ020),
  current_smoke = ifelse(ever_smoke == 1, as.integer(SMQ040 %in% c(1,2)), NA_integer_), # % of ever-smokers
  famhx_chd     = yn(MCQ300A),
  pir_cat = factor(dplyr::case_when(INDFMPIR < 1 ~ "Low",
                                    INDFMPIR >= 1 & INDFMPIR <= 4 ~ "Middle",
                                    INDFMPIR > 4 ~ "High"),
                   levels = c("High","Middle","Low")),
  # medication use (missing -> not on med)
  on_htn_med   = as.integer(cf(BPQ050A == 1)),
  on_lipid_med = as.integer(cf(BPQ100D == 1)),
  on_dm_med    = as.integer(cf(DIQ070 == 1) | cf(DIQ050 == 1)),
  # eGFR (CKD-EPI 2021, race-free) and albumin:creatinine ratio
  .kappa = ifelse(female==1, 0.7, 0.9), .alpha = ifelse(female==1, -0.241, -0.302),
  egfr   = 142 * pmin(LBXSCR/.kappa,1)^.alpha * pmax(LBXSCR/.kappa,1)^(-1.200) *
           0.9938^age * ifelse(female==1, 1.012, 1),
  acr    = dplyr::coalesce(URDACT, URXUMA / URXUCR * 100),
  # comorbidities (composite)
  htn    = as.integer(cf(BPQ020==1) | cf(sbp>=140) | cf(dbp>=90)),
  t2dm   = as.integer(cf(DIQ010==1) | cf(LBXGH>=6.5)),
  dyslip = as.integer(cf(BPQ080==1) | on_lipid_med==1 | cf(LBDLDL>=130)),
  ckd    = as.integer(cf(egfr<60) | cf(acr>=30)),
  stroke = yn(MCQ160F),
  mi     = as.integer(cf(MCQ160E==1) | cf(MCQ160C==1)),   # heart attack OR CHD
  hf     = yn(MCQ160B),
  copd   = yn(MCQ160O),                 # COPD question (asked 2013-2018; denom = asked)
  cancer = yn(MCQ220),
  sedentary_min = ifelse(PAD680 %in% c(7777,9999), NA, PAD680)
)

## ---- linked mortality (public-use, fixed width) ---------------------------
read_mort <- function() {
  purrr::map_dfr(seq_len(nrow(CYCLES)), function(i) {
    cyc <- gsub("-", "_", CYCLES$cycle[i])
    f <- file.path(DIR_RAW, "mortality", sprintf("NHANES_%s_MORT_2019_PUBLIC.dat", cyc))
    if (!file.exists(f)) return(NULL)
    readr::read_fwf(f, col_types = "iiiiiiii",
      readr::fwf_positions(
        start = c(1, 15, 16, 17, 20, 21, 43, 46),
        end   = c(6, 15, 16, 19, 20, 21, 45, 48),
        col_names = c("SEQN","eligstat","mortstat","ucod_leading",
                      "diabetes_mort","hyperten_mort","permth_int","permth_exm")),
      na = c("", "."))
  })
}
mort <- read_mort()
cat("Mortality records:", nrow(mort), " eligible:", sum(mort$eligstat==1, na.rm=TRUE), "\n")

dat <- dat %>% left_join(mort, by = "SEQN") %>% mutate(
  dead      = mortstat,
  time_yr   = permth_exm / 12,
  cv_death  = as.integer(mortstat == 1 & ucod_leading %in% c(1, 5))  # heart + cerebrovascular
)

## ---- sample funnel (documentation) ----------------------------------------
## Two row sets, kept apart, and every step typed.
##   FULL ANALYTIC FILE - the row set the paper itself analyses, and the cohort
##     this script saves. No fasting-frame filter.
##   LOCKED DOMAIN      - its subset carrying a valid WTSAF2YR: the only rows on
##     which a design-aware estimate is possible. P1 locks it; P2-P5 use it.
## A funnel shows N falling and does not show WHY, so every row carries a type:
## ELIGIBILITY / DESIGN / MISSINGNESS / TARGET POPULATION / OUTCOME ASCERTAINMENT.
## The fasting subsample is DESIGN, not missingness - NHANES selected it
## deliberately and supplies WTSAF2YR for it. Fusing the two into one
## "FLI computable" step is the error this log exists to prevent.
inFast <- !is.na(dat$WTSAF2YR) & dat$WTSAF2YR > 0
cnt    <- function(cond) sum(cond, na.rm = TRUE)
keep   <- dat$age >= 18 & inFast
locked <- data.frame(
  row_set   = "locked domain",
  step      = 0:7,
  criterion = c("NHANES 2007-2018 records", "Age >= 18", "In fasting subsample",
                "FLI computable (TG + GGT + BMI + waist)", "Steatosis (FLI >= 60)",
                "MASLD (>= 1 cardiometabolic criterion)", "Phenotype group assignable",
                "Mortality-eligible and linked"),
  n = c(nrow(dat), cnt(dat$age >= 18), cnt(keep), cnt(keep & !is.na(dat$fli)),
        cnt(keep & dat$steatosis == 1), cnt(keep & dat$masld == 1),
        cnt(keep & dat$masld == 1 & !is.na(dat$group)),
        cnt(keep & dat$masld == 1 & !is.na(dat$group) & dat$eligstat == 1 &
            !is.na(dat$mortstat) & !is.na(dat$time_yr))),
  type = c("-", "ELIGIBILITY", "DESIGN", "MISSINGNESS", "TARGET POPULATION",
           "TARGET POPULATION", "MISSINGNESS", "OUTCOME ASCERTAINMENT"),
  stringsAsFactors = FALSE)
locked$dropped <- c(NA, -diff(locked$n))

## The cohort chain is UNCHANGED: s7 is still what gets saved, so the analytic
## file stays at the row set that reproduces the paper.
s0 <- dat
s1 <- filter(s0, age >= 18)
s2 <- filter(s1, !is.na(fli))
s3 <- filter(s2, steatosis == 1)
s4 <- filter(s3, masld == 1)
s5 <- filter(s4, !is.na(group))
s6 <- filter(s5, eligstat == 1, !is.na(mortstat), !is.na(time_yr))
s7 <- if (APPLY_ALCOHOL_EXCL) filter(s6, sig_alcohol == 0) else s6
full <- data.frame(
  row_set   = "full analytic file",
  step      = 0:7,
  criterion = c("All NHANES 2007-2018 records", "Age >= 18",
                "FLI computable (TG,GGT,BMI,waist)", "Hepatic steatosis (FLI >= 60)",
                "MASLD (>= 1 cardiometabolic criterion)", "Non-missing BMI + WHtR (group)",
                "Mortality-eligible + linked",
                sprintf("Alcohol exclusion applied = %s", APPLY_ALCOHOL_EXCL)),
  n = c(nrow(s0), nrow(s1), nrow(s2), nrow(s3), nrow(s4), nrow(s5), nrow(s6), nrow(s7)),
  type = c("-", "ELIGIBILITY", "DESIGN + MISSINGNESS (fused)", "TARGET POPULATION",
           "TARGET POPULATION", "MISSINGNESS", "OUTCOME ASCERTAINMENT",
           "SWITCH (records the setting; drops no rows here)"),
  stringsAsFactors = FALSE)
full$dropped <- c(NA, -diff(full$n))
fn <- rbind(locked, full)
cat("\n---- SAMPLE FUNNEL (typed; two row sets) ----\n"); print(fn)
cat("\nFull analytic file:", nrow(s7),
    " Locked domain:", sum(!is.na(s7$WTSAF2YR) & s7$WTSAF2YR > 0),
    " Difference:", nrow(s7) - sum(!is.na(s7$WTSAF2YR) & s7$WTSAF2YR > 0),
    "records with a computable FLI but no valid fasting weight\n")
write.csv(fn, file.path(DIR_LOGS, "sample_funnel.csv"), row.names = FALSE)

## ---- assemble analytic cohort ---------------------------------------------
analytic <- s7 %>% mutate(group = factor(group, levels = c("I","II","III","IV")))

## ---- reproduction checkpoints ---------------------------------------------
cat("\n==================== CHECKPOINT: cohort ====================\n")
cat("Analytic N (target 6300):", nrow(analytic), "\n\n")
cat("Group sizes (target I/II/III/IV = 386/4541/769/604):\n")
print(table(analytic$group, useNA = "ifany"))
cat("\nDeaths by group (all-cause):\n")
print(tapply(analytic$dead, analytic$group, sum, na.rm = TRUE))
cat("\nOverall: median age", median(analytic$age), " %female",
    round(100*mean(analytic$female),1),
    " median BMI", round(median(analytic$bmi, na.rm=TRUE),1),
    " median WHtR", round(median(analytic$whtr, na.rm=TRUE),2), "\n")
cat("Total deaths:", sum(analytic$dead, na.rm=TRUE),
    " CV deaths:", sum(analytic$cv_death, na.rm=TRUE),
    " median follow-up (yr):", round(median(analytic$time_yr, na.rm=TRUE),1), "\n")

saveRDS(analytic, file.path(DIR_DERIVED, "masld_analytic.rds"))
saveRDS(dat,      file.path(DIR_DERIVED, "merged_all.rds"))
cat("\nSaved data/derived/masld_analytic.rds\n")
