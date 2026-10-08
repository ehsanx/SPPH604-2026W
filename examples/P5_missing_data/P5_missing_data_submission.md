# P5 — Missing Data (Lab 6)

*Model submission — demonstration paper (Kueh et al., BMJ Open 2026;16:e113719).
The numbers below are typed, copied from the rendered output of `P5_code.qmd`
(`P5_code.html`) unless a line names another source, so they must be re-copied whenever
the code is re-run. The approximate income and blood-pressure figures in the section on a
sensitivity analysis we did not run are stated in `P5_code.qmd` but not computed there.*

## Three kinds of downward step, and only one of them is missing data

A cohort funnel shows N falling. It does not show *why*, and the reasons carry
completely different inferential meanings. Sorting the demonstration paper's funnel
into three bins was the most useful thing we did this week:

| step | n | weighted | kind |
|---|---:|---:|---|
| fasting subsample frame | 17,208 | 260,290,473 | **DESIGN** — `WTSAF2YR` handles it |
| adults 18+ | 14,962 | 234,756,163 | eligibility (definitional) |
| FLI computable | 14,170 | 224,125,729 | **MISSINGNESS** — item nonresponse |
| steatosis, FLI ≥ 60 | 6,052 | 94,418,570 | **DISEASE** — target population |
| MASLD, linked, group known | 6,048 | 94,334,495 | disease + small missingness |

**Design.** Fasting measures come from a *designed* NHANES subsample. Their absence
outside it is not missing data — it is the reason `WTSAF2YR` exists. Inference remains
conditional on the weighting assumptions, but this is not an MNAR problem.

**Disease.** The largest single drop, 14,170 → 6,052, is people who do not have
steatosis. They are not missing. They are not in the target population.

**Missingness.** Only the FLI-computability step is item nonresponse: **5.3%** of
adults in the fasting frame.

We flag this because the obvious reading of the funnel — "59% of adults never get an
FLI, so the cohort is a selected 41%" — merges all three bins into one number and then
calls it MNAR. It is not one number and it is not MNAR.

## The missingness pattern, before choosing a method

Using **the paper's Model 1 covariates and nothing else**:

| variable | missing | unweighted | weighted |
|---|---:|---:|---:|
| `cancer` | 109 | 1.80% | 1.18% |

**One** of eleven Model-1 variables carries any missingness. Complete cases:
**5,939 of 6,048**. There is no overlap structure to examine because there is nothing
to overlap with.

## Estimand

> **Scientific (locked) estimand:** the weighted, Model-1-adjusted hazard ratio for
> **Group IV versus Group III**, in the MASLD domain of the NHANES fasting subsample,
> 2007–2018.
>
> **Replication estimand:** the same quantity against **Group I**, the paper's reference.
>
> Both are reported below, locked contrast first.

Stated before any comparison, because complete-case and imputation can silently target
different populations — and a difference between them would then be evidence about
populations, not about missing data.

## Complete case versus multiple imputation

Imputation is survey-aware: impute, rebuild the design, subset the domain, fit, pool
across ten completions. The outcome enters as the event indicator plus a Nelson–Aalen
cumulative-hazard term.

### Locked estimand — IV vs III, weighted Model 1

| | Group IV vs III HR (95% CI) | n |
|---|---|---:|
| complete case | **1.29 (0.89–1.86)** | 5,939 |
| all 109 assigned **no cancer** | 1.28 (0.89–1.85) | 6,048 |
| all 109 assigned **cancer** | 1.28 (0.89–1.85) | 6,048 |
| MI (m = 10) | **1.28 (0.89–1.85)** | 6,048 |

Complete case gives **1.29 (0.89–1.86)**; both extreme assignments and MI give **1.28
(0.89–1.85)**, a difference of 0.01, far smaller than the interval. On the contrast the
term is built around, the residual missingness does not change the estimate in any
meaningful way, and the interval includes 1 throughout.

### Replication estimand — IV vs I, weighted Model 1

The only incomplete Model-1 variable is **binary**, which permits a sensitivity
analysis a reader can check by eye before any model is fitted: assign all 109 missing
values to one extreme, then the other.

| | Group IV HR (95% CI) | n |
|---|---|---:|
| weighted, complete case | **2.98 (0.69–12.82)** | 5,939 |
| weighted, all 109 assigned **no cancer** | 2.99 (0.69–12.89) | 6,048 |
| weighted, all 109 assigned **cancer** | 2.99 (0.69–12.90) | 6,048 |
| weighted, MI (m = 10) | **2.99 (0.69–12.89)** | 6,048 |
| *unweighted, complete case* | *3.81 (1.39–10.43)* | *5,939* |

Every weighted approach lands between **2.98 and 2.99** — a total range of **0.01** on
the hazard ratio. The extremes are a transparent stress test, not formal bounds: they do
not identify the missing values, they show what happens under two transparent global
scenarios. Uniform assignments do not necessarily maximise or minimise the exposure
coefficient, so this bounds nothing — it stress-tests.

Difference between complete case and MI: **0.012**. The pooled fraction of missing
information prints as 0%, but that is *approximately* zero at the displayed precision,
not literally zero — the between-imputation variance of the Group IV log-HR is
3.3e-11. The imputed values genuinely differ between completions; they have almost
no leverage on the coefficient.

## What this shows

> Within the locked domain — the 6,048 rows P5 analyses — only 1.8% of records are
> incomplete on the paper's Model-1 covariates, entirely because of missing cancer
> status. Complete-case analysis, extreme-value stress tests, and pragmatic multiple
> imputation yield materially similar estimates. In this dataset, handling this residual
> missingness does not alter the substantive inference; accounting for the complex survey
> design has substantially greater impact.

Two things that sentence is careful **not** to say. It does not say missingness is
generally unimportant — it says it is numerically negligible *here*. And it does not
say survey design is the paper's dominant threat; it says design mattered more than
missingness **among the analyses run in P4 and P5**. Which threat most endangers the
paper's conclusion needs all five increments, and that judgment belongs to M1.

**Methodological importance is measured, not presumed.** A sensitivity analysis whose
answer is "no material change" is a result, not a failure.

**On the paper's contrast, what moves the conclusion is the design, not the missing
data.** Compare the two complete-case rows of the IV-vs-I table (Model 1, 5,939 rows):
unweighted, the interval excludes 1; weighted to the population, it does not. On the
locked IV-vs-III contrast neither interval excludes 1 (1.05 (0.77–1.45) unweighted, in
P4; 1.29 (0.89–1.86) weighted), so there the design moves the point estimate but not the
conclusion. The unweighted intervals are valid for the sample-conditional question; the
weighted ones answer the population question. Imputing 1.8% of one covariate does not
change what can be claimed on either contrast.

## A sensitivity analysis we deliberately did not run

Adding income (PIR, ~9% missing) and systolic blood pressure would push complete-case
loss to roughly 13% and make this exercise look substantial. **Neither is in the
paper's Model 1.** Adding variables until a missing-data problem appears changes the
adjustment set and answers a different question — it is an adjustment-set change
wearing a disguise. If those variables are wanted, they belong in a separately
labelled sensitivity model with its own stated estimand, not inside this comparison.

## Who this estimate is about

Adults with MASLD in the NHANES fasting subsample, 2007–2018, for whom a Fatty Liver
Index can be computed. `WTSAF2YR` carries the estimate to the fasting-sampled population;
the steatosis and cardiometabolic criteria are the target population rather than a loss;
and the 5.3% item nonresponse on the FLI inputs narrows it further, with no weight
accounting for that step. Stating this is not a hedge — it is the population the locked
estimate (1.29, complete case) belongs to.

## Limitations

- The 5.3% FLI item nonresponse is upstream of this analysis and is not addressed
  here; characterising who lacks a computable FLI, against the demographic and
  examination data NHANES retains on them, is the natural next step.
- MI assumes MAR given the Model-1 covariates and the outcome. With 1.18% weighted
  loss on a single binary covariate, that assumption is doing very little work — which
  is precisely why the result is uninformative about it.
- The imputation is **not fully survey-modelled**. The sampling weight and stratum are
  entered as predictors and the design is reintroduced when each completed dataset is
  refitted; a fully design-aware imputation would model the sampling structure inside
  the imputation itself. We did not fit that fuller model. What `P5_code.qmd` does show
  is that the imputed cancer values have almost no leverage on the Group IV coefficient
  (between-imputation variance 3.3e-11), so how the design enters the imputation model
  can make little difference here. Immaterial here; not a general licence.
