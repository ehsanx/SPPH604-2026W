# ============================================================================
# 05_figure1_km.R  --  Reproduce Figure 1: Kaplan-Meier all-cause mortality
#                      by BMI/WHtR group, with number-at-risk table + log-rank p
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
suppressPackageStartupMessages({library(survival); library(survminer); library(ggplot2)})
d <- readRDS(file.path(DIR_DERIVED, "masld_analytic.rds"))

fit <- survfit(Surv(time_yr, dead) ~ group, data = d)
lr  <- survdiff(Surv(time_yr, dead) ~ group, data = d)
pval <- 1 - pchisq(lr$chisq, length(lr$n) - 1)
cat("Log-rank p =", format.pval(pval, eps = 1e-4), "\n")
cat("Number at risk (paper: GI 386/355/290/222; GIV 604/546/433/334):\n")
print(summary(fit, times = c(0,2,4,6))$n.risk)

g <- ggsurvplot(
  fit, data = d,
  palette = c("#F8766D","#7CAE00","#00BFC4","#C77CFF"),
  legend.labs = c("Group I","Group II","Group III","Group IV"),
  legend.title = "", title = "All-Cause Mortality",
  xlab = "Time (Years)", ylab = "Survival probability",
  ylim = c(0.80, 1.00), xlim = c(0, 7), break.time.by = 2,
  censor = TRUE, size = 0.7,
  risk.table = TRUE, risk.table.height = 0.28, risk.table.title = "Number at risk",
  risk.table.y.text = FALSE, tables.theme = theme_cleantable(),
  pval = "p < 0.0001", pval.coord = c(0.2, 0.83), ggtheme = theme_classic())

png(file.path(DIR_FIGURES, "figure1_km.png"), width = 1800, height = 1650, res = 220)
print(g); dev.off()
cat("Saved output/figures/figure1_km.png\n")
