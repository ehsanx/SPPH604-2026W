# ============================================================================
# 03_table1.R  --  Reproduce Table 1 (baseline characteristics by BMI/WHtR group)
#   Continuous: age = mean (SD); waist/BMI/WHtR/SBP/DBP = median (IQR)
#   Categorical: n (%).  p: ANOVA (age) / Kruskal-Wallis (skewed) / chi-sq (cat)
#   Saves output/tables/table1_reproduced.{csv,html} and prints vs-paper check.
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
suppressPackageStartupMessages({library(dplyr); library(knitr); library(kableExtra)})
d <- readRDS(file.path(DIR_DERIVED, "masld_analytic.rds"))

grp <- d$group; G <- c("I","II","III","IV")
med_iqr <- function(x) sprintf("%.1f (%.1f-%.1f)", median(x,na.rm=T), quantile(x,.25,na.rm=T), quantile(x,.75,na.rm=T))
mean_sd <- function(x) sprintf("%.1f (%.1f)", mean(x,na.rm=T), sd(x,na.rm=T))
whtr_fmt<- function(x) sprintf("%.2f (%.2f-%.2f)", median(x,na.rm=T), quantile(x,.25,na.rm=T), quantile(x,.75,na.rm=T))
n_pct   <- function(x) { x <- x[!is.na(x)]; sprintf("%d (%.1f)", sum(x==1), 100*mean(x==1)) }

by_group <- function(x, f) c(Overall=f(x), sapply(G, function(g) f(x[grp==g])))
p_kw   <- function(x) format.pval(kruskal.test(x ~ grp)$p.value, digits=2, eps=.001)
p_aov  <- function(x) format.pval(summary(aov(x ~ grp))[[1]][["Pr(>F)"]][1], digits=2, eps=.001)
p_chi  <- function(x) format.pval(suppressWarnings(chisq.test(table(x, grp))$p.value), digits=2, eps=.001)

rows <- list()
addc <- function(label, x, fmt, p) rows[[length(rows)+1]] <<- c(Characteristic=label, by_group(x,fmt), p=p(x))
addb <- function(label, x)         rows[[length(rows)+1]] <<- c(Characteristic=label, by_group(x,n_pct), p=p_chi(x))

addc("Age, year",              d$age,   mean_sd, p_aov)
rows[[length(rows)+1]] <- c(Characteristic="Female, n (%)", by_group(d$female,n_pct), p=p_chi(d$female))
addc("Waist circumference, cm", d$waist, med_iqr, p_kw)
addc("BMI, kg/m2",             d$bmi,   med_iqr, p_kw)
addc("WHtR",                   d$whtr,  whtr_fmt, p_kw)
addc("Systolic BP, mm Hg",     d$sbp,   med_iqr, p_kw)
addc("Diastolic BP, mm Hg",    d$dbp,   med_iqr, p_kw)
addb("Current smoking",        d$current_smoke)
addb("Family history of CHD",  d$famhx_chd)
# PIR categories
pir <- d$pir_cat
for (lv in c("High","Middle","Low")) {
  x <- as.integer(pir==lv)
  rows[[length(rows)+1]] <- c(Characteristic=paste0("  ",lv," income"), by_group(x,n_pct),
                              p=if(lv=="High") p_chi(pir) else "")
}
addb("Hypertension",  d$htn)
addb("T2DM",          d$t2dm)
addb("Dyslipidaemia", d$dyslip)
addb("CKD",           d$ckd)
addb("Stroke",        d$stroke)
addb("MI",            d$mi)
addb("Heart failure", d$hf)
addb("COPD",          d$copd)
addb("Cancer",        d$cancer)

tab <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
# header counts
hdr <- c(Characteristic="n", Overall=nrow(d),
         setNames(as.character(table(grp)[G]), G), p="")
tab <- rbind(hdr, tab)
colnames(tab) <- c("Characteristic",
                   sprintf("Overall (n=%d)", nrow(d)),
                   sprintf("Group I (n=%d)",  sum(grp=="I")),
                   sprintf("Group II (n=%d)", sum(grp=="II")),
                   sprintf("Group III (n=%d)",sum(grp=="III")),
                   sprintf("Group IV (n=%d)", sum(grp=="IV")), "p value")

write.csv(tab, file.path(DIR_TABLES,"table1_reproduced.csv"), row.names=FALSE)
kbl(tab, format="html", caption="Table 1 (reproduced): Baseline characteristics of the MASLD cohort, stratified by BMI/WHtR status") |>
  kable_styling(bootstrap_options=c("striped","condensed"), full_width=FALSE) |>
  save_kable(file.path(DIR_TABLES,"table1_reproduced.html"))

## ---- calibration check vs published Table 1 (Overall column) ---------------
paper <- c("n"="6300","Age, year"="51.0 (16.6)","Female, n (%)"="2973 (47.2)",
  "Waist circumference, cm"="111.0 (104.0-120.0)","BMI, kg/m2"="33.2 (30.2-37.4)",
  "Systolic BP, mm Hg"="124.0 (114.0-135.0)","Diastolic BP, mm Hg"="72.0 (64.7-79.3)",
  "Current smoking"="1210 (40.6)","Family history of CHD"="904 (15.0)",
  "Hypertension"="3238 (52.6)","T2DM"="1645 (26.1)","Dyslipidaemia"="3612 (57.7)",
  "CKD"="1142 (18.1)","Stroke"="269 (4.4)","MI"="518 (8.4)","Heart failure"="283 (4.6)",
  "COPD"="152 (5.2)","Cancer"="624 (10.1)")
cat("\n==== Table 1 OVERALL: reproduced vs published ====\n")
cat(sprintf("%-26s %-22s %-22s\n","Characteristic","Reproduced","Published"))
for (nm in names(paper)) {
  rr <- tab[tab$Characteristic==nm, 2]
  cat(sprintf("%-26s %-22s %-22s\n", nm, ifelse(length(rr)==0,"-",rr), paper[[nm]]))
}
cat("\nSaved output/tables/table1_reproduced.{csv,html}\n")
