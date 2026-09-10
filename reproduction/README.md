# MASLD × BMI/WHtR — Reproduction (NHANES 2007–2018)

> **Scope note.** These materials document a teaching reproduction of published
> analyses using the specified public data and course implementation. Differences
> from published results are reproducibility findings, not allegations of research
> misconduct, and may reflect analytic, implementation, or data-version differences.
> The findings below stand as recorded; this note frames how to read them, not
> whether they hold.

Fully reproducible re-analysis of **Kueh MTW et al., BMJ Open 2026;16:e113719**
("Body weight categories and fat distribution in relation to all-cause mortality
among adults with MASLD"). Built as the worked **SPPH 604** example: replicate a
recent open-data paper end-to-end from raw public data, then interrogate it.

> **Result:** Table 1, Table 2, Figure 1 and Figure 2 all reproduce closely.
> See [`reproduction_report.md`](reproduction_report.md) for the side-by-side
> comparison and the P1–P5 teaching map.

**New here?** [WALKTHROUGH.md](WALKTHROUGH.md) is the tour: what each script
decides, the sample funnel, and the two places NHANES will mislead you. This file is the
reference.

## How to run

Requires R (≥ 4.4) with: `haven, dplyr, tidyr, readr, purrr, survival,
survminer, rms, ggplot2, patchwork, knitr, kableExtra, nhanesA`.

```r
source("R/run_all.R")     # builds everything; no paths to edit
```

The project root is detected automatically, so the folder can be unzipped
anywhere. If `data/raw/` is bundled (~204 MB of NHANES + mortality files), the
pipeline runs offline: `01_download.R` skips any file already present. If it is
not bundled, the first run downloads those files from CDC and subsequent runs
read from `data/raw/`.

## Folder layout

```
reproduction/
├── README.md                    <- this file
├── reproduction_report.md       <- reproduced vs published, findings, P1–P5 map
├── R/
│   ├── 00_setup.R               <- paths, cycles, component list
│   ├── 01_download.R            <- download raw NHANES + linked mortality
│   ├── 02_build_analytic.R      <- merge, FLI, MASLD, groups, mortality  (the core)
│   ├── 03_table1.R              <- Table 1 (baseline characteristics)
│   ├── 04_table2_cox.R          <- Table 2 (Cox regression)
│   ├── 05_figure1_km.R          <- Figure 1 (Kaplan–Meier)
│   ├── 06_figure2_rcs.R         <- Figure 2 (restricted cubic splines)
│   └── run_all.R                <- run everything in order
├── data/                        <- not in this repository; 01_download.R creates it
│   ├── raw/                     <- untouched downloads (saved for auditability)
│   │   ├── 2007-2008/ … 2017-2018/   (18 XPT components per cycle)
│   │   ├── mortality/           (6 public-use linked-mortality .dat files)
│   │   └── _download_manifest.csv    (URL / size / status of every file)
│   └── derived/
│       ├── masld_analytic.rds   <- the full analytic file (6,371 rows)
│       └── merged_all.rds       <- all-participant merged frame (pre-filter)
├── output/
│   ├── tables/  table1_reproduced.{csv,html}, table2_reproduced.csv
│   └── figures/ figure1_km.png, figure2_rcs.png
└── logs/                        <- run logs + sample_funnel.csv
```

## Data provenance

- **NHANES survey data:** `https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/<year>/DataFiles/<FILE>.xpt`
  (CDC/NCHS, public, no login). Every file's URL and byte size is recorded in
  `data/raw/_download_manifest.csv`.
- **Mortality:** NCHS Public-Use Linked Mortality Files, 2019 release
  (`ftp.cdc.gov/pub/Health_Statistics/NCHS/datalinkage/linked_mortality/`),
  follow-up censored 31 Dec 2019.

## Key definitions (see `02_build_analytic.R`)

- **Fatty Liver Index** (Bedogni 2006), steatosis = FLI ≥ 60.
- **MASLD** = steatosis + ≥ 1 cardiometabolic criterion (adiposity / glycaemia /
  blood pressure / triglycerides / HDL).
- **Groups** = obesity (BMI ≥ 30, Asian ≥ 25) × central adiposity (WHtR ≥ 0.6).
- **Outcomes** = all-cause and cardiovascular (diseases-of-heart) mortality.

## Caveats

- Analysis is **unweighted** (matches the paper; NHANES survey design not applied).
- **Two row sets, kept apart.** `masld_analytic.rds` is the **full analytic file**
  (6,371 rows): every adult with a computable FLI, whether or not they carry a valid
  fasting weight. The **locked domain** is its 6,048-row subset carrying a valid
  `WTSAF2YR`, and it is the only set on which a design-aware estimate is possible. The
  paper is unweighted, so 6,371 is what reproduces it; 6,048 is a different (correct)
  denominator, not a correction to the first. The typed sample funnel is in
  [WALKTHROUGH.md](WALKTHROUGH.md).
- The paper's stated alcohol exclusion does not reconcile with its reported N under any
  coding of the public alcohol variables we implemented; the primary cohort here matches
  the paper (exclusion off) and the exclusion is a documented switch. See report §5.
