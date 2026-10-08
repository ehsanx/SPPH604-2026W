## Week 6: the R code shown on the deck's code slides, and its real output.
##
## Each snippet below is run exactly as it appears on a slide, in one shared session, and
## its printed output is captured underneath it in reprex style ("#>" lines). The finished
## blocks are written to Week6_code_outputs.json and copied into the deck, and a check fails
## if a slide's block differs from what this script printed. Nothing on a code slide is
## typed by hand.
##
## Run from this folder:   Rscript Week6_code_outputs.R
##
## The data set-up is not shown on the slides. `nhanes` is every NHANES 2007-2018
## participant (59,842 rows), carrying the design variables and, for our rows, the model
## variables. `in_rows` marks Week 4's 5,911 MASLD adults; `d` is those rows alone, exactly
## as in Week6_design_aware.R. `MASLD` marks the 6,371 adults of the analytic file.
##
## Three code slides are not here: the 1999-2004 and 2017-March 2020 pooling examples use
## cycles outside our 2007-2018 data. A separate check runs them on a small made-up file
## and compares the weights they build with the slides' formulas.

source("../../examples/_shared/paths.R")   # find_repro()
repro <- find_repro()
suppressPackageStartupMessages({library(survival); library(survey); library(jsonlite)})
options(width = 72, digits = 7)

.a <- readRDS(file.path(repro, "data/derived/masld_analytic.rds"))
.m <- readRDS(file.path(repro, "data/derived/merged_all.rds"))
.m$in_analysis <- .m$SEQN %in% .a$SEQN
dom <- .m[.m$in_analysis & !is.na(.m$WTSAF2YR) & .m$WTSAF2YR > 0, ]
dom$smk_current <- ifelse(dom$SMQ020 == 1 & dom$SMQ040 %in% c(1, 2), 1L,
                          ifelse(is.na(dom$SMQ020), NA_integer_, 0L))
dom$sed  <- as.numeric(scale(dom$sedentary_min))
dom$race <- factor(dom$RIDRETH1)
dom$group <- factor(dom$group, levels = c("I", "II", "III", "IV"))
COV2 <- c("age", "female", "dyslip", "htn", "t2dm", "ckd", "mi", "cancer",
          "on_htn_med", "on_dm_med", "on_lipid_med", "smk_current", "sed")
d <- dom[complete.cases(dom[, unique(c(COV2, "race"))]), ]
stopifnot(nrow(d) == 5911)
d$IV <- as.integer(d$group == "IV")
d$wt <- d$WTSAF2YR / 6
rownames(d) <- NULL

nhanes <- .m
nhanes$in_rows <- nhanes$SEQN %in% d$SEQN
nhanes$MASLD <- as.integer(nhanes$SEQN %in% .a$SEQN)
i <- match(nhanes$SEQN, d$SEQN)
for (v in c("smk_current", "sed", "race", "group", "IV")) nhanes[[v]] <- d[[v]][i]
rm(i, v)

## ------------------------------------------------------------------ the snippets
## In deck order. Each snippet is a list of pieces; a piece's output is printed right
## after it. A piece that starts with "\n" leaves a blank line above it on the slide.
S <- list(

town_weight = list(
'town <- data.frame(
  age_group = c("Younger", "Older"),
  in_town = c(900, 100),
  sampled = c(100, 100)
)

town$chance <- town$sampled / town$in_town
town$weight <- 1 / town$chance
town'),

town_sample = list(
'library(survey)

s <- data.frame(
  age_group = rep(c("Younger", "Older"), each = 100),
  weight = rep(c(9, 1), each = 100)
)

s$htn <- c(
  rep(1, 15), rep(0, 85),
  rep(1, 40), rep(0, 60)
)

mean(s$htn)'),

town_svymean = list(
'des_town <- svydesign(
  ids = ~1,
  weights = ~weight,
  data = s
)

svymean(~htn, des_town)'),

pool6 = list(
'fast <- subset(nhanes, WTSAF2YR > 0)
fast$wt <- fast$WTSAF2YR / 6

full6 <- svydesign(
  ids = ~SDMVPSU, strata = ~SDMVSTRA,
  weights = ~wt, nest = TRUE, data = fast
)

full1 <- svydesign(
  ids = ~SDMVPSU, strata = ~SDMVSTRA,
  weights = ~WTSAF2YR, nest = TRUE, data = fast
)

round(c(
  divided = sum(weights(subset(full6, in_rows))),
  not_divided = sum(weights(subset(full1, in_rows)))
) / 1e6, 1)'),

design = list(
'# 1. People eligible for the fasting-subsample weight
fast <- subset(nhanes, WTSAF2YR > 0)
fast$wt <- fast$WTSAF2YR / 6

# 2. Tell R how NHANES sampled them
library(survey)
des_full <- svydesign(
  ids = ~SDMVPSU,
  strata = ~SDMVSTRA,
  weights = ~wt,
  nest = TRUE,
  data = fast
)'),

subset_wrong = list(
'masld <- subset(fast, in_rows)

des_wrong <- svydesign(
  ids = ~SDMVPSU,
  strata = ~SDMVSTRA,
  weights = ~wt,
  nest = TRUE,
  data = masld
)'),

subset_right = list(
'des_full <- svydesign(
  ids = ~SDMVPSU,
  strata = ~SDMVSTRA,
  weights = ~wt,
  nest = TRUE,
  data = fast
)

des <- subset(des_full, in_rows)'),

lonely = list(
'# Group I women: obese, lower waist fat
gw <- subset(fast, in_rows & group == "I" & female == 1)

c(people = nrow(gw), strata = length(unique(gw$SDMVSTRA)))',
'
tryCatch(svymean(~age, svydesign(
  ids = ~SDMVPSU, strata = ~SDMVSTRA,
  weights = ~wt, nest = TRUE, data = gw
)), error = function(e) cat("Error:", conditionMessage(e)))',
'
svymean(~age, subset(des_full, in_rows & group == "I" & female == 1))'),

complete_cases = list(
'fast$complete_model <- complete.cases(
  fast[, c("time_yr", "dead", "obese", "central",
           "age", "female", "race", "smk_current", "sed")]
)

# survey design already exists
des_full <- update(des_full, complete_model = fast$complete_model)
analysis_des <- subset(
  des_full,
  MASLD == 1 & complete_model
)'),

kish = list(
'w <- s$weight
n <- length(w)
deff <- n * sum(w^2) / sum(w)^2
round(c(deff = deff, effective_n = n / deff), 2)'),

fit_model = list(
'fm <- Surv(time_yr, dead) ~ obese * central +
  age + female + race + smk_current + sed

fit_w <- svycoxph(fm, design = des)'),

regterm = list(
'regTermTest(
  fit_w,
  ~obese:central,
  df = degf(des)
)'),

week5_w = list(
'fit_u <- coxph(fm, data = d)          # ordinary model
fit_w <- svycoxph(fm, design = des)   # NHANES design

waist_hr <- function(fit, obese) {
  b <- coef(fit)
  exp(b[["central"]] + obese * b[["obese:central"]])
}

round(c(
  unweighted_not_obese = waist_hr(fit_u, 0),
  weighted_not_obese   = waist_hr(fit_w, 0),
  unweighted_obese     = waist_hr(fit_u, 1),
  weighted_obese       = waist_hr(fit_w, 1)
), 2)'),

mec = list(
'mec <- subset(nhanes, WTMEC2YR > 0)
mec$wt <- mec$WTMEC2YR / 6

des_mec <- subset(
  svydesign(
    ids = ~SDMVPSU, strata = ~SDMVSTRA,
    weights = ~wt, nest = TRUE, data = mec
  ),
  in_rows
)

fit_m <- svycoxph(fm, design = des_mec)

round(rbind(
  fasting = c(not_obese = waist_hr(fit_w, 0), obese = waist_hr(fit_w, 1)),
  exam    = c(not_obese = waist_hr(fit_m, 0), obese = waist_hr(fit_m, 1))
), 2)'),

sodium_build = list(
'# 100 younger + 100 older; half exposed in each age group
s2 <- data.frame(
  age_group = rep(c("Younger", "Older"), each = 100),
  high_sodium = rep(rep(c(0, 1), each = 50), times = 2),
  weight = rep(c(9, 1), each = 100)
)

cases <- function(k, n = 50) c(rep(1, k), rep(0, n - k))
s2$incident_htn <- c(
  cases(5), cases(10),    # younger: 10% -> 20%
  cases(10), cases(30)    # older:   20% -> 60%
)

des2 <- svydesign(ids = ~1, weights = ~weight, data = s2)'),

sodium_rr = list(
'fit_sample <- glm(
  incident_htn ~ high_sodium,
  family = poisson(link = "log"), data = s2
)

fit_town <- svyglm(
  incident_htn ~ high_sodium,
  family = quasipoisson(link = "log"), design = des2
)

round(exp(c(
  sample = coef(fit_sample)[["high_sodium"]],
  town = coef(fit_town)[["high_sodium"]]
)), 2)'),

ci_cost = list(
'v <- function(fit) vcov(fit)["central", "central"]

fast$one <- 1

des_eq <- subset(
  svydesign(
    ids = ~SDMVPSU, strata = ~SDMVSTRA,
    weights = ~one, nest = TRUE, data = fast
  ),
  in_rows
)

vs <- c(
  model    = v(fit_u),
  clusters = v(svycoxph(fm, design = des_eq)),
  weights  = v(coxph(fm, data = d, weights = wt, robust = TRUE)),
  design   = v(fit_w)
)

round(vs / vs[["model"]], 2)'),

km = list(
'km <- svykm(Surv(time_yr, dead) ~ group, design = des)

died6 <- function(k) {
  100 * (1 - k$surv[max(which(k$time <= 6))])
}

round(sapply(km, died6), 1)',
'
lr <- svylogrank(Surv(time_yr, dead) ~ group, design = des)
round(lr[[2]], 4)'),

sex = list(
'fs <- Surv(time_yr, dead) ~
  IV * female + age + race + smk_current + sed

d34 <- subset(des, group %in% c("III", "IV"))
fit_s <- svycoxph(fs, design = d34)

round(exp(c(
  ratio = coef(fit_s)[["IV:female"]],
  confint(fit_s)["IV:female", ]
)), 2)',
'
regTermTest(fit_s, ~IV:female, df = degf(des))')
)

## Console width, per snippet, where the slide lays a printed vector out in pairs.
## Anything not listed prints at width 72.
WIDTH <- c(week5_w = 60)

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
blocks <- list()
for (k in names(S)) {
  options(width = if (k %in% names(WIDTH)) WIDTH[[k]] else 72)
  lines <- character(0)
  for (p in S[[k]]) {
    o <- run_piece(p)
    lines <- c(lines, strsplit(p, "\n", fixed = TRUE)[[1]],
               if (length(o)) paste0("#> ", o))
  }
  lines <- sub("[[:space:]]+$", "", lines)   # no trailing spaces: the check is verbatim
  stopifnot(max(nchar(lines)) <= 86)         # fits a slide without sideways scrolling
  blocks[[k]] <- paste(lines, collapse = "\n")
}
options(width = 72)

## ------------------------------------------------------------------ agreement with the main script
fx <- fromJSON("Week6_design_aware.json")$facts
num <- function(s) as.numeric(regmatches(s, regexpr("[0-9.]+", s)))
r2 <- function(x) round(x, 2)
stopifnot(
  abs(mean(s$htn) - 0.275) < 1e-12, abs(coef(svymean(~htn, des_town)) - 0.175) < 1e-12,
  abs(deff - 1.64) < 1e-12,
  r2(exp(coef(fit_sample)[["high_sodium"]])) == 2.67,
  r2(exp(coef(fit_town)[["high_sodium"]])) == 2.18,
  nrow(gw) == num(fx$gw_n), length(unique(gw$SDMVSTRA)) == num(fx$gw_strata),
  abs(r2(waist_hr(fit_u, 0)) - num(fx$wa_nonob_uw_L)) < 1e-9,
  abs(r2(waist_hr(fit_u, 1)) - num(fx$wa_ob_uw_L)) < 1e-9,
  abs(r2(waist_hr(fit_w, 0)) - num(fx$wa_nonob_w_L)) < 1e-9,
  abs(r2(waist_hr(fit_w, 1)) - num(fx$wa_ob_w_L)) < 1e-9,
  abs(r2(waist_hr(fit_m, 0)) - num(fx$wa_nonob_mec)) < 1e-9,
  abs(r2(waist_hr(fit_m, 1)) - num(fx$wa_ob_mec)) < 1e-9,
  abs(round(vs[["design"]] / vs[["model"]], 2) - num(fx$vr_design)) < 1e-9,
  abs(round(vs[["weights"]] / vs[["model"]], 2) - num(fx$vr_wonly)) < 1e-9,
  abs(round(vs[["clusters"]] / vs[["model"]], 2) - num(fx$vr_clust)) < 1e-9,
  abs(round(died6(km[["IV"]]), 1) - num(fx$died6_IV_w)) < 1e-9,
  abs(round(lr[[2]][["Chisq"]], 1) - num(fx$lr_w_chisq)) < 1e-9,
  degf(des_full) == as.numeric(fx$degf))

## The fitted models use the emitted rows and deaths; Slide 18's title (the /6 moves no
## coefficient) holds for every coefficient of the interaction model.
stopifnot(fit_w$n == num(gsub(",", "", fx$n_model)), fit_w$nevent == num(fx$events_model),
          fit_s$n == num(gsub(",", "", fx$n_sex34)), fit_s$nevent == num(fx$events_sex34))
pool_fm <- Surv(time_yr, dead) ~ obese * central + age + female + race + smk_current + sed
pool_b6 <- coef(svycoxph(pool_fm, design = subset(full6, in_rows)))
pool_b1 <- coef(svycoxph(pool_fm, design = subset(full1, in_rows)))
stopifnot(max(abs(pool_b6 - pool_b1)) < 1e-10)
## The complete-case slide prints nothing. In this hidden set-up race, smk_current and sed
## exist only for d's rows, so its domain equals in_rows; on the full data the slide's nine
## variables are complete for 5,963 rows (n_complete_L, Week 7's figure).
cat("complete-case domain as the hidden set-up defines it (= in_rows):", nrow(analysis_des), "rows\n")
cat("full-domain complete cases on the nine model variables:", fx$n_complete_L, "rows\n")
cat("all fitted coefficients unchanged by /6 within tolerance 1e-10\n")

writeLines(toJSON(list(emitted_by = "Week6_code_outputs", blocks = blocks),
                  auto_unbox = TRUE, pretty = TRUE), "Week6_code_outputs.json", useBytes = TRUE)
for (k in names(blocks)) cat("==== ", k, "\n", blocks[[k]], "\n\n", sep = "")
