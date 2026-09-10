# Week 7 Lecture Plan — Missing Data: What Multiple Imputation Can and Cannot Fix

Duration: ~2.5 h (Tue, before the Thu lab)

## Learning objectives
- Classify missingness using the MCAR / MAR / MNAR taxonomy and state why the mechanism, not the amount, governs bias.
- Separate the kinds of loss before naming any of it missing data, using all five types — **design**, **eligibility**, **target population**, **outcome ascertainment**, **missingness** — and apply MCAR / MAR / MNAR to the missingness only, because it is the only loss P5 addresses with the methods this course teaches.
- Contrast complete-case, a model-free extreme-value stress test, and multiple imputation on the MASLD cohort, and read the result honestly on the **replication contrast (IV vs I), design-aware Model 1**: **2.97 → 2.98**, a hazard ratio moving in the third significant figure. On the **locked scientific contrast (IV vs III)** the same sensitivity analysis never leaves **1.29**.
- Specify a defensible imputation model: which variables enter, how many imputations, and Rubin's rules for pooling.
- Judge what MI can repair (MAR item-missingness) and what it cannot (structurally unobserved exposure) — and how to report each honestly.

## Continuity
- Last week (Wk6, L5) we made the estimate design-aware: NHANES weights + strata + PSU, which attenuated Group IV from the naive ~15 toward ~12.4. Weighting fixed *representation*; it did not fill in *missing values*.
- Today we confront the values that are simply absent, and separate a problem MI can help with from one it cannot. This is the last interrogation method before we shift from "find the flaws" to critique (M2, Wk9) and improvement (defended at M3, Wk11).
- Today sets up L6 (missingness pattern -> MI -> design-adjusted refit) and P5, each student's own missing-data sensitivity analysis on their locked paper.

## Slide 1 — Where we are in the project
- Recap the arc: Replicate + Interrogate (survey design last week, missing data this week) -> M1 compiles all five, presented next Tue (Oct 27) -> Critique another group's M1 (M2, Wk9) -> Improve and defend (M3, Wk11).
- Position missing data as the fifth and final threat lens before M1 compiles all five.
- Flag that today's method interacts with everything prior: you impute, THEN weight, THEN refit.
- MASLD hook: the paper reports approximately 6,300; the reproduction's **full analytic file** is 6,371 and its **locked domain** is 6,048. Hold those two numbers — where did the other adults go?
- (~6 min)

## Slide 2 — Why missingness is a bias problem, not a bookkeeping problem
- Dropping incomplete rows silently changes *who* is in your analysis; the estimand can shift even if nothing is mis-measured.
- The amount missing bounds power; the *mechanism* determines bias. 5% MNAR can mislead more than 30% MCAR.
- Preview the punchline: the same paper has one loss MI handles well — item nonresponse inside the cohort — and one it cannot touch, because that one is **design**, not missing data at all.
- MASLD hook: the paper counts 585 all-cause deaths and our reproduction 586, and those deaths drive the survival estimates — if the missing are systematically higher- or lower-risk, every HR moves.
- (~9 min)

## Slide 3 — The taxonomy: MCAR / MAR / MNAR
- MCAR: missingness independent of everything — complete cases are a random subsample, unbiased but wasteful.
- MAR: missingness explained by *observed* data — recoverable by conditioning/imputing on those observables.
- MNAR: missingness depends on the *unobserved value itself* — not fixable from the data alone; needs assumptions or external information.
- Stress these are untestable from the data: you argue the mechanism substantively, then do sensitivity analysis.
- MASLD hook: which label fits the **792 adults inside the fasting subsample who still have no computable FLI**? That is the genuine missing-data question. Those never sampled into the subsample are a different question entirely.
- (~12 min)

## Slide 4 — A picture of the taxonomy
- Simple 3-panel schematic: missingness arrow pointing from (nothing) / (observed X) / (the value itself) to the "missing" indicator.
- Give the one diagnostic you CAN do: compare observed characteristics of complete vs. incomplete cases (rules MCAR less plausible, cannot confirm MAR vs MNAR).
- Note complete-case analysis is unbiased only under MCAR (or, for some estimands, MAR in covariates but not outcome-dependent).
- MASLD hook: complete-case vs. imputed contrast (Slide 10) is exactly this diagnostic run live.
- (~9 min)

## Slide 5 — Classify first: which reductions are actually missing data?
- FLI needs triglycerides + GGT + BMI + waist; only triglycerides comes from the NHANES *fasting* subsample (GGT is MEC-wide standard biochemistry, BMI and waist are anthropometry) — that single fasting input binds the whole index.
- In the MASLD funnel, **after eligibility**, the two largest reductions are **designed subsampling** and **disease definition**. Neither is missing data. Genuine missingness across the whole funnel is **792 item-nonresponse losses**; a further **2 records fail outcome ascertainment**, which is a separate category, not missingness, and is not added to them. Within the locked domain, Model-1 missingness is **1.8%**, all of it cancer status.
- This is selection *into observability of the exposure*, upstream of any confounder adjustment.
- MASLD hook: this is why N collapses from all NHANES adults to the **full analytic file** (6,371) and the **locked domain** (6,048); the phenotype simply cannot be assigned to most people.
- (~11 min)

## Slide 6 — Why designed subsampling is not MNAR
- Fasting status is not random: it tracks appointment time, diabetes, medication, age — variables tied to metabolic risk, the very thing MASLD is about.
- NHANES *designed* the fasting subsample and supplies `WTSAF2YR` to account for that selection stage and its nonresponse. Absence there is **not, by itself**, evidence of MNAR. Inference stays conditional on the weighting assumptions — which is a much narrower claim than "unfixable selection bias".
- Key teaching move: MI cannot invent a measurement that was never taken — but that is an argument for using the **right weight**, not for declaring the study irreparable.
- The honest fix is scope language ("among adults with ascertainable MASLD") plus a selection/sensitivity argument — not imputation.
- MASLD hook: connect back to M1's circularity finding — the fasting filter and the phenotype share BMI+waist inputs, so selection and exposure definition are entangled.
- (~12 min)

## Slide 7 — Break
- 10-minute break. On return we move from the loss MI cannot repair — design, which the weight answers — to the one it can.
- (~10 min)

## Slide 8 — Item nonresponse *inside* the cohort
- Within the **locked domain** — the 6,048 rows P5 analyses — confounders are only partly complete: income ~9% missing, blood pressure ~3% — but neither is in the paper's Model 1. Inside Model 1, exactly one covariate is incomplete: cancer status, 109 rows, 1.8%.
- These are classic item-missing covariates — the setting MI was designed for, and plausibly MAR given the rich NHANES covariate set.
- Contrast with the design and disease steps: here the *rows exist and the outcome/exposure are observed*; only some predictors are blank.
- MASLD hook: on the paper's Model 1, complete-case analysis quietly drops 1.8% of the cohort — 109 people, for a blank cancer-status field, not anything about liver fat. (Adding income and BP would make it ~12.8%, but that changes the adjustment set.)
- (~9 min)

## Slide 9 — Complete-case analysis: the hidden default
- Most regression software listwise-deletes; the analyst rarely chooses it consciously.
- Costs: lost precision, and bias whenever missingness in a covariate is associated with the outcome.
- It is defensible only under MCAR — or MAR in covariates, not outcome-dependent — assumptions you usually cannot justify.
- MASLD hook: the paper's adjusted Group IV HR reflects whoever survived listwise deletion — an unstated subsample.
- (~8 min)

## Slide 10 — Multiple imputation: the idea in three steps
- Impute: draw M plausible completed datasets from a model predicting each missing value from the observed ones (incl. the outcome).
- Analyze: fit the SAME substantive model in each dataset.
- Pool: combine estimates with Rubin's rules — within- + between-imputation variance carries the uncertainty of not knowing the true value.
- MASLD hook: run the **replication contrast (IV vs I), design-aware Model 1** — complete-case **2.97**, both extreme assignments of the missing cancer status **2.98 / 2.99**, MI **2.98**. Everything lands inside a 0.02 band.
- (~13 min)

## Slide 11 — Reading a sensitivity analysis that changes nothing
- Interpret: complete cases were a slightly higher-risk slice; restoring the dropped 1.8% removes that selection if MAR holds — there is no observed truth here to check it against.
- Emphasize what MI actually did: 2.97 -> 2.98, with an interval that came back marginally *wider*, not narrower. The imputed values have almost no leverage (between-imputation variance ~7.6e-12).
- Caution: MI changes the estimate only as much as the missing predictors matter; a null move is also a finding.
- **The wording that matters:** *this* missing-data problem mattered little **after we measured it**. The method was necessary because we did not know that in advance. "Missing data don't matter" is the wrong lesson.
- (~9 min)

## Slide 12 — Building a defensible imputation model
- Include the outcome (here: the Nelson-Aalen cumulative hazard + event indicator for survival data) — omitting it biases associations toward null.
- Be inclusive: put all analysis-model covariates plus useful auxiliary predictors of missingness into the imputation model (congeniality).
- Match variable types (logistic/PMM for skewed or bounded vars); respect the survey design where feasible.
- MASLD hook: income and BP should be imputed from age, sex, BMI, waist, comorbidity AND the mortality outcome — not from a stripped-down model.
- (~11 min)

## Slide 13 — How many imputations, and how to report
- Rule of thumb: M at least equal to the percentage of incomplete cases (so ~10-20 here); more is cheap insurance, few is false precision.
- Report: mechanism assumed, variables imputed, M, software/method, and the pooled estimate with Rubin SEs.
- Always show complete-case vs. MI side by side — divergence is a sensitivity signal, agreement is reassurance.
- MASLD hook: a small table on the **replication contrast (IV vs I), design-aware Model 1** (complete-case 2.97 / stress test 2.98–2.99 / MI 2.98) is the P5 deliverable in miniature — and note that the **survey design** moved the same estimate far more than the missingness did.
- (~9 min)

## Slide 14 — What MI fixes vs. what it cannot
- What a missing-data method can address: item-missing confounders inside the cohort
- Not a missing-data problem at all: the people NHANES never sampled into the fasting subsample. That is scope, addressed by the correct weight and an honest statement of the target population.
- Corollary: MNAR item-missingness also needs sensitivity analysis (e.g., delta-adjustment), not naive MI.
- Link back to the gate: the categories MI cannot reach are the categories M0 criterion 6 does not accept on their own.
- MASLD hook: the external-validity ceiling is a **scope** statement about the fasting subsample, fixed by the correct weight and an honest target-population sentence — not something imputation was ever going to reach.
- (~10 min)

## Slide 15 — Putting the interrogation together
- Sequence for a design-aware, missingness-aware refit: impute the item-missing covariates -> apply the Wk6 weights, strata and PSU -> fit the substantive model in each imputed dataset -> pool with Rubin's rules.
- Each threat we studied moves the Group IV estimate a defensible direction; report the *stack*, not one number.
- Transition line: next week (M1) students compile all five lenses into their replication deck and name the dominant threat — today gives them the missing-data piece.
- MASLD hook: put the four headline numbers side by side — 15.1 naive, ~2.9 adjusted, ~12.4 weighted-crude, 2.98 imputed — and show they are *not* a sequence (different models, different row sets). Then use P4's 2x2 on the fixed 5,939 rows to separate adjustment from design; there, adjustment moves it most and imputation least.
- (~9 min)

## Slide 16 — Bridge to today's lab (L6) and P5
- In L6 (EpiMethods missing-data module) students will: (1) tabulate the missingness pattern for the fixed dataset and name the likely mechanism per variable; (2) run MI with a properly specified model and a justified M; (3) refit the survival model with Rubin pooling, then re-apply the Wk6 survey design, and report complete-case vs. MI vs. design-adjusted side by side.
- They will practice telling design apart from missingness explicitly: which gaps MI addresses, and which are scope limits to be written up, not imputed.
~8 min. P5 is optional and folds into the M1 package. The deliverable is the typed funnel, a small complete-case / stress-test / MI table, and one sentence naming the population the conclusion is about.
- MASLD hook: the demonstration paper reports one HR from an unstated subsample; P5 asks students to show their paper's number under missingness stress and to name its true validity ceiling.
- (~8 min)
