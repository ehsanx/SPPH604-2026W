## Week 5: the numbers the effect-modification / interaction deck quotes.
##
## The paper's four phenotype groups are two exposures crossed: obesity (BMI >= 30, or
## >= 25 for Asian participants) and high waist fat (WHtR >= 0.6). Week 4 taught
## confounding with obesity alone; Week 5 asks the two questions the 2 x 2 raises:
##
##   * EFFECT MODIFICATION -- does high waist fat's effect on death differ between the
##     obese and the non-obese?  (one exposure, WHtR; obesity is the modifier)
##   * INTERACTION -- what do the two together do, compared with what each does alone?
##     (two exposures)
##
## The paper never reports either, so every number the deck quotes is computed here and
## written to Week5_joint_exposure.json, never typed by hand.
##
## Run from this folder:   Rscript Week5_joint_exposure.R
##
## Rows: exactly Week 4's -- the locked domain (MASLD adults with a valid fasting weight),
## restricted to people complete on every covariate of the paper's Model 2 and of the
## pre-exposure set, so all models share rows. Adjustment: Week 4's PRE-EXPOSURE set (age,
## sex, race/ethnicity, smoking, sedentary time), the set Week 4 recommends for a causal
## question. The paper's Model 1 conditions are deliberately NOT used: Week 4 showed some
## are plausibly mediators.
##
## The sex example (P3's locked IV-vs-III question) is quoted in the deck from
## examples/_results/P3.json; this script adds the pre-exposure-set version and the crude
## IV-vs-I table P3 retired, on P3's own rows.

source("../../examples/_shared/paths.R")   # find_repro(), fmtn(), endash()
repro <- find_repro()
suppressPackageStartupMessages({library(survival); library(jsonlite)})

.a <- readRDS(file.path(repro, "data/derived/masld_analytic.rds"))
.m <- readRDS(file.path(repro, "data/derived/merged_all.rds"))
.m$in_analysis <- .m$SEQN %in% .a$SEQN
dom <- .m[.m$in_analysis & !is.na(.m$WTSAF2YR) & .m$WTSAF2YR > 0, ]

## The phenotype is the obesity x waist-fat cross, exactly.
stopifnot(all(dom$obese == as.integer(dom$group %in% c("I", "II"))),
          all(dom$central == as.integer(dom$group %in% c("II", "IV"))))

dom$smk_current <- ifelse(dom$SMQ020 == 1 & dom$SMQ040 %in% c(1, 2), 1L,
                          ifelse(is.na(dom$SMQ020), NA_integer_, 0L))
dom$sed  <- as.numeric(scale(dom$sedentary_min))
dom$race <- factor(dom$RIDRETH1)
dom$group <- factor(dom$group, levels = c("I", "II", "III", "IV"))

COV1 <- c("age", "female", "dyslip", "htn", "t2dm", "ckd", "mi", "cancer",
          "on_htn_med", "on_dm_med", "on_lipid_med")
COV2 <- c(COV1, "smk_current", "sed")
PRE  <- c("age", "female", "race", "smk_current", "sed")
d <- dom[complete.cases(dom[, unique(c(COV2, PRE))]), ]
stopifnot(nrow(d) == 5911)                          # Week 4's rows, unchanged
pre <- paste(PRE, collapse = " + ")

f2  <- function(x) sprintf("%.2f", x)
fci <- function(e, l, u) sprintf("%.2f (%.2f–%.2f)", e, l, u)
pct <- function(x) sprintf("%.1f%%", 100 * x)
## risks and risk differences in percentage points, with a true minus sign
pp  <- function(x) sub("^-", "−", sprintf("%+.1f", 100 * x))
ppci <- function(e, q) sprintf("%s (%s to %s)", pp(e), pp(q[1]), pp(q[2]))

## ---------------------------------------------------------------- 1. the 2 x 2, counted
cell <- function(g) {
  x <- d[d$group == g, ]
  list(n = fmtn(nrow(x)), deaths = fmtn(sum(x$dead)), died = pct(mean(x$dead)))
}
cells <- lapply(setNames(levels(d$group), levels(d$group)), cell)
facts <- list(n_rows = fmtn(nrow(d)))
for (g in names(cells)) for (k in names(cells[[g]]))
  facts[[paste0(k, "_", g)]] <- cells[[g]][[k]]
facts$n_obese    <- fmtn(sum(d$obese == 1))
facts$n_nonobese <- fmtn(sum(d$obese == 0))
facts$dead_I_men   <- as.character(sum(d$dead[d$group == "I" & d$female == 0]))
facts$dead_I_women <- as.character(sum(d$dead[d$group == "I" & d$female == 1]))
facts$n_I_women    <- fmtn(sum(d$group == "I" & d$female == 1))

## ---------------------------------------------------------------- 2. one model, two forms
## (a) joint-variable form: one 4-level factor; (b) product-term form: obese * central.
## Saturated in the exposures, so they are the same model (EpiMethods confounding9).
fj <- coxph(as.formula(paste("Surv(time_yr, dead) ~ group +", pre)), data = d)
fp <- coxph(as.formula(paste("Surv(time_yr, dead) ~ obese * central +", pre)), data = d)
stopifnot(abs(fj$loglik[2] - fp$loglik[2]) < 1e-6)

## HRs of every cell against Group I (obese, lower waist fat): the lowest-risk cell, and
## the paper's own reference.
sj <- summary(fj)$conf.int
for (g in c("II", "III", "IV"))
  facts[[paste0("hr_", g, "_vs_I")]] <- fci(sj[paste0("group", g), 1],
                                            sj[paste0("group", g), 3], sj[paste0("group", g), 4])

## Effect of high waist fat WITHIN each obesity stratum (the effect-modification view).
lc <- function(fit, w) {                       # exp(w'b) with a Wald CI
  b <- coef(fit); V <- vcov(fit); w <- w[names(b)]; w[is.na(w)] <- 0
  e <- sum(w * b); se <- sqrt(drop(t(w) %*% V %*% w))
  c(est = exp(e), lo = exp(e - 1.96 * se), hi = exp(e + 1.96 * se), z = e / se)
}
W <- function(...) { v <- c(...); v }
nonob <- lc(fp, W(central = 1))                            # IV vs III
ob    <- lc(fp, W(central = 1, `obese:central` = 1))       # II vs I
mult  <- lc(fp, W(`obese:central` = 1))                    # (II vs I) / (IV vs III)
p_mult <- summary(fp)$coefficients["obese:central", "Pr(>|z|)"]
## Both methods are large-sample approximations. Group I's 4 deaths make their
## difference worth showing, with each interval paired to its own test.
fa <- coxph(as.formula(paste("Surv(time_yr, dead) ~ obese + central +", pre)), data = d)
stopifnot(identical(rownames(fa$y), rownames(fp$y)),
          fa$n == fp$n, fp$n == nrow(d), fp$nevent == sum(d$dead))
p_lrt <- anova(fa, fp)$`Pr(>|Chi|)`[2]
d$oc <- d$obese * d$central
prof <- function(b) {
  f <- coxph(as.formula(paste("Surv(time_yr, dead) ~ obese + central + offset(bb * oc) +", pre)),
             data = transform(d, bb = b))
  2 * (fp$loglik[2] - f$loglik[2]) - qchisq(0.95, 1)
}
b0 <- coef(fp)[["obese:central"]]
pci <- exp(c(uniroot(prof, c(b0 - 4, b0))$root, uniroot(prof, c(b0, b0 + 4))$root))
## Week 4's Table 2 "Q2" model: waist fat adjusted for obesity and L, with NO product
## term -- one waist-fat HR for everyone. It must equal Week 4's emitted q_waist.
nomod <- summary(fa)$conf.int["central", ]
w4 <- fromJSON("Week4_bmi_exposure.json")$facts
stopifnot(identical(fci(nomod[1], nomod[3], nomod[4]), w4$q_waist))
## Sensitivity: obesity is a 0/1 cut of BMI; adjust for BMI itself as well.
fb <- coxph(as.formula(paste("Surv(time_yr, dead) ~ obese * central + bmi +", pre)), data = d)
bb <- coef(fb)
facts <- c(facts, list(
  hr_whtr_nonobese = fci(nonob["est"], nonob["lo"], nonob["hi"]),
  hr_whtr_obese    = fci(ob["est"], ob["lo"], ob["hi"]),
  n_model         = fmtn(fp$n),
  events_model    = fmtn(fp$nevent),
  rhr_whtr         = fci(mult["est"], mult["lo"], mult["hi"]),
  p_rhr_whtr       = sprintf("%.2f", p_mult),
  p_lrt_whtr       = sprintf("%.2f", p_lrt),
  rhr_whtr_profile = sprintf("%.2f–%.2f", pci[1], pci[2]),
  hr_waist_nomod   = w4$q_waist,
  bmi_whtr_obese    = f2(exp(bb[["central"]] + bb[["obese:central"]])),
  bmi_whtr_nonobese = f2(exp(bb[["central"]])),
  bmi_rhr_whtr      = f2(exp(bb[["obese:central"]]))))

## Week 4's positivity check, applied to the new exposure: within each obesity stratum,
## each person's chance of high waist fat given L.
psw <- function(x) fitted(glm(central ~ age + female + race + smk_current + sed,
                              family = binomial, data = x))
ps_ob <- psw(d[d$obese == 1, ]); ps_no <- psw(d[d$obese == 0, ])
facts <- c(facts, list(
  ob_women_low  = fmtn(sum(d$obese == 1 & d$female == 1 & d$central == 0)),
  ob_women      = fmtn(sum(d$obese == 1 & d$female == 1)),
  ps_ob_range   = sprintf("%.0f%%–%.1f%%", 100 * min(ps_ob), 100 * max(ps_ob)),
  ps_no_range   = sprintf("%.0f%%–%.0f%%", 100 * min(ps_no), 100 * max(ps_no)),
  n_income_missing = fmtn(sum(is.na(d$INDFMPIR)))))

## Effect of NOT being obese within each waist-fat stratum (the other simple effects).
nob_low  <- lc(fj, W(groupIII = 1))                        # III vs I
nob_high <- lc(fj, W(groupIV = 1, groupII = -1))           # IV vs II
facts$hr_notobese_lowwaist  <- fci(nob_low["est"],  nob_low["lo"],  nob_low["hi"])
facts$hr_notobese_highwaist <- fci(nob_high["est"], nob_high["lo"], nob_high["hi"])

## ---------------------------------------------------------------- 3. additive interaction from HRs
## Reference = Group I. The two "exposures" are then NOT being obese and high waist fat,
## so Group IV is the doubly exposed cell: RERI = HR_IV - HR_II - HR_III + 1, with the
## delta-method CI (Hosmer & Lemeshow 1992). AP = RERI / HR_IV;
## S = (HR_IV - 1) / ((HR_II - 1) + (HR_III - 1)).
b <- coef(fj)[c("groupII", "groupIII", "groupIV")]
V <- vcov(fj)[names(b), names(b)]
h <- exp(b)
reri <- unname(h["groupIV"] - h["groupII"] - h["groupIII"] + 1)
gr   <- c(-h["groupII"], -h["groupIII"], h["groupIV"])
se_r <- sqrt(drop(t(gr) %*% V %*% gr))
ap   <- reri / unname(h["groupIV"])
S    <- unname((h["groupIV"] - 1) / ((h["groupII"] - 1) + (h["groupIII"] - 1)))
rhr_joint <- lc(fj, W(groupIV = 1, groupII = -1, groupIII = -1))  # HR_IV / (HR_II * HR_III)
mn <- function(s) gsub("-", "−", s, fixed = TRUE)      # slides print a true minus
facts <- c(facts, list(
  reri  = mn(sprintf("%.2f (%.2f to %.2f)", reri, reri - 1.96 * se_r, reri + 1.96 * se_r)),
  reri_pt = mn(sprintf("%.2f", reri)),
  ap    = mn(sprintf("%.2f", ap)),
  s_index = sprintf("%.2f", S),
  rhr_joint = fci(rhr_joint["est"], rhr_joint["lo"], rhr_joint["hi"])))
## the same multiplicative measure, read the other way round, is its reciprocal
stopifnot(abs(rhr_joint["est"] * mult["est"] - 1) < 1e-8)

## ---------------------------------------------------------------- 4. the additive scale, done properly
## Standardised six-year risks (g-computation, Week 4) from the joint model:
##   * effect modification: within EACH obesity stratum, everyone set to lower vs high
##     waist fat, averaged over that stratum's own people;
##   * interaction: everyone in the cohort set to each of the four cells.
## Risk at 6 years = 1 - S0(6)^exp(lp); bootstrap percentile CIs.
H0at <- function(fit, t) { bh <- basehaz(fit, centered = FALSE); max(c(0, bh$hazard[bh$time <= t])) }
risk6 <- function(fit, nd, g) {
  nd$group <- factor(g, levels = levels(d$group))
  lp <- predict(fit, newdata = nd, type = "lp", reference = "zero")
  mean(1 - exp(-H0at(fit, 6) * exp(lp)))
}
stats6 <- function(dd) {
  fit <- coxph(as.formula(paste("Surv(time_yr, dead) ~ group +", pre)), data = dd)
  ob_ <- dd[dd$obese == 1, ]; no_ <- dd[dd$obese == 0, ]
  em <- c(I = risk6(fit, ob_, "I"), II = risk6(fit, ob_, "II"),
          III = risk6(fit, no_, "III"), IV = risk6(fit, no_, "IV"))
  jt <- sapply(c("I", "II", "III", "IV"), function(g) risk6(fit, dd, g))
  c(em_I = em[["I"]], em_II = em[["II"]], em_III = em[["III"]], em_IV = em[["IV"]],
    rd_obese = em[["II"]] - em[["I"]], rd_nonobese = em[["IV"]] - em[["III"]],
    rd_diff = (em[["II"]] - em[["I"]]) - (em[["IV"]] - em[["III"]]),   # obese minus not obese, as the ratio
    jt_I = jt[["I"]], jt_II = jt[["II"]], jt_III = jt[["III"]], jt_IV = jt[["IV"]],
    ic = jt[["IV"]] - jt[["II"]] - jt[["III"]] + jt[["I"]],
    dead_I = sum(dd$dead[dd$group == "I"]))
}
## The point estimate must agree with survfit's own standardised prediction.
pt6 <- stats6(d)
chk <- d; chk$group <- factor("III", levels = levels(d$group))
sf <- summary(survfit(fj, newdata = chk[chk$obese == 0, ]), times = 6)$surv
stopifnot(abs(mean(1 - sf) - pt6[["em_III"]]) < 1e-6)

## Group I has 4 deaths, so some resamples draw none of them: Group I's coefficients are
## then infinite (coxph warns) and its standardised risk is ~0. Those replicates are what
## the data allow and are kept; how many there were is emitted, not hidden.
set.seed(605)
B <- 500
bs <- suppressWarnings(replicate(B, stats6(d[sample(nrow(d), replace = TRUE), ])))
q <- function(k) quantile(bs[k, ], c(0.025, 0.975), names = FALSE)
facts$boot_zero_I <- as.character(sum(bs["dead_I", ] == 0))
for (k in c("em_I", "em_II", "em_III", "em_IV", "jt_I", "jt_II", "jt_III", "jt_IV"))
  facts[[paste0("risk6_", k)]] <- sprintf("%.1f%%", 100 * pt6[[k]])
facts <- c(facts, list(
  rd_whtr_obese    = ppci(pt6[["rd_obese"]], q("rd_obese")),
  rd_whtr_nonobese = ppci(pt6[["rd_nonobese"]], q("rd_nonobese")),
  rd_whtr_diff     = ppci(pt6[["rd_diff"]], q("rd_diff")),
  ic6              = ppci(pt6[["ic"]], q("ic")),
  reri_risk        = mn(sprintf("%.2f", pt6[["ic"]] / pt6[["jt_I"]])),
  n_boot           = as.character(B)))

## ---------------------------------------------------------------- 4b. a modifier the exposure may cause
## The deck's appendix: diabetes is commoner with high waist fat, and splitting waist fat's
## effect by it gives two HRs neither of which is a clean subgroup effect.
dmhr <- function(v) {
  f <- coxph(as.formula(paste("Surv(time_yr, dead) ~ central + obese +", pre)),
             data = d[d$t2dm == v, ])
  f2(exp(coef(f)[["central"]]))
}
facts <- c(facts, list(
  hr_waist_nodm = dmhr(0), hr_waist_dm = dmhr(1),
  pct_dm_lowwaist  = sprintf("%.0f%%", 100 * mean(d$t2dm[d$central == 0])),
  pct_dm_highwaist = sprintf("%.0f%%", 100 * mean(d$t2dm[d$central == 1]))))

## ---------------------------------------------------------------- 5. sex, for the locked contrast
## P3 tests sex as a modifier of IV vs III with the paper's Model 1 set (P3.json). Here:
## the same 1-df question with Week 4's pre-exposure set, on these rows.
s34 <- d[d$group %in% c("III", "IV"), ]
s34$IV <- as.integer(s34$group == "IV")
pre_ns <- paste(setdiff(PRE, "female"), collapse = " + ")
fs <- coxph(as.formula(paste("Surv(time_yr, dead) ~ IV * female +", pre_ns)), data = s34)
fs0 <- coxph(as.formula(paste("Surv(time_yr, dead) ~ IV + female +", pre_ns)), data = s34)
stopifnot(identical(rownames(fs0$y), rownames(fs$y)),
          fs0$n == fs$n, fs$n == nrow(s34), fs$nevent == sum(s34$dead))
rs <- lc(fs, W(`IV:female` = 1))
men <- lc(fs, W(IV = 1)); wom <- lc(fs, W(IV = 1, `IV:female` = 1))
facts <- c(facts, list(
  n_sex34 = fmtn(fs$n),
  events_sex34 = fmtn(fs$nevent),
  rhr_sex_pre = fci(rs["est"], rs["lo"], rs["hi"]),
  p_sex_pre   = sprintf("%.2f", anova(fs0, fs)$`Pr(>|Chi|)`[2]),   # LRT, as P3
  p_sex_pre_wald = sprintf("%.2f", summary(fs)$coefficients["IV:female", "Pr(>|z|)"]),
  hr_IVvIII_men_pre   = fci(men["est"], men["lo"], men["hi"]),
  hr_IVvIII_women_pre = fci(wom["est"], wom["lo"], wom["hi"])))

## The crude IV-vs-I table P3 retired, on P3's own rows (the 6,048-row locked domain),
## with the deaths in its reference cell and the 1-df ratio for the same comparison.
p3 <- dom
cr <- function(sx) {
  s <- summary(coxph(Surv(time_yr, dead) ~ group, data = p3[p3$female == sx, ]))$conf.int
  fci(s["groupIV", 1], s["groupIV", 3], s["groupIV", 4])
}
p14 <- p3[p3$group %in% c("I", "IV"), ]; p14$IV <- as.integer(p14$group == "IV")
fr <- coxph(Surv(time_yr, dead) ~ IV * female, data = p14)
r14 <- lc(fr, W(`IV:female` = 1))
facts <- c(facts, list(
  n_domain = fmtn(nrow(p3)),
  crude_IVvI_men = cr(0), crude_IVvI_women = cr(1),
  dom_n_I = fmtn(sum(p3$group == "I")),
  dom_n_I_men = fmtn(sum(p3$group == "I" & p3$female == 0)),
  dom_n_I_women = fmtn(sum(p3$group == "I" & p3$female == 1)),
  dom_dead_I_men = as.character(sum(p3$dead[p3$group == "I" & p3$female == 0])),
  dom_dead_I_women = as.character(sum(p3$dead[p3$group == "I" & p3$female == 1])),
  dom_died_I_men = pct(mean(p3$dead[p3$group == "I" & p3$female == 0])),
  dom_died_I_women = pct(mean(p3$dead[p3$group == "I" & p3$female == 1])),
  rhr_IVvI_sex_crude = fci(r14["est"], r14["lo"], r14["hi"])))

out <- list(emitted_by = "Week5_joint_exposure", facts = facts,
            models = list(joint = paste("group +", pre),
                          product = paste("obese * central +", pre),
                          sex = paste("IV * female +", pre_ns, "(Groups III and IV)"),
                          retired = "group, crude, within each sex (6,048-row domain)"),
            model_diagnostics = list(
              joint = list(n = fj$n, events = fj$nevent),
              product = list(n = fp$n, events = fp$nevent),
              no_product = list(n = fa$n, events = fa$nevent),
              sex = list(n = fs$n, events = fs$nevent),
              sex_no_product = list(n = fs0$n, events = fs0$nevent)),
            inference = list(
              hazard_ratio_CI = "normal Wald 95% CI on the log-HR scale",
              p_rhr_whtr = "two-sided normal Wald test of obese:central = 0",
              p_lrt_whtr = "1-df likelihood-ratio test of product versus no-product model, identical rows",
              rhr_whtr_profile = "95% profile partial-likelihood interval paired with the likelihood-ratio test",
              p_sex_pre = "1-df likelihood-ratio test of IV:female = 0, identical rows",
              p_sex_pre_wald = "two-sided normal Wald test of IV:female = 0",
              risk_difference_CI = "percentile interval from 500 individual bootstrap resamples"),
            bootstrap = list(B = B, seed = 605, horizon_years = 6))
writeLines(toJSON(out, auto_unbox = TRUE, pretty = TRUE), "Week5_joint_exposure.json", useBytes = TRUE)
for (k in names(facts)) cat(sprintf("%-24s %s\n", k, facts[[k]]))
