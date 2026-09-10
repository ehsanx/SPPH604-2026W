# P4 — Design-Aware Main Estimate (Lab 5)

*Model submission — demonstration paper (Kueh et al., BMJ Open 2026).*

> **Estimand convention, used identically in every increment.**
>
> - **Scientific (locked) estimand — IV vs III.** Non-obese with high central adiposity
>   against non-obese with low central adiposity. This isolates central adiposity with
>   body-mass category held fixed, and it is the question the term is built on.
> - **Replication estimand — IV vs I.** The paper's own parameterization, kept because
>   reproducing it is what *Replicate* means.
>
> Both are contrasts within one fitted model. Every estimate below states which it is.

## The estimand, stated before the model

We fix the target of inference first, because "the association" is under-specified until we name a population. Our contrast is the all-cause mortality hazard of phenotype **Group IV** (non-obese by BMI, high central adiposity WHtR≥0.6) relative to **Group I** (obese, low central adiposity), among adults who meet FLI-based MASLD criteria, over follow-up censored 31 December 2019 (median 6.7 years). The measure is a hazard ratio.

The design question is *which* population that HR describes. The paper's unweighted Cox model estimates a **sample-conditional** association inside the 6,371 people who happened to be sampled. But NHANES is a stratified, clustered, unequal-probability survey; without weights the estimate is not a statement about US adults with MASLD. Making the estimand *population-average* — the target-of-inference we think the paper actually wants — requires the survey machinery. So P4 is not "add weights and see if the number moves." It is a change of estimand, and we report both because both are legitimate answers to *different* questions.

## Replicate: the unweighted Cox model

We first reproduce the paper's Table 2 on the full cohort (n=6,371; 586 all-cause deaths), Group I as reference. Group IV is the headline "worst survival" phenotype:

| Model | Group II | Group III | **Group IV** |
|---|---|---|---|
| Unadjusted | 6.68 (2.76–16.14) | 6.23 (2.52–15.41) | **15.14 (6.19–37.04)** |
| Model 1 (clinical) | 2.50 (1.03–6.09) | 3.23 (1.30–8.01) | **3.28 (1.33–8.11)** |
| Model 2 (+ smoking, sedentary) | 2.37 (0.97–5.76) | 2.99 (1.20–7.43) | **2.91 (1.18–7.20)** |

These match the publication to rounding (paper IV: 15.13 unadjusted, 2.89 in Model 2). The replication is clean: the fifteen-fold crude hazard collapses to roughly three-fold once age and cardiometabolic burden are adjusted — most of the crude signal is confounding by who lands in each phenotype — but Group IV remains the worst group and its Model-2 confidence interval still excludes 1.

## Improve: a design-aware estimate

The analytic cohort is the NHANES **fasting subsample**, because the FLI needs fasting triglycerides. The correct weight is therefore the pooled fasting-subsample weight, WTSAF2YR divided by 6 (six two-year cycles), with SDMVSTRA strata and SDMVPSU clusters. Valid weights exist for **n=6,048 across 184 clusters**. On that same subset the unweighted IV HR is 16.96 (slightly higher than the full-cohort 15.14 — the weight-eligible subset is not identical to the full cohort, which itself matters).

Survey-weighted, all-cause, Group I reference:

| Group | Weighted HR (95% CI) |
|---|---|
| II | 5.38 (1.19–24.39) |
| III | 4.04 (0.89–18.34) |
| **IV** | **12.40 (2.69–57.15)** |

Because Group I is a tiny, low-event reference (n=391, 5 deaths), the vs-I contrasts are unstable in either weighting scheme. So we also estimate **weighted direct contrasts** against the other high-risk groups, which is the comparison a clinician actually cares about:

- **IV vs III: 3.07 (2.11–4.46)** — non-obese/high-central vs non-obese/low-central
- **IV vs II: 2.30 (1.76–3.02)** — non-obese/high-central vs obese/low-central

*Those three are **crude** survey-weighted estimates. The adjusted versions, and the
comparison that separates adjustment from design, are in the matrix below.*

## The matrix that separates adjustment from design

The running ledger of `15.1 → 2.9 → 12.4` mixes crude and adjusted models on different
row sets, so it is not a sequence of successive corrections and should not be read as
one. To separate **adjustment** from **survey design** the rows must be held fixed.

All four cells below use the **same 5,939 Model-1 complete-case rows** inside the locked
domain.

| | IV vs I *(replication)* | IV vs III *(locked)* |
|---|---|---|
| unweighted, crude | 16.05 (5.91–43.58) | 2.34 (1.72–3.18) |
| unweighted, Model 1 | 3.79 (1.38–10.39) | 1.06 (0.77–1.45) |
| weighted, crude | 11.93 (2.60–54.84) | 3.07 (2.11–4.48) |
| **weighted, Model 1** | **2.97 (0.69–12.79)** | **1.29 (0.90–1.86)** |

Read down a column for what **adjustment** does; read across a row for what **design**
does.

- **On the locked estimand, adjustment dominates design.** Adjustment moves 2.34 to 1.06
  unweighted and 3.07 to 1.29 weighted. Design moves 2.34 to 3.07 crude and 1.06 to 1.29
  adjusted — in the *opposite* direction, and by less.
- **Design changes no conclusion on the locked estimand.** Both adjusted intervals include
  1 (0.77–1.45 and 0.90–1.86).
- **Design does change the conclusion on the replication estimand.** Unweighted Model 1 is
  3.79 (1.38–10.39), excluding 1; weighted Model 1 is 2.97 (0.69–12.79), which does not.
- So "survey design matters" is true **of the paper's own contrast**, and much weaker for
  the question we locked. Anyone ranking design as the dominant threat has to say which
  estimand they mean.



## Interpretation

Two things happen when we move from sample-conditional to population-average. First, the point estimate **attenuates** (IV 16.96 → 12.40): weighting changes how much each respondent contributes according to the sampling design, so representative estimation pulls the number down. Second, the confidence intervals **widen** (IV upper bound 37 → 57). That widening is the **widening of the survey-aware interval** — clustering within 184 PSUs and unequal weights reduce the *effective* sample size below the nominal 6,048, so the honest CI is wider than the unweighted one pretends. The unweighted model was over-confident, not more precise.

**What the matrix actually supports.** For the **locked IV-vs-III** estimand, adjustment is consequential and survey weighting changes the point estimate modestly (1.06 → 1.29) *without* altering the inferential conclusion — both adjusted intervals include 1, so there is **no clear evidence of a higher hazard at the available precision**. For the **replication IV-vs-I** estimand, weighting materially changes the uncertainty and whether the interval excludes 1 (3.79, 1.38–10.39 becomes 2.97, 0.69–12.79). Group IV having the largest point estimate describes an *ordering*; it does not establish that central adiposity carries excess mortality among non-obese adults after adjustment.

## Which weight: a rule, not a judgment call

An earlier draft of this submission called the weight choice "a genuine puzzle we cannot fully resolve" and argued the MEC weight was equally defensible. **That was wrong, and we withdraw it.**

CDC's guidance is the **least common denominator rule**: when an analysis draws on variables measured in different components, use the weight belonging to the **smallest** applicable subsample. FLI requires fasting triglycerides, so `WTSAF2YR` governs — even though GGT and anthropometry are available MEC-wide. The rule exists precisely because analyses routinely straddle frames; it is not a tie to be broken by argument.

The MEC weight is not a defensible alternative here: it would weight to a population in which the exposure cannot be constructed at all. There is no sensitivity axis to carry into M2 on this point.
