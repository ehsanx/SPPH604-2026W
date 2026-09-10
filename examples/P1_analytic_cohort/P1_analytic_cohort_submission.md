# P1 — Analytic Cohort (Lab 2)

*Model submission — demonstration paper (Kueh et al., BMJ Open 2026).*

## Study question

Among U.S. adults meeting FLI-based MASLD criteria, is central adiposity (WHtR) associated with all-cause mortality, and how robust is that association to how the analytic cohort is constructed?

> **Scientific (locked) estimand — IV vs III.** Among adults meeting FLI-based MASLD
> criteria, do **non-obese adults with high central adiposity** have higher all-cause
> mortality than **non-obese adults with low central adiposity**?
>
> **Replication estimand — IV vs I.** The paper references its contrasts to Group I (obese,
> low central adiposity). We reproduce that, because reproducing it is what *Replicate*
> means. Every increment and milestone states which of the two it is reporting.

## Source files and merge key

We assembled six NHANES cycles (2007–2008 through 2017–2018) from the public component files: demographics (`DEMO`), body measures (`BMX`), fasting biochemistry for triglycerides and glucose (`TRIGLY`/`GLU`), standard biochemistry for GGT and creatinine (`BIOPRO`), blood pressure (`BPX`), glycohaemoglobin (`GHB`), lipids (`HDL`/`LDL`/`TCHOL`), smoking (`SMQ`), alcohol (`ALQ`), physical activity (`PAQ`), and the medical-conditions and prescription-medication questionnaires (`MCQ`, `RXQ`). These were merged to the NCHS 2019 public-use linked mortality file. **All merges key on the respondent identifier `SEQN`**, one row per person per cycle, cycles stacked before selection. FLI is computed as `FLI = 100/(1+exp(−(0.953·ln(TG) + 0.139·BMI + 0.718·ln(GGT) + 0.053·waist − 15.745)))`.

## Eligibility decisions

1. **Adults only** — restrict to age ≥ 18 (`RIDAGEYR`). Unambiguous.
2. **Fasting subsample membership (DESIGN)** — fasting analytes are measured in a *designed* NHANES subsample, and `WTSAF2YR` exists to account for that selection stage and its nonresponse. This is not an eligibility choice we make, and it is not missing data.
3. **FLI computable (MISSINGNESS)** — among those already *in* that subsample, some still lack triglycerides, GGT, BMI or waist. That is item nonresponse: a different problem from step 2, and the only one of the two that a missing-data method could address.
4. **Steatosis** — FLI ≥ 60, the paper's stated cut.
5. **MASLD** — steatosis plus ≥ 1 of five cardiometabolic criteria (elevated BMI/waist, hyperglycaemia, hypertension, high triglycerides, low HDL). We coded the standard 2023 nomenclature set; only 2 people were lost here, so criterion wording is not load-bearing.
6. **Mortality-eligible** — retain records with a valid NCHS mortality linkage eligibility flag and non-missing follow-up time (censored 31 Dec 2019).
7. **Phenotype grouping** — the four groups partition on obesity and central adiposity (see BMI note below).

## Cohort funnel

**Every step carries a type label.** A funnel shows N falling; it does not show *why*, and the reasons are not interchangeable.

| Step | Criterion | N | Type | Dropped |
|---|---|---:|---|---:|
| 0 | NHANES 2007–2018 records | 59,842 | — | — |
| 1 | Age ≥ 18 | 36,580 | ELIGIBILITY | 23,262 |
| 2 | In fasting subsample | 14,962 | **DESIGN** | 21,618 |
| 3 | FLI computable (TG + GGT + BMI + waist) | 14,170 | **MISSINGNESS** | 792 |
| 4 | Steatosis (FLI ≥ 60) | 6,052 | **TARGET POPULATION** | 8,118 |
| 5 | MASLD (≥ 1 cardiometabolic criterion) | 6,050 | TARGET POPULATION | 2 |
| 6 | Phenotype group assignable | 6,050 | MISSINGNESS | 0 |
| 7 | Mortality-eligible and linked | **6,048** | OUTCOME ASCERTAINMENT | 2 |

After eligibility, the two largest drops are **Step 2 (design)** and **Step 4 (target population)**, and *neither is missing data*.


- Step 2 is the NHANES fasting subsample. It was **selected deliberately**, and `WTSAF2YR` exists to account for that selection stage and its nonresponse. The correct response is the right weight and a domain analysis (P4), not imputation.
- Step 4 is people without hepatic steatosis. They are not missing — they are **not who the paper is about**.
- **Item nonresponse: 792 people** — selected into the fasting subsample, still without a computable FLI. **Outcome ascertainment: 2 people** unlinked to mortality follow-up. These are different problems and we do not add them into a single "missing" total.

We separate these because collapsing them is the standard error here. Reading the funnel as "41% of adults have a computable FLI, so 59% are missing" merges a designed subsample with a disease definition and produces an apparent missing-data problem of about 29,700 people where the real one is 792 + 2. The 792 are a real item-nonresponse problem and they remain **an upstream issue we do not resolve**: they sit before the analytic cohort, so no within-cohort method reaches them. P5 interrogates a different and smaller thing — the **109 missing cancer values** among the Model-1 covariates *inside* the cohort. Both are genuine; only the second is tractable here.

Note also that our cohort is **6,048**, not the 6,371 the pipeline reports for the full analytic file: restricting to records with a valid fasting weight is what makes the design-aware analysis possible, and it is a different (correct) denominator.

## Reproduced group sizes

| Group (BMI / WHtR) | Ours | Paper |
|---|---|---|
| I — obese / low central (WHtR<0.6) | 391 | 386 |
| II — obese / high central (WHtR≥0.6) | 4,585 | 4,541 |
| III — non-obese / low central | 787 | 769 |
| IV — non-obese / high central | 608 | 604 |

All four groups reproduce within ~1%. Group IV (non-obese, high central adiposity) is the paper's headline "worst survival" phenotype; our all-cause death counts (5 / 389 / 74 / 118; total 586) likewise match the paper's (5 / 388 / 74 / 118; total 585).

## Documented ambiguity: alcohol operationalization

The paper's Methods state an exclusion of ">2 drinks/day (men), >1 (women)," but its reported N and deaths match **no effective exclusion**. We tested three defensible codings of the same sentence:

- **Crude `ALQ130` rule** (usual drinks on drinking days, applied flatly): removes **2,063** → N = 4,308.
- **Frequency-weighted average** (drinks/day = quantity × frequency ÷ reference period): removes **427** → N = 5,944.
- **No effective exclusion** (as the published counts imply): removes **0** → N = 6,371.

**One coding trap, worth its own line.** `ALQ130` uses NHANES reserved codes — **777**
("refused") and **999** ("don't know"). Applied to raw values, a rule like `ALQ130 > 2`
silently reclassifies every refusal as a heavy drinker; here that is nine people, and it
moves the crude-rule exclusion from 2,063 to 2,072. Reserved codes are not measurements.
Strip them before any threshold rule, in every increment.

The three codings span a >2,000-person range from one ambiguous sentence. We **did not tune the coding to hit the paper's N.** We adopted the no-exclusion path because it reproduces the published cohort and is the most transparent about the discrepancy, and we carry the alcohol question forward as a documented methods-vs-results inconsistency rather than a solved step.

## BMI cut-point finding

The paper's Table headers label the non-obese groups "BMI < 25." That is inconsistent with the data: the non-obese groups have BMI **medians of 27.6 (III) and 28.8 (IV)** — impossible under a 25 cut. The Methods text uses BMI ≥ 30 for obesity, and **coding the split at 30 reproduces the group sizes above**. We conclude the "< 25" headers are inconsistent with the analysis as run, and that the operative threshold is 30.

## Honest account of the residual N gap

We reproduce 6,371 on the full analytic file where the paper reports **6,300**, and lock **6,048** as the analysis domain (those with a valid fasting weight). Completeness on the paper's Model-1 covariates is reported in P5, which is where it is analysed; an earlier draft quoted a 6,246 figure from an expanded covariate set that Model 1 does not contain, and that figure is withdrawn.

## Reproducibility notes

Analysis in R; cycles stacked and merged on `SEQN` in a single deterministic script. FLI coefficients are hard-coded from the source formula. Every funnel row is emitted by the script so counts are re-derivable end to end, and the three alcohol codings toggle from one parameter. Group definitions use BMI ≥ 30 and WHtR ≥ 0.60.
