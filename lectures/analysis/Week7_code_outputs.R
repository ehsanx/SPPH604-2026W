## Week 7: the R code shown on the deck's "In R" slides, and its real output.
##
## Each snippet below is run exactly as it appears on a slide, in one shared session, and
## its printed output is captured underneath it in reprex style ("#>" lines). The finished
## blocks are written to Week7_code_outputs.json and copied into the deck, and a check fails
## if a slide's block differs from what this script printed. Two short blocks on the slides
## are typed rather than copied (Step 0's `colSums(is.na())` counts and Step 1's `H` line);
## the check confirms that the numbers they print are the ones this script emits.
##
## Some blocks below are no longer on the 20 Oct deck (the town's R, Step 5's code, the
## extreme fills). They still run, because the deck quotes numbers they compute.
##
## Three snippets draw a picture. Those pictures are saved, from the same call, to
## lectures/img/: w7_pattern.png (md.pattern), w7_trace.png (convergence) and
## w7_density.png (observed vs imputed). They are what a student sees on running the code.
## Two small data files feed the figure script: Week7_fig_single.csv (the fill-in demo) and
## Week7_fig_rubin.csv (each copy's estimate, for the Rubin's-rules picture).
##
## Run from this folder:   Rscript Week7_code_outputs.R      (about three minutes: it imputes)
##
## The data set-up is not shown on the slides. `dom` is the 6,048-row locked domain with
## Weeks 4-6's variables (as in Week7_missing_data.R): `smk` is current smoking (a factor),
## `sed` is Week 4's standardised sedentary time, `agegrp` and `cycle` are factors, `ccL`
## marks the rows complete on L, and `fast` is Week 6's fasting frame (17,208 people with
## SEQN, SDMVSTRA, SDMVPSU and wt = WTSAF2YR / 6).

source("../../examples/_shared/paths.R")   # find_repro()
repro <- find_repro()
suppressPackageStartupMessages({library(survival); library(survey); library(mice)
                                library(mitools); library(jsonlite); library(haven)
                                library(lattice)})
options(width = 72, digits = 7)

.a <- readRDS(file.path(repro, "data/derived/masld_analytic.rds"))
.m <- readRDS(file.path(repro, "data/derived/merged_all.rds"))
.m$in_analysis <- .m$SEQN %in% .a$SEQN
dom <- .m[.m$in_analysis & !is.na(.m$WTSAF2YR) & .m$WTSAF2YR > 0, ]
dom$smk_current <- ifelse(dom$SMQ020 == 1 & dom$SMQ040 %in% c(1, 2), 1L,
                          ifelse(is.na(dom$SMQ020), NA_integer_, 0L))
sed_c <- mean(dom$sedentary_min, na.rm = TRUE); sed_s <- sd(dom$sedentary_min, na.rm = TRUE)
dom$sed  <- (dom$sedentary_min - sed_c) / sed_s
dom$race <- factor(dom$RIDRETH1)
dom$group <- factor(dom$group, levels = c("I", "II", "III", "IV"))
rownames(dom) <- NULL
raw <- file.path(repro, "data/raw")
youth <- do.call(rbind, lapply(c("2007-2008/SMQ_E.xpt", "2009-2010/SMQ_F.xpt", "2011-2012/SMQ_G.xpt"),
  function(f) { x <- as.data.frame(read_xpt(file.path(raw, f)))
                data.frame(SEQN = x$SEQN, tried = if ("SMQ620" %in% names(x)) x$SMQ620 else x$SMQ621,
                           days30 = x$SMD641) }))
youth <- youth[youth$SEQN %in% dom$SEQN[is.na(dom$smk_current)], ]
stopifnot(nrow(dom) == 6048, !anyNA(dom$bmi), !anyNA(dom$waist))
## Week 6's fasting frame as Week 6 built it: every column, plus wt (the set-up slide narrows it)
fast <- .m[!is.na(.m$WTSAF2YR) & .m$WTSAF2YR > 0, ]
fast$wt <- fast$WTSAF2YR / 6
.n_child <- sum(fast$age < 18); .min_age <- min(fast$age)   # the frame is all ages 12+
IMG <- file.path("..", "img")

## ------------------------------------------------------------------ the snippets
S <- list(

cc_default = list(
'fm <- Surv(time_yr, dead) ~ obese * central + age + female + race + smk_current + sed
fit <- coxph(fm, data = dom)          # Week 5\'s model, given all 6,048 rows
c(rows_used = fit$n, deaths = fit$nevent, rows_dropped = length(fit$na.action))'),

town_data = list(
'mk <- function(age, smoker, deaths, n)          # n people; the first `deaths` die
  data.frame(age = age, smoker = smoker, died = rep(1:0, c(deaths, n - deaths)))
town <- rbind(mk("young", 1, 12, 120), mk("young", 0, 24, 480),
              mk("old",   1, 80, 200), mk("old",   0, 40, 200))
mean(town$smoker)                                   # the truth: 32% smoke',
'town$second <- ave(seq_len(nrow(town)), town$age, town$smoker, town$died,
                   FUN = seq_along) %% 2 == 0      # every second person per cell
hidden <- with(town, list(MCAR     = second,                 # half of everyone
                          MAR_age  = second & age == "old",  # half of the old
                          MNAR     = second & smoker == 1,   # half of the smokers
                          MAR_died = second & died == 1))    # half of the deaths
sapply(hidden, sum)                       # whose smoking status is hidden'),

town_cc = list(
'cc <- function(h) {                      # complete cases: drop the hidden
  obs <- town[!h, ]
  rr <- function(a) with(subset(obs, age == a),
                         mean(died[smoker == 1]) / mean(died[smoker == 0]))
  c(smokers_pct = 100 * mean(obs$smoker), rr_young = rr("young"), rr_old = rr("old"))
}
round(sapply(hidden, cc), 2)'),

town_cc_one = list(
'mnar <- town[, c("age", "smoker", "died")]   # version 3: half the smokers hidden
mnar$smoker[hidden$MNAR] <- NA
obs <- subset(mnar, !is.na(smoker))          # complete cases: the rows R keeps
nrow(obs)                                    # 1,000 minus the 160 hidden',
'mean(obs$smoker)                             # the share who smoke (truth: 0.32)',
'old <- subset(obs, age == "old")
table(smoker = old$smoker, died = old$died)',
'risk_smokers <- mean(old$died[old$smoker == 1])   # 40 / 100
risk_non     <- mean(old$died[old$smoker == 0])   # 40 / 200
c(risk_smokers = risk_smokers, risk_non = risk_non, RR = risk_smokers / risk_non)'),

little_test = list(
'library(naniar)
set.seed(604)
mcar_demo <- dom[, c("bmi", "waist")]                    # both complete
mcar_demo$waist[sample(nrow(mcar_demo), 1814)] <- NA    # hidden at random: MCAR
round(unlist(mcar_test(mcar_demo)), 3)',
'mar_demo <- dom[, c("bmi", "waist")]
mar_demo$waist[mar_demo$bmi > 35 & runif(nrow(mar_demo)) < 0.6] <- NA   # MAR
round(unlist(mcar_test(mar_demo)), 3)'),

single_mean = list(
'set.seed(604)
demo <- dom[, c("bmi", "waist")]                     # both complete for all 6,048
demo$waist[sample(nrow(demo), round(0.3 * nrow(demo)))] <- NA   # hide 30% at random
mean_fill <- demo
mean_fill$waist[is.na(demo$waist)] <- mean(demo$waist, na.rm = TRUE)   # one fill
round(c(sd_truth = sd(dom$waist), sd_filled = sd(mean_fill$waist)), 2)',
'round(c(cor_truth  = cor(dom$bmi, dom$waist),
        cor_filled = cor(mean_fill$bmi, mean_fill$waist)), 2)'),

single_imp = list(
'library(mice)
set.seed(604)
demo <- dom[, c("bmi", "waist")]                    # both complete for all 6,048
demo$waist[sample(nrow(demo), round(0.3 * nrow(demo)))] <- NA   # hide 30% at random
one_copy <- function(method)                        # fill the gaps once, one way
  complete(mice(demo, m = 1, maxit = 1, method = c("", method),
                seed = 604, printFlag = FALSE))
ways <- list(mean = "mean", regression = "norm.predict", stochastic = "norm.nob")
fills <- c(list(truth = dom[, c("bmi", "waist")]), lapply(ways, one_copy))
round(t(sapply(fills, function(x)
  c(sd_waist = sd(x$waist), cor_with_bmi = cor(x$bmi, x$waist)))), 2)'),

town_mi = list(
'library(mice)
impute <- function(h) {          # impute smoking from age, death, and age x death
  d <- town[, c("age", "smoker", "died")]
  d$smoker[h] <- NA
  d$old_died <- as.integer(d$age == "old" & d$died == 1)   # the analysis is by age
  d$smoker <- factor(d$smoker); d$age <- factor(d$age)
  imp <- mice(d, m = 100, method = c("", "logreg", "", ""), seed = 607,
              printFlag = FALSE)
  with(imp, glm(died ~ I(smoker == "1"), family = poisson,
                subset = age == "old"))     # the RR among the old, in each copy
}
rr_old <- function(fits) round(exp(summary(pool(fits))$estimate[2]), 2)
fit_died <- impute(hidden$MAR_died); fit_mnar <- impute(hidden$MNAR)
c(MAR_died = rr_old(fit_died), MNAR = rr_old(fit_mnar))   # the truth is 2'),

town_noY = list(
'drop_death <- function(h) {             # the same, but imputing from age only
  d <- town[, c("age", "smoker", "died")]
  d$smoker[h] <- NA
  d$smoker <- factor(d$smoker); d$age <- factor(d$age)
  pred <- make.predictorMatrix(d); pred["smoker", "died"] <- 0   # death left out
  imp <- mice(d, m = 100, method = c("", "logreg", ""), predictorMatrix = pred,
              seed = 607, printFlag = FALSE)
  with(imp, glm(died ~ I(smoker == "1"), family = poisson, subset = age == "old"))
}
c(with_death = rr_old(impute(hidden$MCAR)),
  without_death = rr_old(drop_death(hidden$MCAR)))   # MCAR; the truth is 2'),

town_rubin = list(
'pt <- pool(fit_died)$pooled[2, ]          # log RR among the old, MAR on death
round(c(estimate = pt$estimate, within = pt$ubar, between = pt$b, total = pt$t), 5)',
'round(pt$ubar + (1 + 1 / 100) * pt$b, 5)  # Rubin: total = within + (1 + 1/m) between'),

setup = list(
'library(survival); library(mice)
dom$smk    <- factor(dom$smk_current)   # a factor, so mice() uses logistic regression
dom$cycle  <- factor(dom$SDDSRVYR)      # survey cycle: 5 = 2007-08 ... 10 = 2017-18
dom$agegrp <- cut(dom$age, c(17, 19, 24, 29, 39, 59, Inf),
                  labels = c("18-19", "20-24", "25-29", "30-39", "40-59", "60+"))
ccL  <- complete.cases(dom[, c("age", "female", "race", "smk", "sed")])   # on L
fast <- fast[, c("SEQN", "SDMVSTRA", "SDMVPSU", "wt")]  # Week 6\'s frame: design only
fm   <- Surv(time_yr, dead) ~ obese * central + age + female + race + smk + sed
c(rows = nrow(dom), complete_on_L = sum(ccL), fasting_frame = nrow(fast))'),

step0_count = list(
'vars <- c("age", "female", "race", "smk", "sed", "cancer")
colSums(is.na(dom[, vars]))               # how many values are missing',
'md.pattern(dom[, vars], rotate.names = TRUE)   # which combinations (also a picture)'),

step0_why = list(
'with(subset(dom, age < 20),
     table(cycle = cycle, smoking_missing = is.na(smk)))'),

step0_compare = list(
'dom$complete_L <- ccL           # complete on all five variables of L
aggregate(cbind(died = dead, age) ~ complete_L, data = dom, FUN = mean)',
'chk <- glm(!complete_L ~ dead + time_yr + age + female + race + obese,
           family = binomial, data = dom)     # does missingness track death?
round(summary(chk)$coefficients[c("dead", "time_yr"), c(1, 2, 4)], 3)',
'chk_c <- update(chk, . ~ . + cycle)           # add the interview cycle
round(summary(chk_c)$coefficients[c("dead", "time_yr"), c(1, 2, 4)], 3)'),

step1_data = list(
'dat <- dom[, c("SEQN", "time_yr", "dead", "obese", "central", "group",
               "age", "agegrp", "female", "race", "smk", "sed", "cycle")]
dat$H    <- nelsonaalen(dat, time_yr, dead)   # the outcome, in a form mice can use
dat$logw <- log(dom$WTSAF2YR)                 # design information
dim(dat)'),

h_toy = list(
'toy <- data.frame(time = c(1, 1.5, 2, rep(3, 7)),   # 10 people, years followed
                  dead = c(1, 0,   1, rep(0, 7)))   # deaths at 1 and 2 years
toy$H <- nelsonaalen(toy, time, dead)
toy[1:4, ]'),

step1_dryrun = list(
'ini  <- mice(dat, maxit = 0)           # a dry run: nothing is imputed yet
meth <- ini$method
meth[meth != ""]                        # the method mice chose for each gap'),

step1_pred = list(
'pred <- ini$predictorMatrix    # rows: variables to fill; columns: predictors
pred[, c("SEQN", "time_yr", "obese", "central")] <- 0   # never as predictors
pred[c("smk", "sed"), c("SEQN", "time_yr", "dead", "H", "group", "age", "cycle")]'),

step2_impute = list(
'imp <- mice(dat, m = 20, maxit = 10, method = meth, predictorMatrix = pred,
            seed = 607, printFlag = FALSE)
imp$nmis[imp$nmis > 0]                  # gaps filled in each of the 20 copies'),

step2_trace = list(
'plot(imp, c("smk", "sed"), layout = c(2, 2))   # one line per copy, 10 iterations'),

step2_density = list(
'library(lattice)
densityplot(imp, ~ sed)                 # blue: observed; red: each copy\'s 28'),

step2_copies = list(
'copy1 <- complete(imp, 1)               # copy 1: an ordinary data frame, no gaps
c(rows = nrow(copy1), smoking_missing = sum(is.na(copy1$smk)))',
'who <- c(which(is.na(dat$smk))[1:3],    # three people whose smoking was missing
         which(!is.na(dat$smk))[1])      # and one whose smoking was observed
tab <- sapply(1:4, function(k)
  ifelse(complete(imp, k)$smk[who] == "1", "smoker", "non-smoker"))
dimnames(tab) <- list(c("gap A", "gap B", "gap C", "observed D"), paste("copy", 1:4))
tab'),

step2_filled = list(
'filled <- sapply(1:20, function(k)
  mean(complete(imp, k)$smk[is.na(dat$smk)] == "1"))
round(100 * mean(filled))     # % of the 57 filled in as current smokers'),

step3_with = list(
'fits <- with(imp, coxph(Surv(time_yr, dead) ~ obese * central +
                          age + female + race + smk + sed))
hr <- sapply(fits$analyses, function(f) exp(coef(f)[["central"]]))
round(hr[1:6], 4)          # waist fat among the not obese, copies 1 to 6'),

step4_pool = list(
'pooled <- pool(fits)                      # Rubin\'s rules, for every coefficient
p <- pooled$pooled                        # one row per coefficient
round(p[p$term == "central", c("estimate", "ubar", "b", "t")], 5)   # waist fat'),

step4_hr = list(
's <- summary(pooled, conf.int = TRUE, exponentiate = TRUE)   # HRs, with intervals
round(unlist(s[s$term == "central", c("estimate", "2.5 %", "97.5 %")]), 2)'),

step5_long = list(
'long <- complete(imp, "long")             # the 20 copies, stacked; .imp = copy number
long <- merge(long, fast, by = "SEQN")    # add PSU, stratum and weight to each row
long$in_dom <- 1                          # all of these are in our MASLD domain
table(long$.imp)[1:3]                     # 6,048 rows in each copy'),

step5_rest = list(
'rest <- fast[!fast$SEQN %in% dat$SEQN, ]  # the other 11,160 in the fasting frame
rest$in_dom <- 0
rest <- do.call(rbind, lapply(seq_len(imp$m), function(k) cbind(rest, .imp = k)))
rest[setdiff(names(long), names(rest))] <- NA     # their analysis columns stay empty
full <- rbind(long, rest[, names(long)])
table(full$.imp)[1:3]                     # every copy: the whole fasting frame'),

step5_design = list(
'library(survey); library(mitools)
copies <- imputationList(split(full, full$.imp))   # 20 completed copies of one sample
des_full <- svydesign(ids = ~SDMVPSU, strata = ~SDMVSTRA, weights = ~wt,
                      nest = TRUE, data = copies)   # Week 6\'s design, on each copy
length(des_full$designs)'),

step5_fit = list(
'des_dom  <- subset(des_full, in_dom == 1)   # the domain; the design stays whole
fits_w   <- with(des_dom, svycoxph(fm))      # Week 5\'s model in each copy
pooled_w <- MIcombine(fits_w)                # Rubin\'s rules, as in Thursday\'s lab
est_w <- coef(pooled_w); se_w <- sqrt(diag(vcov(pooled_w)))
b <- est_w[["central"]]; se <- se_w[["central"]]   # waist fat, IV vs III
round(exp(b + c(HR = 0, low = -1.96, high = 1.96) * se), 2)'),

youth_check = list(
'# the 55 of the 57 who answered the youth questions: days smoked in the past 30
ans <- subset(youth, !is.na(tried))
round(100 * c(any_day = mean(ans$days30 %in% 1:30),
              every_day = mean(ans$days30 %in% 30)))'),

straight_line = list(
'keep <- names(dat) != "agegrp"           # the same model, age only as a straight line
imp_lin <- mice(dat[, keep], m = 20, maxit = 10, method = meth[keep],
                predictorMatrix = pred[keep, keep], seed = 607, printFlag = FALSE)
round(100 * mean(sapply(1:20, function(k)
  mean(complete(imp_lin, k)$smk[is.na(dat$smk)] == "1"))))   # % of the 57 as smokers'),

stress = list(
'lo <- min(dom$sed, na.rm = TRUE); hi <- max(dom$sed, na.rm = TRUE)   # 0 and 1,200 min
stress <- function(smk_fill, sed_fill) {      # fill the 57 and the 28, then refit
  d <- dom; ms <- is.na(d$smk); md <- is.na(d$sed)
  d$smk[ms] <- smk_fill(d$dead[ms]); d$sed[md] <- sed_fill(d$dead[md])
  hr <- exp(coef(coxph(fm, data = d)))
  round(c(not_obese = hr[["central"]], ratio = hr[["obese:central"]]), 2)
}
rbind(none  = stress(function(y) "0", function(y) lo),
      all   = stress(function(y) "1", function(y) hi),
      dead  = stress(function(y) ifelse(y == 1, "1", "0"),
                     function(y) ifelse(y == 1, hi, lo)),
      alive = stress(function(y) ifelse(y == 0, "1", "0"),
                     function(y) ifelse(y == 0, hi, lo)))')
)

## snippets that draw: the picture is saved from the same call
FIG <- list(step0_count   = list(file = "w7_pattern.png", w = 7.6, h = 4.4),
            step2_trace   = list(file = "w7_trace.png",   w = 9.0, h = 4.8),
            step2_density = list(file = "w7_density.png", w = 7.6, h = 4.4))

## ------------------------------------------------------------------ run and capture
env <- environment()
run_piece <- function(code) {
  out <- character(0)
  for (e in parse(text = code)) {
    o <- capture.output(v <- withVisible(eval(e, envir = env)))
    if (v$visible) o <- c(o, capture.output(print(v$value)))
    out <- c(out, o)
  }
  out
}
## (dotted names: the snippets run in this same environment and must not overwrite the loop)
blocks <- list()
for (.id in names(S)) {
  .fg <- FIG[[.id]]
  if (!is.null(.fg)) png(file.path(IMG, .fg$file), width = .fg$w, height = .fg$h,
                         units = "in", res = 220)
  .lines <- character(0)
  for (.p in S[[.id]]) {
    .o <- run_piece(.p)
    .lines <- c(.lines, strsplit(.p, "\n", fixed = TRUE)[[1]],
                if (length(.o)) paste0("#> ", .o))
  }
  if (!is.null(.fg)) dev.off()
  .lines <- sub("[[:space:]]+$", "", .lines)   # no trailing spaces: the check is verbatim
  if (max(nchar(.lines)) > 86) stop("line too long in ", .id, ": ", .lines[nchar(.lines) > 86][1])
  blocks[[.id]] <- paste(.lines, collapse = "\n")
}

## ------------------------------------------------------------------ data for the figure script
hid <- is.na(demo$waist)
write.csv(data.frame(bmi = dom$bmi, waist = dom$waist, hidden = as.integer(hid),
                     mean = fills$mean$waist, regression = fills$regression$waist,
                     stochastic = fills$stochastic$waist),
          "Week7_fig_single.csv", row.names = FALSE)
est_se <- function(fits, term) t(sapply(fits$analyses, function(f)
  c(est = unname(coef(f)[term]), se = unname(sqrt(diag(vcov(f)))[term]))))
rt <- est_se(fit_died, 2); rm_ <- est_se(fits, "central")
write.csv(rbind(data.frame(source = "town", k = seq_len(nrow(rt)), rt),
                data.frame(source = "masld", k = seq_len(nrow(rm_)), rm_)),
          "Week7_fig_rubin.csv", row.names = FALSE)

## ------------------------------------------------------------------ facts the prose quotes
f2 <- function(x) sprintf("%.2f", x)
sm <- t(sapply(fills, function(x) c(sd = sd(x$waist), cor = cor(x$bmi, x$waist))))
pm <- pool(fit_mnar)$pooled[2, ]
rownames(p) <- p$term; est <- setNames(p$estimate, p$term)   # the slides print one row
pc <- p[c("central", "obese:central"), ]
facts <- list(
  single_n_hidden = format(sum(hid), big.mark = ","),
  single_sd_truth = sprintf("%.1f", sm["truth", "sd"]),
  single_sd_mean = sprintf("%.1f", sm["mean", "sd"]),
  single_sd_reg = sprintf("%.1f", sm["regression", "sd"]),
  single_sd_stoch = sprintf("%.1f", sm["stochastic", "sd"]),
  single_cor_truth = f2(sm["truth", "cor"]), single_cor_mean = f2(sm["mean", "cor"]),
  single_cor_reg = f2(sm["regression", "cor"]), single_cor_stoch = f2(sm["stochastic", "cor"]),
  town_mi_died = f2(exp(pt$estimate)), town_mi_mnar = f2(exp(pm$estimate)),
  town_ubar = sprintf("%.5f", pt$ubar), town_b = sprintf("%.5f", pt$b), town_t = sprintf("%.5f", pt$t),
  town_fmi = f2(pt$fmi),
  masld_b_central = sprintf("%.5f", pc["central", "b"]),
  masld_ubar_central = sprintf("%.5f", pc["central", "ubar"]),
  masld_fmi_central = sprintf("%.3f", pc["central", "fmi"]),
  masld_fmi_ratio = sprintf("%.3f", pc["obese:central", "fmi"]),
  masld_hr_copy_min = sprintf("%.3f", min(hr)), masld_hr_copy_max = sprintf("%.3f", max(hr)),
  n_long = format(nrow(long), big.mark = ","), n_frame = format(nrow(fast), big.mark = ","),
  n_rest = format(nrow(fast) - nrow(dat), big.mark = ","),
  n_frame_child = format(.n_child, big.mark = ","), frame_min_age = as.character(.min_age),
  sed_sd_min = sprintf("%.0f", sed_s), delta30_sd = sprintf("%.2f", 30 / sed_s),
  r_version = paste0(R.version$major, ".", R.version$minor),
  mice_version = as.character(packageVersion("mice")),
  survey_version = as.character(packageVersion("survey")))

## ------------------------------------------------------------------ agreement with the main script
fx <- fromJSON("Week7_missing_data.json")$facts
num <- function(s) as.numeric(regmatches(s, regexpr("[0-9.]+", s)))
hr3 <- function(b) round(exp(c(b[["central"]], b[["central"]] + b[["obese:central"]],
                               b[["obese:central"]])), 2)
stopifnot(
  abs(mean(town$smoker) - 0.32) < 1e-12,
  identical(unname(sapply(hidden, sum)), as.integer(gsub(",", "", c(fx$town_MCAR_hidden,
    fx$town_MAR_age_hidden, fx$town_MNAR_hidden, fx$town_MAR_died_hidden)))),
  nrow(obs) == 840, abs(mean(obs$smoker) - 160 / 840) < 1e-12,
  isTRUE(all.equal(sd(mean_fill$waist), sd(fills$mean$waist))),
  identical(sprintf("%.2f", sapply(hidden, cc)["rr_old", ]),
            c(fx$town_MCAR_rr_o, fx$town_MAR_age_rr_o, fx$town_MNAR_rr_o, fx$town_MAR_died_rr_o)),
  isTRUE(all.equal(hr3(est), c(num(fx$wa_nonob_uw_mi), num(fx$wa_ob_uw_mi), num(fx$wa_ratio_uw_mi)))),
  isTRUE(all.equal(hr3(est_w), c(num(fx$wa_nonob_w_mi), num(fx$wa_ob_w_mi), num(fx$wa_ratio_w_mi)))),
  round(100 * mean(sapply(1:20, function(k) mean(complete(imp_lin, k)$smk[is.na(dat$smk)] == "1")))) ==
    num(fx$smk_imp_1819_lin),
  isTRUE(all.equal(unname(stress(function(y) "0", function(y) lo)), c(num(fx$wa_nonob_x_none), num(fx$wa_ratio_x_none)))),
  isTRUE(all.equal(unname(stress(function(y) "1", function(y) hi)), c(num(fx$wa_nonob_x_all), num(fx$wa_ratio_x_all)))),
  isTRUE(all.equal(unname(stress(function(y) ifelse(y == 1, "1", "0"), function(y) ifelse(y == 1, hi, lo))),
                   c(num(fx$wa_nonob_x_dead), num(fx$wa_ratio_x_dead)))),
  isTRUE(all.equal(unname(stress(function(y) ifelse(y == 0, "1", "0"), function(y) ifelse(y == 0, hi, lo))),
                   c(num(fx$wa_nonob_x_alive), num(fx$wa_ratio_x_alive)))),
  round(100 * mean(ans$days30 %in% 1:30)) == num(fx$youth_any30_pct),
  round(100 * mean(ans$days30 %in% 30)) == num(fx$youth_daily_pct),
  abs(round(100 * mean(filled_smk <- sapply(1:20, function(k)
    mean(complete(imp, k)$smk[is.na(dat$smk)] == "1")))) - num(fx$smk_imp_1819)) < 1e-9,
  sum(ccL) == as.numeric(gsub(",", "", fx$n_ccL)),
  all(table(full$.imp) == nrow(fast)), sum(full$in_dom == 1) == 20 * nrow(dat))

writeLines(toJSON(list(emitted_by = "Week7_code_outputs", facts = facts, blocks = blocks),
                  auto_unbox = TRUE, pretty = TRUE), "Week7_code_outputs.json", useBytes = TRUE)
for (k in names(blocks)) cat("==== ", k, "\n", blocks[[k]], "\n\n", sep = "")
for (k in names(facts)) cat(sprintf("%-22s %s\n", k, facts[[k]]))
