## Week 4, BMI-only version of the deck: the numbers it quotes.
##
## The paper crosses BMI with waist-to-height ratio to make four groups. The simplified
## Week 4 deck (lectures/slides/Week4_confounding_slides_bmi.qmd) teaches confounding
## with ONE exposure instead: obesity, defined as the paper defines it (BMI >= 30, or
## >= 25 for Asian participants). The paper never reports this comparison, so every
## number that deck quotes is computed here and written to Week4_bmi_exposure.json,
## never typed by hand.
##
## Run from this folder:   Rscript Week4_bmi_exposure.R
##
## Rows: the locked domain every increment uses (MASLD adults with a valid fasting
## weight, as in examples/P2_confounding/P2_code.qmd), restricted to people with
## complete data on every covariate of the largest model, so that all five models
## are fitted on the SAME people and differ only in what they adjust for.

source("../../examples/_shared/paths.R")   # find_repro(), fmtn(), endash()
repro <- find_repro()
suppressPackageStartupMessages({library(survival); library(jsonlite)})

.a <- readRDS(file.path(repro, "data/derived/masld_analytic.rds"))
.m <- readRDS(file.path(repro, "data/derived/merged_all.rds"))
.m$in_analysis <- .m$SEQN %in% .a$SEQN
dom <- .m[.m$in_analysis & !is.na(.m$WTSAF2YR) & .m$WTSAF2YR > 0, ]

## Obesity exactly as the paper (and 02_build_analytic.R) defines it; it equals
## phenotype Groups I + II.
stopifnot(all(dom$obese == as.integer(dom$group %in% c("I", "II"))))

## Model 2's two extra covariates, derived as reproduction/R/04_table2_cox.R does.
dom$smk_current <- ifelse(dom$SMQ020 == 1 & dom$SMQ040 %in% c(1, 2), 1L,
                          ifelse(is.na(dom$SMQ020), NA_integer_, 0L))
dom$sed  <- as.numeric(scale(dom$sedentary_min))
dom$race <- factor(dom$RIDRETH1)

COV1 <- c("age", "female", "dyslip", "htn", "t2dm", "ckd", "mi", "cancer",
          "on_htn_med", "on_dm_med", "on_lipid_med")       # the paper's Model 1
COV2 <- c(COV1, "smk_current", "sed")                        # the paper's Model 2
PRE  <- c("age", "female", "race", "smk_current", "sed")     # pre-exposure only
d <- dom[complete.cases(dom[, unique(c(COV2, PRE))]), ]

fit <- function(covs) {
  rhs <- paste(c("obese", covs), collapse = " + ")
  s <- summary(coxph(as.formula(paste("Surv(time_yr, dead) ~", rhs)), data = d))$conf.int
  c(hr = s["obese", 1], lo = s["obese", 3], hi = s["obese", 4])
}
models <- list(crude = character(0), agesex = c("age", "female"),
               m1 = COV1, m2 = COV2, pre = PRE)
est <- lapply(models, fit)
hrs <- vapply(est, function(e) sprintf("%.2f (%.2f–%.2f)", e["hr"], e["lo"], e["hi"]), "")
pts <- vapply(est, function(e) sprintf("%.2f", e["hr"]), "")
chg <- function(a, b) sprintf("%+.0f%%", 100 * (est[[b]]["hr"] / est[[a]]["hr"] - 1))

## Table 1 by obesity, on the same rows
grp  <- split(d, d$obese)             # "0" = not obese, "1" = obese
npct <- function(x) sprintf("%s (%.1f%%)", fmtn(sum(x == 1, na.rm = TRUE)), 100 * mean(x == 1, na.rm = TRUE))
msd  <- function(x) sprintf("%.1f (%.1f)", mean(x), sd(x))
smd  <- function(x) {
  a <- grp[["1"]][[x]]; b <- grp[["0"]][[x]]
  abs(mean(a) - mean(b)) / sqrt((var(a) + var(b)) / 2)
}
yw <- d$age < 40 & d$female == 1       # positivity example: women aged 18-39

facts <- list(
  obese_def      = "BMI ≥ 30 (≥ 25 for Asian participants)",
  n_domain       = fmtn(nrow(dom)),
  n_rows         = fmtn(nrow(d)),
  n_dropped      = fmtn(nrow(dom) - nrow(d)),
  n_obese        = fmtn(nrow(grp[["1"]])),
  n_nonobese     = fmtn(nrow(grp[["0"]])),
  died_obese     = npct(grp[["1"]]$dead),
  died_nonobese  = npct(grp[["0"]]$dead),
  hr_crude       = hrs[["crude"]],  pt_crude  = pts[["crude"]],
  hr_agesex      = hrs[["agesex"]], pt_agesex = pts[["agesex"]],
  hr_m1          = hrs[["m1"]],     pt_m1     = pts[["m1"]],
  hr_m2          = hrs[["m2"]],     pt_m2     = pts[["m2"]],
  hr_pre         = hrs[["pre"]],    pt_pre    = pts[["pre"]],
  chg_crude_agesex = chg("crude", "agesex"),
  chg_agesex_m1    = chg("agesex", "m1"),
  chg_m1_m2        = chg("m1", "m2"),
  chg_crude_m1     = chg("crude", "m1"),
  age_obese      = msd(grp[["1"]]$age),  age_nonobese = msd(grp[["0"]]$age),
  smd_age        = sprintf("%.2f", smd("age")),
  women_obese    = sprintf("%.1f%%", 100 * mean(grp[["1"]]$female)),
  women_nonobese = sprintf("%.1f%%", 100 * mean(grp[["0"]]$female)),
  smk_obese      = sprintf("%.1f%%", 100 * mean(grp[["1"]]$smk_current)),
  smk_nonobese   = sprintf("%.1f%%", 100 * mean(grp[["0"]]$smk_current)),
  t2dm_obese     = sprintf("%.1f%%", 100 * mean(grp[["1"]]$t2dm)),
  t2dm_nonobese  = sprintf("%.1f%%", 100 * mean(grp[["0"]]$t2dm)),
  tg_obese       = sprintf("%.0f", median(grp[["1"]]$LBXTR, na.rm = TRUE)),
  tg_nonobese    = sprintf("%.0f", median(grp[["0"]]$LBXTR, na.rm = TRUE)),
  ggt_obese      = sprintf("%.0f", median(grp[["1"]]$LBXSGTSI, na.rm = TRUE)),
  ggt_nonobese   = sprintf("%.0f", median(grp[["0"]]$LBXSGTSI, na.rm = TRUE)),
  yw_obese       = fmtn(sum(yw & d$obese == 1)),
  yw_nonobese    = fmtn(sum(yw & d$obese == 0))
)

## ---- Table 1's p-values and SMDs, as tableone prints them (the tool Lab 3 and P2 use) ----
t1 <- tableone::CreateTableOne(vars = c("dead", "age", "female", "smk_current", "t2dm"),
                               strata = "obese", data = d,
                               factorVars = c("dead", "female", "smk_current", "t2dm"))
t1p  <- print(t1, smd = TRUE, printToggle = FALSE, noSpaces = TRUE)
t1r  <- function(v) grep(paste0("^", v, " "), rownames(t1p), value = TRUE)
pval <- function(v) t1p[t1r(v), "p"]
smdv <- function(v) sprintf("%.2f", as.numeric(t1p[t1r(v), "SMD"]))
stopifnot(smdv("age") == facts$smd_age)          # same SMD formula as smd() above
facts <- c(facts, list(
  p_died = pval("dead"), p_age = pval("age"), p_women = pval("female"),
  p_smk = pval("smk_current"), p_t2dm = pval("t2dm"),
  smd_died = smdv("dead"), smd_women = smdv("female"),
  smd_smk = smdv("smk_current"), smd_t2dm = smdv("t2dm")))

## ---- Positivity: does every kind of person occur in both groups? ----
## (a) each person's chance of obesity given the pre-exposure covariates, and (b) the
## age band x sex x race/ethnicity x smoking cells, counting those with only one group.
ps   <- fitted(glm(obese ~ age + female + race + smk_current + sed, family = binomial, data = d))
cell <- table(interaction(cut(d$age, c(-Inf, 39, 59, Inf)), d$female, d$race,
                          d$smk_current, drop = TRUE), d$obese)
lone <- cell[, "0"] == 0 | cell[, "1"] == 0
facts <- c(facts, list(
  ps_min = sprintf("%.0f%%", 100 * min(ps)), ps_max = sprintf("%.0f%%", 100 * max(ps)),
  pos_cells = as.character(nrow(cell)), pos_cells_both = as.character(sum(!lone)),
  pos_cells_lone_n = as.character(sum(cell[lone, ]))))

## ---- A collider you can see: selecting on FLI >= 60 flips obesity vs triglycerides ----
## Everyone in the fasting subsample whose FLI can be computed (P1's funnel step 3),
## before and after the FLI >= 60 selection (P1's step 4).
fl <- subset(.m, age >= 18 & !is.na(WTSAF2YR) & WTSAF2YR > 0 & !is.na(LBXTR) &
               !is.na(LBXSGTSI) & !is.na(bmi) & !is.na(waist))
sel <- fl$fli >= 60
med <- function(x, g) sprintf("%.0f", tapply(x, g, median)[c("1", "0")])
tg_all <- med(fl$LBXTR, fl$obese); tg_sel <- med(fl$LBXTR[sel], fl$obese[sel])
gg_all <- med(fl$LBXSGTSI, fl$obese); gg_sel <- med(fl$LBXSGTSI[sel], fl$obese[sel])
rho <- function(i) sprintf("%+.2f", cor(fl$bmi[i], fl$LBXTR[i], method = "spearman"))
facts <- c(facts, list(
  n_fli = fmtn(nrow(fl)), n_fli60 = fmtn(sum(sel)),
  tg_all_obese = tg_all[1], tg_all_nonobese = tg_all[2],
  tg_sel_obese = tg_sel[1], tg_sel_nonobese = tg_sel[2],
  ggt_all_obese = gg_all[1], ggt_all_nonobese = gg_all[2],
  ggt_sel_obese = gg_sel[1], ggt_sel_nonobese = gg_sel[2],
  rho_all = rho(rep(TRUE, nrow(fl))), rho_sel = rho(sel)))
## the figure's data (BMI and TG only, no identifiers), for the collider scatter plot
write.csv(data.frame(bmi = round(fl$bmi, 1), tg = fl$LBXTR, fli60 = as.integer(sel)),
          "Week4_collider_points.csv", row.names = FALSE)

## ---- The Table 2 fallacy: one model's coefficients vs each question's own model ----
## One model, as a paper's Table 2 would print it; then, for each coefficient, the
## model its own DAG calls for (w4_table2_panels.png). Age is per 10 years.
d$age10 <- d$age / 10
cx <- function(rhs, term) {
  s <- summary(coxph(as.formula(paste("Surv(time_yr, dead) ~", rhs)), data = d))$conf.int
  sprintf("%.2f (%.2f–%.2f)", s[term, 1], s[term, 3], s[term, 4])
}
one <- "obese + central + age10 + female + t2dm"
pre <- paste(PRE, collapse = " + ")
facts <- c(facts, list(
  t2_obese  = cx(one, "obese"),   q_obese  = cx(paste("obese +", pre), "obese"),
  t2_waist  = cx(one, "central"), q_waist  = cx(paste("central + obese +", pre), "central"),
  t2_age    = cx(one, "age10"),   q_age    = cx("age10", "age10"),
  t2_t2dm   = cx(one, "t2dm"),    q_t2dm   = cx(paste("t2dm + obese + central +", pre), "t2dm")))

out <- list(emitted_by = "Week4_bmi_exposure", facts = facts,
            models = list(crude = "obese only", agesex = "obese + age + sex",
                          m1 = paste(c("obese", COV1), collapse = " + "),
                          m2 = paste(c("obese", COV2), collapse = " + "),
                          pre = paste(c("obese", PRE), collapse = " + ")))
writeLines(toJSON(out, auto_unbox = TRUE, pretty = TRUE), "Week4_bmi_exposure.json", useBytes = TRUE)
for (k in names(facts)) cat(sprintf("%-18s %s\n", k, facts[[k]]))
