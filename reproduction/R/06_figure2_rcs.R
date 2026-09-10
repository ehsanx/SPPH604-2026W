# ============================================================================
# 06_figure2_rcs.R  --  Reproduce Figure 2: restricted cubic spline curves for
#   the association of BMI (a) and WHtR (b) with probability of all-cause death
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
suppressPackageStartupMessages({library(rms); library(ggplot2); library(patchwork)})
d <- readRDS(file.path(DIR_DERIVED, "masld_analytic.rds"))
dd <- datadist(d); options(datadist = "dd")

panel <- function(var, xlab, xlim) {
  f <- lrm(as.formula(sprintf("dead ~ rcs(%s, 4)", var)), data = d)
  p <- as.data.frame(Predict(f, name = var, fun = plogis, np = 200))
  names(p)[names(p)==var] <- "x"
  ggplot(p, aes(x, yhat)) +
    geom_ribbon(aes(ymin = lower, ymax = upper), fill = "grey70", alpha = 0.5) +
    geom_line(colour = "#2C6FBB", linewidth = 0.8) +
    coord_cartesian(xlim = xlim) +
    labs(x = xlab, y = "Probability of All-Cause Mortality") +
    theme_bw(base_size = 11) +
    theme(panel.grid.minor = element_blank(),
          strip.background = element_rect(fill = "grey90")) +
    facet_wrap(~ toupper(sub("bmi","BMI", sub("whtr","WHtR", var))))
}

pa <- panel("bmi",  expression(BMI~(kg/m^2)), c(18, 65))
pb <- panel("whtr", "WHtR",                   c(0.45, 1.0))
fig <- pa + pb + plot_annotation(tag_levels = "a")

ggsave(file.path(DIR_FIGURES, "figure2_rcs.png"), fig,
       width = 9, height = 4, dpi = 220)
cat("Saved output/figures/figure2_rcs.png\n")
cat("BMI spline non-linear p, WHtR spline: see model anova\n")
print(anova(lrm(dead ~ rcs(bmi,4), data=d)))
print(anova(lrm(dead ~ rcs(whtr,4), data=d)))
