# Walkthrough — how the reproduction is built

`README.md` next to this file is the reference: how to run it, what lives where, and the
caveats. **This page is the tour** — what each script decides, what it writes, and the two
places where NHANES will quietly give you the wrong answer.

Read it before you write P1. Your own paper will not be this one, but the shape of the work
is the same: rebuild the cohort, count what you lose at each step, then analyse.

---

## The whole thing in one command

```r
source("R/run_all.R")
```

The project root is detected automatically, so the folder can sit anywhere. Internet is
needed only by `01_download.R`, and only if `data/raw/` is not already populated.

Every step writes a log to `logs/`. When something disagrees with the paper, the log for
that step is the first place to look.

---

## The spine: the sample funnel

Cohort construction *is* the analysis in a replication like this one. Almost every
discrepancy you will chase traces back to a row here, so `02_build_analytic.R` writes it
out as a file — `logs/sample_funnel.csv`:

| Step | N | Type | Dropped |
|---|---:|---|---:|
| All NHANES 2007–2018 records | 59,842 | — | — |
| Age ≥ 18 | 36,580 | ELIGIBILITY | 23,262 |
| In fasting subsample | 14,962 | **DESIGN** | 21,618 |
| FLI computable (TG + GGT + BMI + waist) | 14,170 | **MISSINGNESS** | 792 |
| Steatosis (FLI ≥ 60) | 6,052 | **TARGET POPULATION** | 8,118 |
| MASLD (≥ 1 cardiometabolic criterion) | 6,050 | TARGET POPULATION | 2 |
| Phenotype group assignable | 6,050 | MISSINGNESS | 0 |
| Mortality-eligible and linked | **6,048** | OUTCOME ASCERTAINMENT | 2 |

**Every step carries a type label**, because a funnel shows N falling and does not show
*why* — and the reasons are not interchangeable. After eligibility, the two largest
reductions are the fasting subsample (DESIGN) and hepatic steatosis (TARGET POPULATION),
and **neither is missing data**. Genuine missingness is **792 item-nonresponse losses**,
and separately **2** records unlinked to mortality follow-up. Those are different problems:
they are not added together, and neither of them is 30,532, which is what reading every
post-age-eligibility reduction as attrition would give.

The fasting-subsample row is the one most often mistyped. Only a planned subset of
participants were ever asked to fast, and `WTSAF2YR` exists to account for that selection
stage and its nonresponse, so absence of fasting measures outside the subsample is a design
feature and is **not, by itself**, a missing-data problem. Item nonresponse *within* the
subsample is the separate thing, and it is 792 people. That is the first trap, below.

### Two row sets, kept apart

| Row set | N | What it is |
|---|---:|---|
| **Full analytic file** | **6,371** | the funnel above with the DESIGN row removed: every adult with a computable FLI, whether or not they carry a valid fasting weight |
| **Locked domain** | **6,048** | the funnel above as written, ending at records that carry a valid `WTSAF2YR` — the only set on which a design-aware estimate is possible |

These are the same two row sets the worked examples name. They differ by 323 records, and
the difference is not an error in either. The paper is unweighted, so the **full analytic
file is the one that reproduces it**: Table 1, Table 2 and the figures in `output/` are
built on 6,371 against the paper's approximately 6,300. Its own FLI step is the 14,989 that
`logs/sample_funnel.csv` records, and 14,989 exceeds the 14,962 adults in the fasting-weight
frame because 819 adults have all four FLI inputs without carrying a valid `WTSAF2YR`. The
locked domain is a different — and, for a design-aware estimate, the correct —
denominator, not a correction to the first.

**Getting 6,371 rather than the paper's number is not a failure** — it is the finding, and
tracing *why* the two differ is the skill being taught. An unexplained exact match is worth
less than a discrepancy you can account for.

One line of `logs/sample_funnel.csv` records a switch rather than a filter: `Alcohol
exclusion applied = FALSE` closes the file, and it is the reason the full analytic file
stays at 6,371 rather than dropping further. See the alcohol finding in
`reproduction_report.md`.

---

## Script by script

| Script | What it decides | What it writes |
|---|---|---|
| `00_setup.R` | Project root, the output folder paths, the six NHANES cycles, and the list of data components to download — shared constants only. It defines **no analysis switch**: `APPLY_ALCOHOL_EXCL` is defined in `02_build_analytic.R`, which is also where the funnel log records whether it was applied | nothing |
| `01_download.R` | Nothing analytic. Fetches raw NHANES cycles and the linked mortality files, untouched | `data/raw/<cycle>/`, `data/raw/mortality/`, and `_download_manifest.csv` recording URL, size and status per file |
| `02_build_analytic.R` | **Everything that matters.** Merges cycles, computes FLI → steatosis, separates the fasting-subsample step (DESIGN) from FLI item nonresponse (MISSINGNESS), applies the MASLD criteria, handles alcohol, assigns the four BMI/WHtR groups, links mortality, and marks the locked domain using `WTSAF2YR` | the analytic dataset and `logs/sample_funnel.csv` |
| `03_table1.R` | Baseline characteristics by group — mean (SD) for age, median (IQR) for skewed measures, n (%) for categorical; ANOVA / Kruskal–Wallis / chi-square | `output/tables/table1_reproduced.{csv,html}` |
| `04_table2_cox.R` | Cox models for all-cause and CV death, Group I as reference: unadjusted, Model 1, Model 2 | `output/tables/table2_reproduced.{csv,html}` |
| `05_figure1_km.R` | Kaplan–Meier by group, with number-at-risk and log-rank | `output/figures/figure1_km.png` |
| `06_figure2_rcs.R` | Restricted cubic splines (4 knots) for BMI and WHtR against probability of death | `output/figures/figure2_rcs.png` |

The definitions worth knowing before you read the code: **steatosis** is FLI ≥ 60;
**MASLD** is steatosis plus at least one cardiometabolic criterion; **obesity** is BMI ≥ 30
(≥ 25 for Asian participants); **central adiposity** is WHtR ≥ 0.6. Those four combine into
Groups I–IV.

---

## Two places NHANES will mislead you

Both of these are in `02_build_analytic.R`. Both cost real time to find. Neither is
specific to this paper — you will meet them again.

### 1. `WTSAF2YR` is a designed subsample, not missing data

Triglycerides come from the **fasting subsample**, which carries its own weight,
`WTSAF2YR`. Only a planned subset of participants were ever asked to fast, so those
missing values are *missing by design*.

This matters twice over. It fixes where the drop belongs in the funnel: the 21,618 people
lost at **In fasting subsample** were never sampled for the measurement, not lost to it,
and they are a different problem from the 792 lost at **FLI computable**, who were sampled
and still lack an input. Collapsing the two into a single "FLI computable" step is the
error the typed funnel above exists to prevent. And it changes how a design-aware analysis
has to be built: you construct the survey design on the **full frame** and then `subset()`
to the fasting sample. Filtering the data *before* building the design discards the
information the variance estimator needs, and the standard errors come out wrong.

This pipeline uses the variable for one thing only: separating those two funnel steps and
marking the locked domain. It never weights with it. **Doing something design-aware with it
is P4's job**, which is why P4 exists as a separate increment.

### 2. `ALQ130` has reserved codes, and is the wrong variable on its own

`ALQ130` is *drinks per drinking-day*, not consumption. Significant alcohol intake needs
**frequency × quantity** — `ALQ120Q` / `ALQ120U` combined with `ALQ130`. Using `ALQ130`
alone over-excludes roughly 2,000 people.

Worse, both variables use **777 and 999 as reserved codes** for "refused" and "don't know".
Leave them in and a refusal becomes someone reporting 777 drinks — reclassifying nine
refusals as heavy drinkers. They must be set to `NA` before any threshold rule is applied.
The code does this for both variables before combining them.

The general lesson: in NHANES, **check the codebook for reserved values before you compare
a variable to a number.** A silent misclassification of nine people is exactly the kind of
error a replication is supposed to catch.

---

## Why this pipeline is unweighted

`04_table2_cox.R` uses `coxph`, not `svycoxph`. There is no survey design object anywhere
in `03`–`06`.

That is deliberate: **this pipeline reproduces the paper's analysis, and the paper's
analysis is unweighted.** Reproducing a choice is not endorsing it. The design-aware
estimate is the *interrogation* half of the course, and it lands in P4 and M1 — where the
question becomes what the weighted answer is and whether it changes the conclusion.

Keep the two apart in your own work as well. Replicate first, faithfully, and only then say
what you would have done differently.

---

## When a number disagrees

In order:

1. **`logs/sample_funnel.csv`** — is the disagreement in the cohort, before any modelling?
   Most are.
2. **The step log in `logs/`** — each script writes one.
3. **`reproduction_report.md`** — what reproduced, what did not, and why, already written up
   for this paper.

Then write down what you found. A traced discrepancy is a result; a silent one is a bug.
