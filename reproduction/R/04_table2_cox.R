# ============================================================================
# 04_table2_cox.R  --  Reproduce Table 2 (Cox regression, all-cause + CV death)
#   Unadjusted / Model 1 / Model 2 HRs for BMI-WHtR groups (ref = Group I).
#   Model 1: age, sex, dyslipidaemia, hypertension, T2DM, CKD, MI, cancer,
#            antihypertensive/antidiabetic/lipid-lowering medication use.
#   Model 2: Model 1 + smoking status + sedentary activity duration.
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
suppressPackageStartupMessages({library(dplyr); library(survival)})
d <- readRDS(file.path(DIR_DERIVED, "masld_analytic.rds"))

## smoking covariate for models: current smoker vs not (never-smokers -> 0)
d <- d %>% mutate(
  smk_current = ifelse(SMQ020==1 & SMQ040 %in% c(1,2), 1L,
                       ifelse(is.na(SMQ020), NA_integer_, 0L)),
  sed = as.numeric(scale(sedentary_min))          # standardise for stability
)

## choose CV death definition that matches the paper's 158 events
cat("CV events: heart-only(001) =", sum(d$mortstat==1 & d$ucod_leading==1, na.rm=TRUE),
    " heart+cerebro(001,005) =", sum(d$cv_death, na.rm=TRUE), " (paper 158)\n")
d$cv_heart <- as.integer(d$mortstat==1 & d$ucod_leading==1)

cov1 <- c("age","female","dyslip","htn","t2dm","ckd","mi","cancer",
          "on_htn_med","on_dm_med","on_lipid_med")
cov2 <- c(cov1, "smk_current", "sed")

## fit a model, return HR (95% CI) + p for groups II/III/IV
fit_hr <- function(outcome, time, covs = NULL, data = d) {
  rhs <- paste(c("group", covs), collapse = " + ")
  f <- as.formula(sprintf("Surv(%s, %s) ~ %s", time, outcome, rhs))
  m <- coxph(f, data = data)
  s <- summary(m)
  g <- c("groupII","groupIII","groupIV")
  out <- sapply(g, function(k) {
    if (!k %in% rownames(s$conf.int)) return(c(NA,NA,NA,NA))
    c(s$conf.int[k,"exp(coef)"], s$conf.int[k,"lower .95"],
      s$conf.int[k,"upper .95"], s$coefficients[k,"Pr(>|z|)"])
  })
  data.frame(group = c("II","III","IV"),
             hr = out[1,], lo = out[2,], hi = out[3,], p = out[4,],
             n = m$n, ev = m$nevent, row.names = NULL)
}
fmt <- function(hr,lo,hi) ifelse(is.na(hr), "-", sprintf("%.2f (%.2f-%.2f)", hr, lo, hi))
fmtp<- function(p) ifelse(is.na(p), "-", ifelse(p<0.001,"<0.001",sprintf("%.3f",p)))

build_panel <- function(outcome, label) {
  n_risk <- as.integer(table(d$group))
  ev     <- tapply(d[[outcome]], d$group, sum, na.rm=TRUE)
  u  <- fit_hr(outcome, "time_yr")
  m1 <- fit_hr(outcome, "time_yr", cov1)
  m2 <- fit_hr(outcome, "time_yr", cov2)
  data.frame(
    Outcome = c(label, rep("", 3)),
    Group   = c("I (ref)","II","III","IV"),
    N_risk  = n_risk,
    Events  = sprintf("%d (%.1f)", as.integer(ev), 100*as.integer(ev)/n_risk),
    Unadj   = c("Reference", fmt(u$hr,u$lo,u$hi)),
    Unadj_p = c("-", fmtp(u$p)),
    Model1  = c("Reference", fmt(m1$hr,m1$lo,m1$hi)),
    M1_p    = c("-", fmtp(m1$p)),
    Model2  = c("Reference", fmt(m2$hr,m2$lo,m2$hi)),
    M2_p    = c("-", fmtp(m2$p)),
    check.names = FALSE)
}

t2_all <- build_panel("dead",     "All-cause mortality")
t2_cv  <- build_panel("cv_heart", "Cardiovascular mortality")
t2 <- rbind(t2_all, t2_cv)
write.csv(t2, file.path(DIR_TABLES, "table2_reproduced.csv"), row.names = FALSE)
suppressPackageStartupMessages({library(knitr); library(kableExtra)})
kbl(t2, format = "html", row.names = FALSE,
    caption = "Table 2 (reproduced): Cox regression of mortality by BMI/WHtR group") |>
  kable_styling(bootstrap_options = c("striped","condensed"), full_width = FALSE) |>
  save_kable(file.path(DIR_TABLES, "table2_reproduced.html"))

cat("\n===== TABLE 2 (reproduced) =====\n")
print(t2, row.names = FALSE)

## ---- compare to published HRs ---------------------------------------------
cat("\n===== Published Table 2 (for comparison) =====\n")
cat("ALL-CAUSE  events: I 5(1.3) II 388(8.5) III 74(9.6) IV 118(19.5)\n")
cat("  Unadj:  II 6.66(2.76-16.09)  III 6.25(2.53-15.47)  IV 15.13(6.18-37.02)\n")
cat("  Model1: II 2.44(1.00-5.93)p.049  III 3.18(1.28-7.88)p.013  IV 3.16(1.28-7.81)p.013\n")
cat("  Model2: II 2.30(0.94-5.60)p.067  III 3.03(1.22-7.53)p.017  IV 2.89(1.17-7.17)p.022\n")
cat("CV  events: I 1(0.3) II 112(2.5) III 19(2.5) IV 26(4.3)\n")
cat("  Unadj:  II 9.64(1.35-69.05)  III 8.11(1.09-60.61)  IV 16.75(2.27-123.4)\n")
cat("\nSaved output/tables/table2_reproduced.csv\n")
