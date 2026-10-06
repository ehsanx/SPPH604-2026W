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
## Each snippet is a list of pieces; a piece's output is printed right after it.
S <- list(

diabetes_tab = list(
'tab <- table(diabetes = d$t2dm, high_waist = d$central)
tab                                    # people',
'round(100 * prop.table(tab, 2))        # % in each waist group'),

diabetes = list(
'f_no  <- coxph(Surv(time_yr, dead) ~ central + obese + age + female +
                 race + smk_current + sed, data = subset(d, t2dm == 0))
f_yes <- coxph(Surv(time_yr, dead) ~ central + obese + age + female +
                 race + smk_current + sed, data = subset(d, t2dm == 1))
round(summary(f_no)$conf.int["central", c(1, 3, 4)], 2)   # HR, lower, upper',
'round(summary(f_yes)$conf.int["central", c(1, 3, 4)], 2)'),

scale_toy = list(
'toy <- data.frame(age = c("60+", "<60"),
                  risk1 = c(0.80, 0.50), risk0 = c(0.50, 0.20))
toy$RD <- toy$risk1 - toy$risk0                    # risk difference
toy$RR <- toy$risk1 / toy$risk0                    # risk ratio
toy$OR <- (toy$risk1 / (1 - toy$risk1)) /
          (toy$risk0 / (1 - toy$risk0))            # odds ratio
toy'),

measures_toy = list(
'r00 <- 0.05; r10 <- 0.10; r01 <- 0.15; r11 <- 0.30   # risk, A = a, M = m
rr10 <- r10 / r00; rr01 <- r01 / r00; rr11 <- r11 / r00
RERI <- rr11 - rr10 - rr01 + 1
round(c(ratio = rr11 / (rr10 * rr01),          # multiplicative: 1 = none
        RERI  = RERI,                          # additive: 0 = none
        AP    = RERI / rr11,                   # additive: 0 = none
        S     = (rr11 - 1) / ((rr10 - 1) + (rr01 - 1)),   # additive: 1 = none
        IC    = r11 - r10 - r01 + r00), 3)     # additive, in risk: 0 = none'),

counts = list(
'table(group = d$group, died = d$dead)',
'with(subset(d, obese == 1 & female == 1),     # obese women only
     table(high_waist = central))'),

twoways = list(
'fit_joint <- coxph(Surv(time_yr, dead) ~ group +
                     age + female + race + smk_current + sed, data = d)
fit_prod  <- coxph(Surv(time_yr, dead) ~ obese * central +
                     age + female + race + smk_current + sed, data = d)
all.equal(fit_joint$loglik, fit_prod$loglik)     # the same fit?',
'round(exp(coef(fit_prod))[c("obese", "central", "obese:central")], 2)'),

strata = list(
'b <- coef(fit_prod)
round(exp(b[["central"]]), 2)                 # not obese: IV vs III',
'round(exp(b[["central"]] + b[["obese:central"]]), 2)   # obese: II vs I',
'd$notobese <- 1 - d$obese      # flip: the obese become the reference
fit_flip <- coxph(Surv(time_yr, dead) ~ notobese * central +
                    age + female + race + smk_current + sed, data = d)
round(summary(fit_flip)$conf.int["central", c(1, 3, 4)], 2)   # HR, lower, upper'),

lrt = list(
'# fit_prod: from "One model, two ways"
fit_main <- coxph(Surv(time_yr, dead) ~ obese + central +   # no product
                    age + female + race + smk_current + sed, data = d)
round(exp(coef(fit_main))[["central"]], 2)    # one HR for all: Week 4\'s',
'lr <- anova(fit_main, fit_prod)       # likelihood-ratio test, product term
round(c(chisq = lr$Chisq[2], p = lr$`Pr(>|Chi|)`[2]), 3)'),

std = list(
'risk6 <- function(people, g) {   # fit_joint: from "One model, two ways"
  people$group <- factor(g, levels = levels(d$group))   # set everyone to g
  1 - mean(summary(survfit(fit_joint, newdata = people), times = 6)$surv)
}
ob <- subset(d, obese == 1); notob <- subset(d, obese == 0)
r_within <- c(I = risk6(ob, "I"), II = risk6(ob, "II"),           # obese
              III = risk6(notob, "III"), IV = risk6(notob, "IV"))  # not obese
round(100 * r_within, 1)                  # standardised 6-year risk, %',
'rd <- 100 * c(obese = r_within[["II"]] - r_within[["I"]],
              not_obese = r_within[["IV"]] - r_within[["III"]])
round(c(rd, difference = rd[["obese"]] - rd[["not_obese"]]), 1)   # points'),

joint = list(
'# fit_joint and risk6(): from the earlier In-R slides
h <- exp(coef(fit_joint))[c("groupII", "groupIII", "groupIV")]   # vs I
RERI <- h[["groupIV"]] - h[["groupII"]] - h[["groupIII"]] + 1
round(c(RERI = RERI, AP = RERI / h[["groupIV"]],
        S = (h[["groupIV"]] - 1) /
            ((h[["groupII"]] - 1) + (h[["groupIII"]] - 1))), 2)',
'r_all <- sapply(c("I", "II", "III", "IV"),
                function(g) risk6(d, g))       # everyone, set to each group
round(100 * c(r_all, IC = r_all[["IV"]] - r_all[["II"]] -
                          r_all[["III"]] + r_all[["I"]]), 1)'),

sexcount = list(
'with(subset(dom, group == "I"), table(female, died = dead))   # 6,048 rows'),

sextest = list(
's34 <- subset(d, group %in% c("III", "IV"))   # the locked contrast only
s34$IV <- as.integer(s34$group == "IV")
f0 <- coxph(Surv(time_yr, dead) ~ IV + female +        # no product term
              age + race + smk_current + sed, data = s34)
f1 <- coxph(Surv(time_yr, dead) ~ IV * female +        # IV x sex
              age + race + smk_current + sed, data = s34)
round(summary(f1)$conf.int["IV:female", c(1, 3, 4)], 2)   # HR, lower, upper',
'round(anova(f0, f1)$`Pr(>|Chi|)`[2], 2)        # likelihood-ratio p')
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
  stopifnot(max(nchar(lines)) <= 80)         # fits a slide without sideways scrolling
  paste(lines, collapse = "\n")
})

## ------------------------------------------------------------------ agreement with the main script
fx <- fromJSON("Week5_joint_exposure.json")$facts
num <- function(s) as.numeric(gsub("−", "-", regmatches(s, regexpr("[+−-]?[0-9.]+", s))))
stopifnot(
  isTRUE(all.equal(fit_joint$loglik, fit_prod$loglik)),
  abs(round(exp(b[["central"]]), 2) - num(fx$hr_whtr_nonobese)) < 1e-9,
  abs(round(exp(b[["central"]] + b[["obese:central"]]), 2) - num(fx$hr_whtr_obese)) < 1e-9,
  abs(round(exp(coef(fit_main))[["central"]], 2) - num(fx$hr_waist_nomod)) < 1e-9,
  abs(round(RERI, 2) - num(fx$reri)) < 1e-9,
  abs(round(100 * r_within[["I"]], 1) - num(fx$risk6_em_I)) < 1e-9,
  abs(round(100 * (r_all[["IV"]] - r_all[["II"]] - r_all[["III"]] + r_all[["I"]]), 1) -
        num(fx$ic6)) < 1e-9,
  abs(round(rd[["obese"]] - rd[["not_obese"]], 1) - num(fx$rd_whtr_diff)) < 1e-9)

writeLines(toJSON(list(emitted_by = "Week5_code_outputs", blocks = blocks),
                  auto_unbox = TRUE, pretty = TRUE), "Week5_code_outputs.json", useBytes = TRUE)
for (k in names(blocks)) cat("==== ", k, "\n", blocks[[k]], "\n\n", sep = "")
