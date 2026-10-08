## Week 6: the numbers the survey-design deck quotes.
##
## Weeks 4 and 5 taught on 5,911 MASLD adults, unweighted, so every estimate described the
## people NHANES happened to sample. Week 6 asks which population an estimate describes,
## and re-does Weeks 4 and 5 with the survey design:
##
##   * the design is declared ONCE on the whole fasting subsample (everyone with a valid
##     fasting weight, 2007-2018), with weight WTSAF2YR / 6 (six pooled cycles), strata
##     SDMVSTRA and PSUs SDMVPSU (nest = TRUE: PSU codes repeat across strata);
##   * the MASLD rows are reached with subset(), never by filtering the data first;
##   * every weighted estimate sits beside the unweighted one on the SAME 5,911 rows, with
##     the same adjustment set L as Weeks 4-5 (age, sex, race/ethnicity, smoking, sedentary
##     time). The paper's Model 1 is not used: Week 4 showed some of its conditions are
##     plausibly mediators.
##
## Every number the deck quotes is written to Week6_design_aware.json, never typed.
## Run from this folder:   Rscript Week6_design_aware.R      (about a minute)

source("../../examples/_shared/paths.R")   # find_repro(), fmtn(), endash()
repro <- find_repro()
suppressPackageStartupMessages({library(survival); library(survey); library(jsonlite)})
options(survey.lonely.psu = "adjust")

.a <- readRDS(file.path(repro, "data/derived/masld_analytic.rds"))
.m <- readRDS(file.path(repro, "data/derived/merged_all.rds"))
.m$in_analysis <- .m$SEQN %in% .a$SEQN

## ---------------------------------------------------------------- Week 4's rows, exactly
dom <- .m[.m$in_analysis & !is.na(.m$WTSAF2YR) & .m$WTSAF2YR > 0, ]
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
stopifnot(nrow(.a) == 6371, nrow(dom) == 6048, nrow(d) == 5911)
complete_L <- complete.cases(dom[, c("time_yr", "dead", "obese", "central", PRE)])
d$IV <- as.integer(d$group == "IV")
pre <- paste(PRE, collapse = " + ")

## ---------------------------------------------------------------- the design, declared once
## The frame is everyone in the fasting subsample (WTSAF2YR > 0), whatever their age or
## MASLD status. The variables the models need are carried over from `d` for its rows;
## outside the 5,911 they are NA, which subset() never touches.
keep <- c("SEQN", "obese", "central", "group", "IV", "time_yr", "dead", PRE)
mk_frame <- function(wvar) {
  f <- .m[!is.na(.m[[wvar]]) & .m[[wvar]] > 0, c("SEQN", "SDMVSTRA", "SDMVPSU", wvar)]
  f$wt  <- f[[wvar]] / 6                       # six two-year cycles pooled
  f$wt1 <- f[[wvar]]                           # NOT divided: only totals change
  f$one <- 1                                   # equal weights: the unweighted estimator
  f <- merge(f, d[, keep], by = "SEQN", all.x = TRUE, sort = FALSE)
  f$in_rows <- f$SEQN %in% d$SEQN
  f
}
fast <- mk_frame("WTSAF2YR")
stopifnot(sum(fast$in_rows) == 5911)
d$wt_saf <- fast$wt[match(d$SEQN, fast$SEQN)]
des_full <- svydesign(ids = ~SDMVPSU, strata = ~SDMVSTRA, weights = ~wt, data = fast, nest = TRUE)
des  <- subset(des_full, in_rows)                                  # <- the domain
des1 <- subset(svydesign(ids = ~SDMVPSU, strata = ~SDMVSTRA, weights = ~wt1, data = fast,
                         nest = TRUE), in_rows)                    # without the /6
desE <- subset(svydesign(ids = ~SDMVPSU, strata = ~SDMVSTRA, weights = ~one, data = fast,
                         nest = TRUE), in_rows)                    # equal weights
nps <- function(x) length(unique(paste(x$SDMVSTRA, x$SDMVPSU)))

f2  <- function(x) sprintf("%.2f", x)
fci <- function(e, l, u) sprintf("%.2f (%.2f–%.2f)", e, l, u)
pct <- function(x, k = 1) sprintf(paste0("%.", k, "f%%"), 100 * x)
pfmt <- function(p) if (p < 0.001) "<0.001" else sprintf("%.2f", p)
mill <- function(x) sprintf("%.1f million", x / 1e6)

facts <- list(
  n_interviewed = fmtn(nrow(.m)),
  n_exam   = fmtn(sum(.m$WTMEC2YR > 0, na.rm = TRUE)),
  n_fast   = fmtn(nrow(fast)),
  n_fast_adults = fmtn(sum(.m$WTSAF2YR > 0 & .m$RIDAGEYR >= 18, na.rm = TRUE)),
  n_analytic = fmtn(nrow(.a)),
  n_domain = fmtn(nrow(dom)),
  n_nofastwt = fmtn(nrow(.a) - nrow(dom)),
  n_rows   = fmtn(nrow(d)),
  n_complete_L = fmtn(sum(complete_L)),
  n_strata = as.character(length(unique(fast$SDMVSTRA))),
  n_psu    = as.character(nps(fast)),
  n_psu_rows = as.character(nps(fast[fast$in_rows, ])),
  degf     = as.character(degf(des_full)),
  deaths_rows = fmtn(sum(d$dead)),
  deaths_I = as.character(sum(d$dead[d$group == "I"])))

## ---------------------------------------------------------------- 1. who the rows stand for
races <- c(`1` = "Mexican American", `2` = "Other Hispanic", `3` = "Non-Hispanic White",
           `4` = "Non-Hispanic Black", `5` = "Other or multiracial")
wr <- coef(svymean(~race, des))
for (k in names(races)) {
  facts[[paste0("race", k, "_uw")]] <- pct(mean(d$race == k))
  facts[[paste0("race", k, "_w")]]  <- pct(wr[[paste0("race", k)]])
}
facts$age_uw   <- sprintf("%.1f", mean(d$age))
facts$age_w    <- sprintf("%.1f", coef(svymean(~age, des)))
facts$women_uw <- pct(mean(d$female))
facts$women_w  <- pct(coef(svymean(~female, des)))
facts$dead_uw  <- pct(mean(d$dead))
facts$dead_w   <- pct(coef(svymean(~dead, des)))
wg <- coef(svymean(~group, des))
for (g in levels(d$group)) {
  facts[[paste0("share_", g, "_uw")]] <- pct(mean(d$group == g))
  facts[[paste0("share_", g, "_w")]]  <- pct(wg[[paste0("group", g)]])
  facts[[paste0("n_", g)]]            <- fmtn(sum(d$group == g))   # the deck's Table 1 counts
}
facts$pop_rows   <- mill(sum(weights(des)))
facts$pop_rows_6x <- mill(sum(weights(des1)))
w <- weights(des); w <- w[w > 0]
facts$kish <- f2(length(w) * sum(w^2) / sum(w)^2)
facts$neff <- fmtn(round(length(w) / (length(w) * sum(w^2) / sum(w)^2)))

## ---------------------------------------------------------------- 2. Week 4 and Week 5, redone
hr1 <- function(fit, term) {
  s <- summary(fit)$conf.int; fci(s[term, 1], s[term, 3], s[term, 4])
}
## waist fat within each obesity stratum, from one product-term model
strata_hr <- function(fit, q = qnorm(0.975)) {   # q: z by default; t on the design df on request
  b <- coef(fit); V <- vcov(fit); i <- c("central", "obese:central")
  e <- c(b[["central"]], sum(b[i]), b[["obese:central"]])
  s <- c(sqrt(V["central", "central"]), sqrt(sum(V[i, i])), sqrt(V["obese:central", "obese:central"]))
  out <- fci(exp(e), exp(e - q * s), exp(e + q * s))
  names(out) <- c("nonobese", "obese", "ratio"); out
}
f_ob_c  <- Surv(time_yr, dead) ~ obese
f_ob_L  <- as.formula(paste("Surv(time_yr, dead) ~ obese +", pre))
f_em_c  <- Surv(time_yr, dead) ~ obese * central
f_em_L  <- as.formula(paste("Surv(time_yr, dead) ~ obese * central +", pre))
u_ob_c <- coxph(f_ob_c, data = d);  w_ob_c <- svycoxph(f_ob_c, design = des)
u_ob_L <- coxph(f_ob_L, data = d);  w_ob_L <- svycoxph(f_ob_L, design = des)
u_em_c <- coxph(f_em_c, data = d);  w_em_c <- svycoxph(f_em_c, design = des)
u_em_L <- coxph(f_em_L, data = d);  w_em_L <- svycoxph(f_em_L, design = des)
fits <- list(u_ob_c, w_ob_c, u_ob_L, w_ob_L, u_em_c, w_em_c, u_em_L, w_em_L)
stopifnot(all(vapply(fits, function(f) f$n == nrow(d) && f$nevent == sum(d$dead), logical(1))))
facts$n_model <- fmtn(w_em_L$n)
facts$events_model <- fmtn(w_em_L$nevent)
facts$model_coefficients <- as.character(length(coef(w_em_L)))
facts$ddf_model_w <- as.character(w_em_L$degf.resid)

facts$ob_uw_crude <- hr1(u_ob_c, "obese"); facts$ob_w_crude <- hr1(w_ob_c, "obese")
facts$ob_uw_L     <- hr1(u_ob_L, "obese"); facts$ob_w_L     <- hr1(w_ob_L, "obese")
for (nm in c("uw_crude", "w_crude", "uw_L", "w_L")) {
  fit <- list(uw_crude = u_em_c, w_crude = w_em_c, uw_L = u_em_L, w_L = w_em_L)[[nm]]
  s <- strata_hr(fit)
  facts[[paste0("wa_nonob_", nm)]] <- s[["nonobese"]]
  facts[[paste0("wa_ob_", nm)]]    <- s[["obese"]]
  facts[[paste0("wa_ratio_", nm)]] <- s[["ratio"]]
}
## the same intervals on t with the design's degrees of freedom (the deck's intervals are z)
st <- strata_hr(w_em_L, q = qt(0.975, degf(des)))
facts$wa_nonob_w_L_t <- st[["nonobese"]]; facts$wa_ob_w_L_t <- st[["obese"]]
facts$wa_ratio_w_L_t <- st[["ratio"]]
## Test labels matter: the unweighted z-Wald matches its z-Wald CI; the LRT is
## a different test. The weighted Wald F uses the explicitly requested design df.
u_main <- coxph(as.formula(paste("Surv(time_yr, dead) ~ obese + central +", pre)), data = d)
facts$p_wald_uw <- pfmt(coef(summary(u_em_L))["obese:central", "Pr(>|z|)"])
facts$p_lrt_uw <- pfmt(anova(u_main, u_em_L)$`Pr(>|Chi|)`[2])
rt <- regTermTest(w_em_L, ~obese:central, df = degf(des))
facts$p_wald_w <- pfmt(rt$p[1])
facts$F_w      <- f2(rt$Ftest[1])
facts$ddf_w    <- as.character(rt$ddf)

## Weeks 4-5's unweighted numbers must come back unchanged
w4 <- fromJSON("Week4_bmi_exposure.json")$facts
w5 <- fromJSON("Week5_joint_exposure.json")$facts
stopifnot(facts$ob_uw_crude == w4$hr_crude, facts$ob_uw_L == w4$hr_pre,
          facts$wa_nonob_uw_L == w5$hr_whtr_nonobese, facts$wa_ob_uw_L == w5$hr_whtr_obese,
          facts$wa_ratio_uw_L == w5$rhr_whtr, facts$p_lrt_uw == w5$p_lrt_whtr,
          facts$p_wald_uw == w5$p_rhr_whtr,
          facts$deaths_I == w5$deaths_I)

## ---------------------------------------------------------------- 3. where the wider CIs come from
## Waist fat among the not obese (IV vs III), adjusted for L, four ways on the same rows.
se_c <- function(fit) sqrt(vcov(fit)["central", "central"])
v_model  <- se_c(u_em_L)^2                                                   # unweighted, model SE
v_clust  <- se_c(svycoxph(f_em_L, design = desE))^2                          # unweighted, + strata/PSU
v_wonly  <- se_c(coxph(f_em_L, data = d, weights = wt_saf, robust = TRUE))^2  # weights only
v_design <- se_c(w_em_L)^2                                                   # weights + strata + PSU
facts$vr_clust  <- f2(v_clust / v_model)
facts$vr_wonly  <- f2(v_wonly / v_model)
facts$vr_design <- f2(v_design / v_model)
facts$vr_design_vs_wonly <- f2(v_design / v_wonly)
facts$se_model  <- sprintf("%.3f", sqrt(v_model))
facts$se_design <- sprintf("%.3f", sqrt(v_design))

## ---------------------------------------------------------------- 4. the /6, and subset() vs filtering
coef_raw <- coef(svycoxph(f_em_L, design = des1))
stopifnot(max(abs(coef_raw - coef(w_em_L))) < 1e-10)                         # /6 moves no coefficient
facts$hr_same_6 <- "identical"
facts$max_coef_diff_6 <- sprintf("%.2e", max(abs(coef_raw - coef(w_em_L))))
pre_des <- svydesign(ids = ~SDMVPSU, strata = ~SDMVSTRA, weights = ~wt,
                     data = fast[fast$in_rows, ], nest = TRUE)              # the WRONG way
facts$se_subset <- sprintf("%.4f", se_c(w_em_L))
facts$se_filter <- sprintf("%.4f", se_c(svycoxph(f_em_L, design = pre_des)))
## a sparse domain: obese women with lower waist fat (Group I women)
gw <- fast$in_rows & fast$group %in% "I" & fast$female %in% 1
facts$gw_n    <- as.character(sum(gw))
facts$gw_psu  <- as.character(nps(fast[gw, ]))
facts$gw_strata <- as.character(length(unique(fast$SDMVSTRA[gw])))
facts$gw_lonely <- as.character(sum(table(unique(fast[gw, c("SDMVSTRA", "SDMVPSU")])$SDMVSTRA) == 1))

## ---------------------------------------------------------------- 5. WTMEC sensitivity
mec <- mk_frame("WTMEC2YR")
stopifnot(sum(mec$in_rows) == 5911)
desM <- subset(svydesign(ids = ~SDMVPSU, strata = ~SDMVSTRA, weights = ~wt, data = mec,
                         nest = TRUE), in_rows)
sM <- strata_hr(svycoxph(f_em_L, design = desM))
facts$wa_nonob_mec <- sM[["nonobese"]]; facts$wa_ob_mec <- sM[["obese"]]
facts$wa_ratio_mec <- sM[["ratio"]]
facts$ob_mec_L <- hr1(svycoxph(f_ob_L, design = desM), "obese")
facts$pop_rows_mec <- mill(sum(weights(desM)))
facts$cor_saf_mec <- f2(cor(d$wt_saf, mec$wt[match(d$SEQN, mec$SEQN)]))
wr_sm <- d$wt_saf / mec$wt[match(d$SEQN, mec$SEQN)]                         # fasting / exam weight
facts$wr_min <- sprintf("%.1f", min(wr_sm)); facts$wr_max <- sprintf("%.1f", max(wr_sm))
facts$wr_mean <- sprintf("%.1f", mean(wr_sm))
ad_exam <- sum(.m$WTMEC2YR > 0 & .m$RIDAGEYR >= 18, na.rm = TRUE)
facts$n_exam_adults <- fmtn(ad_exam)
facts$pct_fast_of_exam_adults <- pct(sum(.m$WTSAF2YR > 0 & .m$RIDAGEYR >= 18, na.rm = TRUE) / ad_exam, 0)

## ---------------------------------------------------------------- 6. survival curves, sample vs population
km_u <- survfit(Surv(time_yr, dead) ~ group, data = d)
km_w <- svykm(Surv(time_yr, dead) ~ group, design = des)
grid <- seq(0, 12, by = 0.05)
pts <- do.call(rbind, lapply(levels(d$group), function(g) {
  su <- summary(km_u[paste0("group=", g)], times = grid, extend = TRUE)$surv
  kw <- km_w[[g]]
  sw <- sapply(grid, function(t) { i <- which(kw$time <= t); if (length(i)) kw$surv[max(i)] else 1 })
  rbind(data.frame(analysis = "unweighted", group = g, time = grid, surv = su),
        data.frame(analysis = "weighted", group = g, time = grid, surv = sw))
}))
write.csv(pts, "Week6_km_points.csv", row.names = FALSE)
lr_u <- survdiff(Surv(time_yr, dead) ~ group, data = d)
lr_w <- svylogrank(Surv(time_yr, dead) ~ group, design = des)
facts$lr_uw_chisq <- sprintf("%.1f", lr_u$chisq)
facts$lr_w_chisq  <- sprintf("%.1f", lr_w[[2]][["Chisq"]])
facts$lr_w_p      <- pfmt(lr_w[[2]][["p"]])
facts$lr_uw_p     <- pfmt(pchisq(lr_u$chisq, 3, lower.tail = FALSE))
s6 <- function(g, which) {
  if (which == "uw") 1 - summary(km_u[paste0("group=", g)], times = 6)$surv
  else { kw <- km_w[[g]]; 1 - kw$surv[max(which(kw$time <= 6))] }
}
for (g in levels(d$group)) {
  facts[[paste0("died6_", g, "_uw")]] <- pct(s6(g, "uw"))
  facts[[paste0("died6_", g, "_w")]]  <- pct(s6(g, "w"))
}

## ---------------------------------------------------------------- 7. Week 5's sex question, design-aware
f_sex0 <- as.formula("Surv(time_yr, dead) ~ IV + female + age + race + smk_current + sed")
f_sex1 <- as.formula("Surv(time_yr, dead) ~ IV * female + age + race + smk_current + sed")
s34 <- d[d$group %in% c("III", "IV"), ]
dsex <- subset(des, group %in% c("III", "IV"))
u_sex <- coxph(f_sex1, data = s34); w_sex <- svycoxph(f_sex1, design = dsex)
stopifnot(u_sex$n == nrow(s34), w_sex$n == u_sex$n,
          u_sex$nevent == sum(s34$dead), w_sex$nevent == u_sex$nevent)
facts$n_sex34 <- fmtn(w_sex$n)
facts$events_sex34 <- fmtn(w_sex$nevent)
facts$sex_uw <- hr1(u_sex, "IV:female"); facts$sex_w <- hr1(w_sex, "IV:female")
facts$p_sex_uw <- pfmt(anova(coxph(f_sex0, data = s34), u_sex)$`Pr(>|Chi|)`[2])
facts$p_sex_wald_uw <- pfmt(coef(summary(u_sex))["IV:female", "Pr(>|z|)"])
facts$p_sex_w  <- pfmt(regTermTest(w_sex, ~IV:female, df = degf(des))$p[1])
stopifnot(facts$sex_uw == w5$rhr_sex_pre, facts$p_sex_uw == w5$p_sex_pre)

writeLines(toJSON(list(emitted_by = "Week6_design_aware", facts = facts),
                  auto_unbox = TRUE, pretty = TRUE), "Week6_design_aware.json", useBytes = TRUE)
for (k in names(facts)) cat(sprintf("%-22s %s\n", k, facts[[k]]))
