## Week 7: the numbers the missing-data deck quotes.
##
## Weeks 4-6 analysed 5,911 rows: the 6,048-row locked domain, restricted to people complete
## on every covariate. That restriction is itself a complete-case analysis. Week 7 asks who it
## removed, why their values are missing, whether it biased Weeks 4-6's hazard ratios, and
## what multiple imputation (MI) changes, without and with Week 6's survey design.
##
##   * the models are Weeks 4-6's: obesity's HR, and waist fat's HR within each obesity
##     stratum, adjusted for the pre-exposure set L (age, sex, race/ethnicity, smoking,
##     sedentary time);
##   * three row sets, always named: 5,911 (Weeks 4-6), the rows complete on L alone, and all
##     6,048 with the missing L values multiply imputed;
##   * the design is Week 6's: WTSAF2YR / 6, strata, PSUs, declared on the whole fasting
##     subsample and then subset(); with MI, once per imputed data set.
##
## Every number the deck quotes is written to Week7_missing_data.json, never typed.
## Run from this folder:   Rscript Week7_missing_data.R      (about three minutes)

source("../../examples/_shared/paths.R")   # find_repro(), fmtn()
repro <- find_repro()
suppressPackageStartupMessages({library(survival); library(survey); library(mice)
                                library(mitools); library(jsonlite); library(haven)})

.a <- readRDS(file.path(repro, "data/derived/masld_analytic.rds"))
.m <- readRDS(file.path(repro, "data/derived/merged_all.rds"))
.m$in_analysis <- .m$SEQN %in% .a$SEQN

f2  <- function(x) sprintf("%.2f", x)
fci <- function(e, l, u) sprintf("%.2f (%.2f–%.2f)", e, l, u)
pct <- function(x, k = 1) sprintf(paste0("%.", k, "f%%"), 100 * x)
pfmt <- function(p) if (p < 0.001) "<0.001" else sprintf("%.2f", p)
facts <- list()

## ---------------------------------------------------------------- 0. the made-up town
## 1,000 adults. Young 600: 120 smokers (12 die), 480 non-smokers (24 die). Old 400: 200
## smokers (80 die), 200 non-smokers (40 die). Truth: 32% smoke; smoking doubles the risk of
## death within each age group. Smoking status is then hidden in four ways.
## cells: young smoker died / lived, young non-smoker died / lived, old ... (same order)
town  <- c(ysd = 12, ysl = 108, ynd = 24, ynl = 456, osd = 80, osl = 120, ond = 40, onl = 160)
hide <- list(                                                  # smoking hidden, per cell
  MCAR     = town / 2,                                         # half of everyone
  MAR_age  = c(0, 0, 0, 0, town[5:8] / 2),                     # half of the old
  MNAR     = c(town[1:2] / 2, 0, 0, town[5:6] / 2, 0, 0),       # half of the smokers
  MAR_died = c(town[1] / 2, 0, town[3] / 2, 0, town[5] / 2, 0, town[7] / 2, 0))  # half the deaths
stopifnot(all(sapply(hide, function(h) all(h == round(h)))))
town_est <- function(h) {
  o <- unname(town - h)
  rr <- function(sd, sl, nd, nl) (sd / (sd + sl)) / (nd / (nd + nl))
  c(prev = sum(o[c(1, 2, 5, 6)]) / sum(o),
    rr_young = rr(o[1], o[2], o[3], o[4]), rr_old = rr(o[5], o[6], o[7], o[8]))
}
facts$town_prev_true <- pct(sum(town[c(1, 2, 5, 6)]) / sum(town), 0)
or_cells <- function(o) c(young = (o[1] / o[2]) / (o[3] / o[4]), old = (o[5] / o[6]) / (o[7] / o[8]))
or_true <- or_cells(unname(town)); or_cc <- or_cells(unname(town - hide$MAR_died))
facts$town_or_y <- f2(or_true[["young"]]); facts$town_or_o <- f2(or_true[["old"]])
stopifnot(isTRUE(all.equal(or_true, or_cc)))                  # the OR survives hiding the deaths
## the logistic check, run on the MNAR version: does hiding track death, given age?
tw <- data.frame(cell = rep(names(town), town), hid = 0L)
hm <- unname(hide$MNAR); tn <- unname(town)
tw$hid <- unlist(lapply(seq_along(tn), function(k) rep(c(1L, 0L), c(hm[k], tn[k] - hm[k]))))
tw$died <- as.integer(substr(tw$cell, 3, 3) == "d"); tw$old <- as.integer(substr(tw$cell, 1, 1) == "o")
tchk <- summary(glm(hid ~ died + old, family = binomial, data = tw))$coefficients
facts$town_chk_or <- f2(exp(tchk["died", 1])); facts$town_chk_p <- sprintf("%.3f", tchk["died", 4])
for (v in names(hide)) {
  e <- town_est(hide[[v]])
  facts[[paste0("town_", v, "_hidden")]] <- fmtn(sum(hide[[v]]))
  facts[[paste0("town_", v, "_prev")]]   <- pct(e[["prev"]])
  facts[[paste0("town_", v, "_rr_y")]]   <- f2(e[["rr_young"]])
  facts[[paste0("town_", v, "_rr_o")]]   <- f2(e[["rr_old"]])
}

## ---------------------------------------------------------------- 1. the funnel, each loss typed
## From every NHANES 2007-2018 participant to the locked domain, as 02_build_analytic.R does.
fu <- list(all = .m)
fu$adult <- fu$all[!is.na(fu$all$age) & fu$all$age >= 18, ]                       # ELIGIBILITY
fu$fast  <- fu$adult[!is.na(fu$adult$WTSAF2YR) & fu$adult$WTSAF2YR > 0, ]          # DESIGN
fu$fli   <- fu$fast[!is.na(fu$fast$fli), ]                                          # MISSINGNESS
fu$steat <- fu$fli[fu$fli$steatosis == 1, ]                                         # TARGET POPULATION
fu$masld <- fu$steat[fu$steat$masld == 1 & !is.na(fu$steat$group), ]               # TARGET POPULATION
fu$linked <- fu$masld[fu$masld$eligstat == 1 & !is.na(fu$masld$mortstat) &
                      !is.na(fu$masld$time_yr), ]                                   # OUTCOME
for (k in names(fu)) facts[[paste0("fun_", k)]] <- fmtn(nrow(fu[[k]]))
facts$fun_drop_design  <- fmtn(nrow(fu$adult) - nrow(fu$fast))
facts$fun_drop_fli     <- fmtn(nrow(fu$fast) - nrow(fu$fli))
facts$fun_drop_outcome <- fmtn(nrow(fu$masld) - nrow(fu$linked))
## the 792 adults in the fasting frame without an FLI: are they like the rest?
nofli <- fu$fast[is.na(fu$fast$fli), ]; withfli <- fu$fli
facts$nofli_waist  <- fmtn(sum(is.na(nofli$BMXWAIST)))
facts$nofli_age    <- sprintf("%.1f", mean(nofli$age)); facts$withfli_age <- sprintf("%.1f", mean(withfli$age))
lk <- function(x) x[!is.na(x$mortstat) & x$eligstat %in% 1, ]
facts$nofli_died   <- pct(mean(lk(nofli)$mortstat)); facts$withfli_died <- pct(mean(lk(withfli)$mortstat))
## the 323 analytic adults with a fasting weight of exactly 0 (fasting nonresponse)
zero <- .m[.m$in_analysis & .m$WTSAF2YR %in% 0, ]
pos  <- .m[.m$in_analysis & !is.na(.m$WTSAF2YR) & .m$WTSAF2YR > 0, ]
facts$n_zero_wt <- fmtn(nrow(zero))
facts$zero_age  <- sprintf("%.1f", mean(zero$age)); facts$pos_age <- sprintf("%.1f", mean(pos$age))
facts$zero_died <- pct(mean(zero$dead));            facts$pos_died <- pct(mean(pos$dead))
stopifnot(nrow(fu$linked) == 6048, nrow(zero) + nrow(pos) == nrow(.a))

## ---------------------------------------------------------------- 2. the locked domain, as Weeks 4-6
dom <- pos
dom$smk_current <- ifelse(dom$SMQ020 == 1 & dom$SMQ040 %in% c(1, 2), 1L,
                          ifelse(is.na(dom$SMQ020), NA_integer_, 0L))
sed_c <- mean(dom$sedentary_min, na.rm = TRUE); sed_s <- sd(dom$sedentary_min, na.rm = TRUE)
dom$sed  <- (dom$sedentary_min - sed_c) / sed_s          # = Week 4's scale(), kept for imputed values
dom$race <- factor(dom$RIDRETH1)
dom$group <- factor(dom$group, levels = c("I", "II", "III", "IV"))
dom$cycle <- factor(dom$SDDSRVYR)
COV1 <- c("age", "female", "dyslip", "htn", "t2dm", "ckd", "mi", "cancer",
          "on_htn_med", "on_dm_med", "on_lipid_med")
COV2 <- c(COV1, "smk_current", "sed")
PRE  <- c("age", "female", "race", "smk_current", "sed")
stopifnot(nrow(dom) == 6048, setequal(fu$linked$SEQN, dom$SEQN),
          isTRUE(all.equal(dom$sed, as.numeric(scale(dom$sedentary_min)))))
cc2 <- complete.cases(dom[, unique(c(COV2, PRE))])        # Weeks 4-6's rows
ccL <- complete.cases(dom[, PRE])                         # complete on L alone
stopifnot(sum(cc2) == 5911)
facts$n_domain <- fmtn(nrow(dom)); facts$n_rows <- fmtn(sum(cc2)); facts$n_ccL <- fmtn(sum(ccL))
facts$n_drop_rows <- fmtn(nrow(dom) - sum(cc2)); facts$n_drop_L <- fmtn(nrow(dom) - sum(ccL))
facts$deaths_domain <- fmtn(sum(dom$dead)); facts$deaths_I <- as.character(sum(dom$dead[dom$group == "I"]))

## ---------------------------------------------------------------- 3. what is missing, and why
nmiss <- function(v) sum(is.na(dom[[v]]))
for (v in c("cancer", "smk_current", "sed", "INDFMPIR")) facts[[paste0("miss_", v)]] <- fmtn(nmiss(v))
young <- dom$age < 20
facts$n_1819 <- fmtn(sum(young)); facts$dead_1819 <- as.character(sum(dom$dead[young]))
facts$miss_cancer_1819 <- fmtn(sum(is.na(dom$cancer) & young))
facts$miss_smk_1819 <- fmtn(sum(is.na(dom$smk_current) & young))
facts$n_1819_early <- fmtn(sum(young & dom$SDDSRVYR <= 7))
facts$n_1819_late  <- fmtn(sum(young & dom$SDDSRVYR >= 8))
facts$smk_1819_late <- pct(mean(dom$smk_current[young & dom$SDDSRVYR >= 8]), 0)
facts$smk_2024_early <- pct(mean(dom$smk_current[dom$age >= 20 & dom$age < 25 & dom$SDDSRVYR <= 7]), 0)
facts$miss_sed_9999 <- fmtn(sum(dom$PAD680 %in% 9999)); facts$miss_sed_blank <- fmtn(sum(is.na(dom$PAD680)))
facts$miss_sed_min_age <- as.character(min(dom$age[is.na(dom$sed)]))
facts$miss_inc_nhw <- pct(mean(is.na(dom$INDFMPIR[dom$RIDRETH1 == 3])))
facts$miss_inc_other <- pct(mean(is.na(dom$INDFMPIR[dom$RIDRETH1 != 3])))
stopifnot(all(young[is.na(dom$cancer)]), all(young[is.na(dom$smk_current)]),
          all(dom$SDDSRVYR[is.na(dom$smk_current)] <= 7), !any(young[is.na(dom$sed)]),
          !any(is.na(dom$smk_current) & is.na(dom$sed)), min(dom$age[cc2]) >= 20,
          sum(young) == sum(is.na(dom$cancer)))
## missing values the coding turns into "no"
facts$hid_cancer_dk <- fmtn(sum(dom$MCQ220 %in% c(7, 9)))
facts$hid_smk_dk    <- fmtn(sum(dom$SMQ020 %in% c(7, 9)))
facts$hid_mi_skip   <- fmtn(sum(young & is.na(dom$MCQ160E)))
facts$hid_htn_bp    <- fmtn(sum(is.na(dom$sbp) & dom$htn %in% 0))
stopifnot(all(dom$cancer[dom$MCQ220 %in% c(7, 9)] == 0), all(dom$mi[young] == 0))

## the missing-data patterns on L and cancer (what md.pattern() shows on the slide)
pm <- with(dom, paste(is.na(smk_current), is.na(sed), is.na(cancer)))
facts$pat_complete   <- fmtn(sum(pm == "FALSE FALSE FALSE"))
facts$pat_cancer     <- fmtn(sum(pm == "FALSE FALSE TRUE"))
facts$pat_cancer_smk <- fmtn(sum(pm == "TRUE FALSE TRUE"))
facts$pat_sed        <- fmtn(sum(pm == "FALSE TRUE FALSE"))
stopifnot(sum(pm %in% c("FALSE FALSE FALSE", "FALSE FALSE TRUE", "TRUE FALSE TRUE",
                        "FALSE TRUE FALSE")) == nrow(dom), sum(pm == "FALSE FALSE FALSE") == sum(cc2))
facts$pct_incomplete_any <- pct(mean(pm != "FALSE FALSE FALSE"), 1)

## who complete cases on L keep and lose (the one comparison you can run)
summ <- function(x, tag) {
  facts[[paste0("n_", tag)]]      <<- fmtn(nrow(x))
  facts[[paste0("died_", tag)]]   <<- pct(mean(x$dead))
  facts[[paste0("deaths_", tag)]] <<- as.character(sum(x$dead))
  facts[[paste0("age_", tag)]]    <<- sprintf("%.1f", mean(x$age))
}
summ(dom[ccL, ], "keepL"); summ(dom[!ccL, ], "dropL")
summ(dom[cc2, ], "keep2"); summ(dom[!cc2, ], "drop2")
## does missingness track the outcome once the covariates are known?
mfit <- glm(I(!ccL) ~ dead + time_yr + age + female + race + obese, family = binomial, data = dom)
cm <- summary(mfit)$coefficients
facts$or_miss_dead <- f2(exp(cm["dead", 1])); facts$p_miss_dead <- pfmt(cm["dead", 4])
facts$p_miss_time  <- pfmt(cm["time_yr", 4])
cmc <- summary(update(mfit, . ~ . + cycle))$coefficients
facts$p_miss_time_cyc <- pfmt(cmc["time_yr", 4]); facts$p_miss_dead_cyc <- pfmt(cmc["dead", 4])

## the 57 without SMQ020 answered the youth smoking module instead (SMQ620 / SMQ621, SMD641)
raw <- file.path(repro, "data/raw")
yq <- do.call(rbind, lapply(c("2007-2008/SMQ_E.xpt", "2009-2010/SMQ_F.xpt", "2011-2012/SMQ_G.xpt"),
  function(f) { x <- as.data.frame(read_xpt(file.path(raw, f)))
                data.frame(SEQN = x$SEQN, tried = if ("SMQ620" %in% names(x)) x$SMQ620 else x$SMQ621,
                           days30 = x$SMD641) }))
y57 <- yq[yq$SEQN %in% dom$SEQN[is.na(dom$smk_current)], ]
stopifnot(nrow(y57) == sum(is.na(dom$smk_current)))
facts$youth_answered <- fmtn(sum(!is.na(y57$tried)))
## shares among the 55 who answered (the same 2 non-answerers stay missing in the harmonised model)
ans <- y57[!is.na(y57$tried), ]
facts$youth_any30    <- fmtn(sum(ans$days30 %in% 1:30)); facts$youth_any30_pct <- pct(mean(ans$days30 %in% 1:30), 0)
facts$youth_daily    <- fmtn(sum(ans$days30 %in% 30));   facts$youth_daily_pct <- pct(mean(ans$days30 %in% 30), 0)

## ---------------------------------------------------------------- 4. the models, complete cases
pre <- paste(PRE, collapse = " + ")
f_ob <- as.formula(paste("Surv(time_yr, dead) ~ obese +", pre))
f_em <- as.formula(paste("Surv(time_yr, dead) ~ obese * central +", pre))
est_from <- function(b, V) {
  i <- c("central", "obese:central")
  e <- c(b[["central"]], sum(b[i]), b[["obese:central"]])
  s <- c(sqrt(V["central", "central"]), sqrt(sum(V[i, i])), sqrt(V["obese:central", "obese:central"]))
  setNames(fci(exp(e), exp(e - 1.96 * s), exp(e + 1.96 * s)), c("nonobese", "obese", "ratio"))
}
ob_from <- function(b, V) fci(exp(b[["obese"]]), exp(b[["obese"]] - 1.96 * sqrt(V["obese", "obese"])),
                              exp(b[["obese"]] + 1.96 * sqrt(V["obese", "obese"])))
put_bv <- function(tag, bo, Vo, be, Ve) {
  facts[[paste0("ob_", tag)]] <<- ob_from(bo, Vo)
  s <- est_from(be, Ve)
  facts[[paste0("wa_nonob_", tag)]] <<- s[["nonobese"]]
  facts[[paste0("wa_ob_", tag)]]    <<- s[["obese"]]
  facts[[paste0("wa_ratio_", tag)]] <<- s[["ratio"]]
}
put <- function(tag, fob, fem) put_bv(tag, coef(fob), vcov(fob), coef(fem), vcov(fem))
put("uw_rows", coxph(f_ob, data = dom[cc2, ]), coxph(f_em, data = dom[cc2, ]))
put("uw_ccL",  coxph(f_ob, data = dom[ccL, ]), coxph(f_em, data = dom[ccL, ]))

fast <- .m[!is.na(.m$WTSAF2YR) & .m$WTSAF2YR > 0, c("SEQN", "SDMVSTRA", "SDMVPSU", "WTSAF2YR")]
fast$wt <- fast$WTSAF2YR / 6
mvars <- c("SEQN", "obese", "central", "group", "time_yr", "dead", PRE, "INDFMPIR")
frame_with <- function(dd) {                     # the fasting frame, carrying dd's model variables
  f <- merge(fast, dd[, mvars], by = "SEQN", all.x = TRUE, sort = FALSE)
  f$in_dom  <- f$SEQN %in% dom$SEQN
  f$in_rows <- f$SEQN %in% dom$SEQN[cc2]
  f$in_ccL  <- f$SEQN %in% dom$SEQN[ccL]
  f
}
des_full <- svydesign(ids = ~SDMVPSU, strata = ~SDMVSTRA, weights = ~wt, data = frame_with(dom), nest = TRUE)
put("w_rows", svycoxph(f_ob, design = subset(des_full, in_rows)), svycoxph(f_em, design = subset(des_full, in_rows)))
put("w_ccL",  svycoxph(f_ob, design = subset(des_full, in_ccL)),  svycoxph(f_em, design = subset(des_full, in_ccL)))

## Weeks 4, 5 and 6's numbers must come back unchanged on the 5,911 rows
w4 <- fromJSON("Week4_bmi_exposure.json")$facts
w5 <- fromJSON("Week5_joint_exposure.json")$facts
w6 <- fromJSON("Week6_design_aware.json")$facts
stopifnot(facts$ob_uw_rows == w4$hr_pre, facts$wa_nonob_uw_rows == w5$hr_whtr_nonobese,
          facts$wa_ratio_uw_rows == w5$rhr_whtr, facts$ob_w_rows == w6$ob_w_L,
          facts$wa_nonob_w_rows == w6$wa_nonob_w_L, facts$wa_ratio_w_rows == w6$wa_ratio_w_L,
          facts$wa_ob_uw_rows == w5$hr_whtr_obese, facts$wa_ob_w_rows == w6$wa_ob_w_L)

## ---------------------------------------------------------------- 5. multiple imputation
## The imputation data set is the one the slides build (Week7_code_outputs.R runs the same
## lines, in the same column order, so the random draws agree):
##   SEQN            an ID: kept so each copy can be merged back, never a predictor;
##   time_yr         the analysis needs it; as a predictor it is replaced by H;
##   dead, H         the outcome: the event indicator and the Nelson-Aalen cumulative hazard
##                   (White & Royston 2009);
##   obese, central  the analysis needs them; as predictors they are replaced by group, the four
##                   combinations, so Week 5's obesity x waist interaction is in the model;
##   age, agegrp, female, race  L's complete variables; agegrp so that 18-19-year-olds are not
##                   extrapolated from a straight line in age;
##   smk, sed        the two incomplete L variables (logistic regression; predictive mean
##                   matching on Week 4's standardised scale);
##   cycle           an auxiliary: smoking was not asked of 18-19-year-olds before 2013;
##   logw            design information: the log fasting weight.
M <- 20
dom$smk    <- factor(dom$smk_current)
dom$agegrp <- cut(dom$age, c(17, 19, 24, 29, 39, 59, Inf),
                  labels = c("18-19", "20-24", "25-29", "30-39", "40-59", "60+"))
dat <- dom[, c("SEQN", "time_yr", "dead", "obese", "central", "group",
               "age", "agegrp", "female", "race", "smk", "sed", "cycle")]
dat$H    <- nelsonaalen(dat, time_yr, dead)
dat$logw <- log(dom$WTSAF2YR)
ini  <- mice(dat, maxit = 0, printFlag = FALSE)
meth <- ini$method
pred <- ini$predictorMatrix
pred[, c("SEQN", "time_yr", "obese", "central")] <- 0
stopifnot(meth[["smk"]] == "logreg", meth[["sed"]] == "pmm", sum(meth != "") == 2)
imp <- mice(dat, m = M, maxit = 10, method = meth, predictorMatrix = pred,
            seed = 607, printFlag = FALSE)
## the cautionary version: age only as a straight line
keep <- names(dat) != "agegrp"
imp_lin <- mice(dat[, keep], m = M, maxit = 10, method = meth[keep],
                predictorMatrix = pred[keep, keep], seed = 607, printFlag = FALSE)
smk_filled <- function(im) mean(sapply(seq_len(M), function(k)
  mean(complete(im, k)$smk[is.na(dom$smk_current)] == "1")))
facts$m_imp <- as.character(M)
facts$pct_incomplete <- pct(mean(!complete.cases(dom[, PRE])), 1)
facts$smk_imp_1819 <- pct(smk_filled(imp), 0); facts$smk_imp_1819_lin <- pct(smk_filled(imp_lin), 0)
fill <- function(k, im = imp) {
  x <- complete(im, k); dd <- dom
  stopifnot(identical(x$SEQN, dd$SEQN))
  dd$smk_current <- as.integer(as.character(x$smk))
  dd$sed <- x$sed
  dd
}
completed <- lapply(seq_len(M), fill)
stopifnot(all(sapply(completed, function(dd) complete.cases(dd[, PRE]))))

pool_put <- function(tag, fits_ob, fits_em) {
  pob <- MIcombine(lapply(fits_ob, coef), lapply(fits_ob, vcov))
  pem <- MIcombine(lapply(fits_em, coef), lapply(fits_em, vcov))
  put_bv(tag, coef(pob), vcov(pob), coef(pem), vcov(pem))
  facts[[paste0("fmi_", tag)]] <<- sprintf("%.3f", max(pem$missinfo[c("central", "obese:central")]))
}
pool_put("uw_mi", lapply(completed, function(dd) coxph(f_ob, data = dd)),
                  lapply(completed, function(dd) coxph(f_em, data = dd)))
mi_dom <- subset(svydesign(ids = ~SDMVPSU, strata = ~SDMVSTRA, weights = ~wt, nest = TRUE,
                           data = imputationList(lapply(completed, frame_with))), in_dom)
pool_put("w_mi", with(mi_dom, svycoxph(f_ob)), with(mi_dom, svycoxph(f_em)))

## ---------------------------------------------------------------- 6. stress tests: the extremes
stress <- function(smk_rule, sed_rule) {
  dd <- dom; ms <- is.na(dd$smk_current); md <- is.na(dd$sed)
  dd$smk_current[ms] <- smk_rule(dd[ms, ]); dd$sed[md] <- (sed_rule(dd[md, ]) - sed_c) / sed_s
  est_from(coef(coxph(f_em, data = dd)), vcov(coxph(f_em, data = dd)))
}
lo <- min(dom$sedentary_min, na.rm = TRUE); hi <- max(dom$sedentary_min, na.rm = TRUE)
ex <- list(none   = stress(function(x) 0L, function(x) rep(lo, nrow(x))),       # nobody smokes, least sedentary
           all    = stress(function(x) 1L, function(x) rep(hi, nrow(x))),       # everyone smokes, most sedentary
           dead   = stress(function(x) as.integer(x$dead == 1),                 # the extremes tied to the outcome
                           function(x) ifelse(x$dead == 1, hi, lo)),
           alive  = stress(function(x) as.integer(x$dead == 0),
                           function(x) ifelse(x$dead == 0, hi, lo)))
facts$sed_min <- fmtn(lo); facts$sed_max <- fmtn(hi)
for (k in names(ex)) {
  facts[[paste0("wa_nonob_x_", k)]] <- ex[[k]][["nonobese"]]
  facts[[paste0("wa_ratio_x_", k)]] <- ex[[k]][["ratio"]]
}
facts$deaths_missing_smk <- as.character(sum(dom$dead[is.na(dom$smk_current)]))
## harmonised instead of imputed: the youth answer "smoked on at least one of the past 30 days"
hz <- dom; i57 <- match(hz$SEQN, y57$SEQN)
hz$smk_current[!is.na(i57)] <- ifelse(is.na(y57$tried[i57[!is.na(i57)]]), NA,
                                      as.integer(y57$days30[i57[!is.na(i57)]] %in% 1:30))
hzc <- hz[complete.cases(hz[, PRE]), ]
sh <- est_from(coef(m_ <- coxph(f_em, data = hzc)), vcov(m_))
facts$n_harm <- fmtn(nrow(hzc)); facts$wa_nonob_harm <- sh[["nonobese"]]; facts$wa_ratio_harm <- sh[["ratio"]]
facts$deaths_missing_sed <- as.character(sum(dom$dead[is.na(dom$sed)]))

## ---------------------------------------------------------------- 7. where missing data would matter: income
## Week 6 named income as a sampling variable left out of L. Adding it costs complete cases.
PREI <- c(PRE, "INDFMPIR")
ccI <- complete.cases(dom[, PREI])
facts$n_ccI <- fmtn(sum(ccI)); facts$pct_incI <- pct(mean(!ccI), 1)
facts$deaths_I_ccI <- as.character(sum(dom$dead[ccI & dom$group == "I"]))
f_emI <- as.formula(paste("Surv(time_yr, dead) ~ obese * central +", paste(PREI, collapse = " + ")))
des_full$variables$in_ccI <- des_full$variables$SEQN %in% dom$SEQN[ccI]
m_I <- svycoxph(f_emI, design = subset(des_full, in_ccI)); sI <- est_from(coef(m_I), vcov(m_I))
facts$wa_nonob_wI_cc <- sI[["nonobese"]]; facts$wa_ratio_wI_cc <- sI[["ratio"]]
m_L <- svycoxph(f_em, design = subset(des_full, in_ccI)); sL <- est_from(coef(m_L), vcov(m_L))
facts$wa_nonob_wL_ccI <- sL[["nonobese"]]
## MI with income in the imputation and analysis models (income: PMM)
datI <- cbind(dat, pir = dom$INDFMPIR)
iniI <- mice(datI, maxit = 0, printFlag = FALSE)
methI <- iniI$method; predI <- iniI$predictorMatrix
predI[, c("SEQN", "time_yr", "obese", "central")] <- 0
stopifnot(methI[["pir"]] == "pmm", sum(methI != "") == 3)
impI <- mice(datI, m = M, maxit = 10, method = methI, predictorMatrix = predI,
             seed = 607, printFlag = FALSE)
fillI <- function(k) { dd <- fill(k, impI); dd$INDFMPIR <- complete(impI, k)$pir; dd }
miI <- subset(svydesign(ids = ~SDMVPSU, strata = ~SDMVSTRA, weights = ~wt, nest = TRUE,
                        data = imputationList(lapply(seq_len(M), function(k) frame_with(fillI(k))))), in_dom)
pI <- MIcombine(with(miI, svycoxph(f_emI)))
sIm <- est_from(coef(pI), vcov(pI))
facts$wa_nonob_wI_mi <- sIm[["nonobese"]]; facts$wa_ratio_wI_mi <- sIm[["ratio"]]
facts$fmi_wI_mi <- sprintf("%.2f", max(pI$missinfo[c("central", "obese:central")]))

writeLines(toJSON(list(emitted_by = "Week7_missing_data", facts = facts),
                  auto_unbox = TRUE, pretty = TRUE), "Week7_missing_data.json", useBytes = TRUE)
for (k in names(facts)) cat(sprintf("%-22s %s\n", k, facts[[k]]))
