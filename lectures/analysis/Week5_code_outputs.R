## Week 5: the R code shown on the deck's "In R" slides, and its real output.
##
## Each snippet below is run exactly as it appears on a slide, in one shared session, and
## its printed output is captured underneath it in reprex style ("#>" lines). The finished
## blocks are written to Week5_code_outputs.json; the deck carries them verbatim, and a
## check fails if a slide's block differs from what this script printed. Nothing on an
## "In R" slide is typed by hand.
##
## Run from this folder:   Rscript Week5_code_outputs.R
##
## The data set-up is not shown on the slides: `d` is Week 4's 5,911 rows and `dom` the
## 6,048-row locked domain, built exactly as in Week5_joint_exposure.R.

source("../../examples/_shared/paths.R")   # find_repro()
repro <- find_repro()
suppressPackageStartupMessages({library(survival); library(jsonlite)})
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
stopifnot(nrow(d) == 5911, nrow(dom) == 6048)
rownames(d) <- NULL

## ------------------------------------------------------------------ the snippets
## In deck order. Each snippet is a list of pieces; a piece's output is printed right
## after it. A snippet with no printed output is still run, so the slide's code is checked.
S <- list(

smoke_em = list(
'toy <- data.frame(
  income = c("Higher", "Low"),
  risk_nonsmoke = c(0.05, 0.15),
  risk_smoke    = c(0.10, 0.30)
)

toy$RD <- toy$risk_smoke - toy$risk_nonsmoke
toy$RR <- toy$risk_smoke / toy$risk_nonsmoke
toy'),

smoke_int = list(
'r00 <- 0.05  # higher income, not smoking
r10 <- 0.10  # higher income, smoking
r01 <- 0.15  # low income, not smoking
r11 <- 0.30  # low income, smoking

rr10 <- r10 / r00
rr01 <- r01 / r00
rr11 <- r11 / r00

mult_ratio <- rr11 / (rr10 * rr01)
IC <- r11 - r10 - r01 + r00
round(c(mult_ratio = mult_ratio, IC = IC), 2)'),

counts = list(
'table(group = d$group, died = d$dead)',
'
with(subset(d, obese == 1 & female == 1),
     table(high_waist = central))'),

fit_model = list(
'fit <- coxph(Surv(time_yr, dead) ~ obese * central +
               age + female + race + smk_current + sed, data = d)'),

recover = list(
'b <- coef(fit)

round(exp(b[["central"]]), 2)                      # not obese: IV vs III',
'
round(exp(b[["central"]] + b[["obese:central"]]), 2)   # obese: II vs I',
'
fit_main <- coxph(Surv(time_yr, dead) ~ obese + central +
                    age + female + race + smk_current + sed, data = d)
round(anova(fit_main, fit)$`Pr(>|Chi|)`[2], 3)     # likelihood-ratio p'),

risk6_em = list(
'# fit is the Cox model from the preceding slides
risk6 <- function(people, waist) {
  nd <- people                 # same people, same L values
  nd$central <- waist          # change only high-waist exposure
  s6 <- summary(survfit(fit, newdata = nd), times = 6)$surv
  mean(1 - s6)                 # average predicted 6-year risk
}

ob    <- subset(d, obese == 1)
notob <- subset(d, obese == 0)

r <- c(
  obese_low     = risk6(ob,    0),
  obese_high    = risk6(ob,    1),
  notobese_low  = risk6(notob, 0),
  notobese_high = risk6(notob, 1)
)
round(100 * r, 1)'),

rd = list(
'rd <- 100 * c(
  obese     = r[["obese_high"]]    - r[["obese_low"]],
  not_obese = r[["notobese_high"]] - r[["notobese_low"]]
)
round(rd, 1)',
'
round(rd[["obese"]] - rd[["not_obese"]], 1)   # difference of risk differences'),

int_mult = list(
'# Multiplicative interaction from the Cox product term
b <- coef(fit)
round(exp(b[["obese:central"]]), 2)   # HR(waist | obese) / HR(waist | not obese)'),

int_ic = list(
'# A = high waist, M = obesity
# R00 = Group III; R10 = IV; R01 = I; R11 = II
risk6_all <- function(waist, obese) {   # everyone, set to one joint state
  nd <- d; nd$central <- waist; nd$obese <- obese
  mean(1 - summary(survfit(fit, newdata = nd), times = 6)$surv)
}
R <- c(R00 = risk6_all(0, 0), R10 = risk6_all(1, 0),
       R01 = risk6_all(0, 1), R11 = risk6_all(1, 1))
round(100 * R, 1)',
'
IC <- 100 * (R[["R11"]] - R[["R01"]] - R[["R10"]] + R[["R00"]])
round(IC, 1)   # percentage points'),

crude_sex = list(
'dom$group <- relevel(factor(dom$group), ref = "I")

fit_men <- coxph(Surv(time_yr, dead) ~ group,
                 data = subset(dom, female == 0))
fit_women <- coxph(Surv(time_yr, dead) ~ group,
                   data = subset(dom, female == 1))

round(summary(fit_men)$conf.int[
  "groupIV", c("exp(coef)", "lower .95", "upper .95")], 2)',
'
round(summary(fit_women)$conf.int[
  "groupIV", c("exp(coef)", "lower .95", "upper .95")], 2)'),

sexcount = list(
'with(subset(dom, group == "I"), table(female, died = dead))'),

sextest = list(
's34 <- subset(d, group %in% c("III", "IV"))
s34$IV <- as.integer(s34$group == "IV")

f0 <- coxph(Surv(time_yr, dead) ~ IV + female +
              age + race + smk_current + sed, data = s34)
f1 <- coxph(Surv(time_yr, dead) ~ IV * female +
              age + race + smk_current + sed, data = s34)

round(summary(f1)$conf.int["IV:female", c(1, 3, 4)], 2)   # ratio of HRs',
'
round(anova(f0, f1)$`Pr(>|Chi|)`[2], 2)   # likelihood-ratio p'),

twoways = list(
'fit_joint <- coxph(Surv(time_yr, dead) ~ group +
                     age + female + race + smk_current + sed, data = d)
fit_prod  <- coxph(Surv(time_yr, dead) ~ obese * central +
                     age + female + race + smk_current + sed, data = d)
all.equal(fit_joint$loglik, fit_prod$loglik)',
'
round(exp(coef(fit_prod))[c("obese", "central", "obese:central")], 2)'),

diabetes_tab = list(
'tab <- table(diabetes = d$t2dm, high_waist = d$central)
round(100 * prop.table(tab, 2))'),

dm_models = list(
'f_no  <- coxph(Surv(time_yr, dead) ~ central + obese + age + female +
                 race + smk_current + sed, data = subset(d, t2dm == 0))
f_yes <- coxph(Surv(time_yr, dead) ~ central + obese + age + female +
                 race + smk_current + sed, data = subset(d, t2dm == 1))')
)

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
blocks <- lapply(S, function(pieces) {
  lines <- character(0)
  for (p in pieces) {
    o <- run_piece(p)
    lines <- c(lines, strsplit(p, "\n", fixed = TRUE)[[1]],
               if (length(o)) paste0("#> ", o))
  }
  lines <- sub("[[:space:]]+$", "", lines)   # no trailing spaces: the check is verbatim
  stopifnot(max(nchar(lines)) <= 86)         # fits a slide without sideways scrolling
  paste(lines, collapse = "\n")
})

## ------------------------------------------------------------------ agreement with the main script
fx <- fromJSON("Week5_joint_exposure.json")$facts
num <- function(s) as.numeric(gsub("−", "-", regmatches(s, regexpr("[+−-]?[0-9.]+", s))))
count <- function(s) as.integer(gsub(",", "", s, fixed = TRUE))
stopifnot(
  identical(rownames(fit_main$y), rownames(fit$y)),
  identical(rownames(f0$y), rownames(f1$y)),
  fit$n == count(fx$n_model), fit$nevent == count(fx$events_model),
  f1$n == count(fx$n_sex34), f1$nevent == count(fx$events_sex34),
  isTRUE(all.equal(fit_joint$loglik, fit$loglik)),
  abs(round(exp(b[["central"]]), 2) - num(fx$hr_whtr_nonobese)) < 1e-9,
  abs(round(exp(b[["central"]] + b[["obese:central"]]), 2) - num(fx$hr_whtr_obese)) < 1e-9,
  abs(round(exp(b[["obese:central"]]), 2) - num(fx$rhr_whtr)) < 1e-9,
  abs(round(exp(coef(fit_main))[["central"]], 2) - num(fx$hr_waist_nomod)) < 1e-9,
  abs(round(100 * r[["obese_low"]], 1) - num(fx$risk6_em_I)) < 1e-9,
  abs(round(rd[["obese"]] - rd[["not_obese"]], 1) - num(fx$rd_whtr_diff)) < 1e-9,
  # JSON's legacy M = not obese; the slide's M = obese reverses the IC sign.
  abs(round(IC, 1) + num(fx$ic6)) < 1e-9)

writeLines(toJSON(list(emitted_by = "Week5_code_outputs", blocks = blocks,
                      model_diagnostics = list(
                        product = list(n = fit$n, events = fit$nevent),
                        no_product = list(n = fit_main$n, events = fit_main$nevent),
                        sex = list(n = f1$n, events = f1$nevent),
                        sex_no_product = list(n = f0$n, events = f0$nevent))),
                  auto_unbox = TRUE, pretty = TRUE), "Week5_code_outputs.json", useBytes = TRUE)
for (k in names(blocks)) cat("==== ", k, "\n", blocks[[k]], "\n\n", sep = "")
