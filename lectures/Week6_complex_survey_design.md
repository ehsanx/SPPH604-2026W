# Week 6 Lecture Plan — Complex Survey Analysis: Why NHANES Is Not a Simple Random Sample

Duration: 2.5 h = 150 min (Tue, before the Thu lab).

Timing: the Slide 1–16 markers below sum to **147** — 142 min of content plus the 5-minute break at Slide 9 — leaving **3 min of float** in the session. The deck (`slides/Week6_survey_slides.qmd`) spends that float on its opening Continuity recap, which this plan does not separately budget. **Slide 15** (pitfalls checklist, 6 min) recaps material already covered and is the designated cut if the mechanics slides 4–8 run long.

## Learning objectives
- Explain why NHANES is a stratified, multistage, clustered probability sample — not a simple random sample — and why that breaks default standard errors.
- Identify the three design objects every NHANES analysis needs: weights (WTINT / WTMEC / WTSAF), strata (SDMVSTRA), and PSU (SDMVPSU).
- Choose and pool the correct weight when combining survey cycles, and state what design effects do to confidence intervals.
- Contrast the MASLD paper's unweighted estimates with design-aware ones, and articulate why unweighted was a *choice*.
- Reason about the fasting-vs-non-fasting weight puzzle that MASLD's own analyte mix creates.

## Continuity
- Recap Wk5: the targeted IV-vs-III × sex test gave a ratio of HRs of 1.00 (0.42–2.35) — underpowered rather than resolved. Today: the **weight follows the measurement subsample** (CDC's least-common-denominator rule), and **domain analysis** preserves the parent design — build the design, then `subset()`.
- Today: a different threat entirely — not confounding or modification, but whose *population* the numbers describe. The paper analyzed NHANES as if it were a simple random sample.
- Sets up L5 (naive vs survey-weighted estimation) and P4, your first design-aware re-estimate of your own paper.

## Slide 1 — Where we are in the project (5 min)
- Timeline recap: Replicate → Interrogate → Improve → Defend. M1 is Wk8; **M2 (Wk9) is your critique of another group's M1**; M3 (Wk11) is your individual defense.
- P1 eligibility, P2 Table 1, P3 effect modification are done — all built on an *unweighted* analytic file.
- Today we question a design assumption baked into every number so far.
- MASLD hook: the paper reports HRs to two decimals but does not name the survey design.

## Slide 2 — The motivating puzzle (8 min)
- Show the paper's Group IV all-cause HR ~15.1 (unadjusted). Ask: 15.1 *for whom* — the sample, or US adults with MASLD?
- The gap between "sample" and "population" is exactly what survey design bridges.
- Preview the punchline: design-aware weighting attenuates Group IV toward ~12.4 and widens the CI.
- MASLD hook: the paper's inference target is implicitly the US population, but its math is the sample's.

## Slide 3 — What "simple random sample" assumes (10 min)
- SRS: every person independently, equally likely to be drawn; default SEs assume this.
- Two violations coming: unequal selection probabilities (weights) and non-independence (clustering).
- Consequence of ignoring them: point estimates biased toward the sample composition; SEs usually too *small*.
- MASLD hook: default `coxph` SEs in the replication silently assume SRS.

## Slide 4 — How NHANES is actually built (12 min)
- Multistage: (1) counties (PSUs), (2) segments, (3) households, (4) persons — selection at each stage.
- Stratified first by design domain; oversampling of targeted subgroups (e.g., older adults, some race/ethnicity groups, low income).
- Result: neither equal probabilities nor independent draws — the two SRS assumptions both fail by design.
- MASLD hook: MASLD adults are not spread randomly across PSUs; they cluster with the households sampled.

## Slide 5 — Weights: WTINT, WTMEC, WTSAF (12 min)
- A weight ~ how many people in the target population this respondent represents (inverse selection probability, adjusted for nonresponse and post-stratification).
- Three tiers by how far into the exam a variable lives: WTINT (interview) ⊇ WTMEC (mobile exam) ⊇ WTSAF (fasting subsample).
- Rule: use the weight for the *most restrictive* data source your analysis actually requires.
- MASLD hook: FLI needs triglycerides (a fasting analyte) -> the honest weight is WTSAF, the smallest, most-adjusted one.

## Slide 6 — Strata and PSUs: SDMVSTRA, SDMVPSU (10 min)
- SDMVSTRA encodes the design strata; SDMVPSU encodes the (masked) primary sampling units within a stratum.
- These drive *variance*, not the point estimate: clustering means neighbors resemble each other, so effective sample size < N.
- Analytic strata/PSU are pseudo-values released for disclosure control — use as provided, never re-derive.
- MASLD hook: none of SDMVSTRA / SDMVPSU appear anywhere in the paper's methods.

## Slide 7 — Pooling weights across cycles (10 min)
- NHANES 2007–2018 = six 2-year cycles; the paper stacks them.
- Weights are built per cycle -> you must divide by the number of cycles pooled (here /6) so the weighted total isn't multiplied.
- Use the survey-cycle-appropriate weight variable and pool consistently; strata/PSU are pooled as-is.
- MASLD hook: with six cycles combined, the correct pooled fasting weight is WTSAF/6, a step easy to miss.

## Slide 8 — The design effect (10 min)
- DEFF ~ variance under the real design ÷ variance under SRS; typically > 1 because of clustering + weighting.
- Practical read: when DEFF > 1, your *effective* N is smaller than your row count; honest CIs get wider.
- "N = 6,300" overstates the information content once design is respected.
- MASLD hook: the paper's tight CIs partly reflect pretending each of ~6,300 rows is an independent draw.

## Slide 9 — Short break (5 min)
- Stretch. Coming up: what happens to the MASLD numbers when we do it right, and the fasting-weight puzzle.

## Slide 10 — "Unweighted" is a choice, not a default (10 min)
- Some analysts argue for unweighted, model-based inference when the outcome model is richly adjusted (conditional, not descriptive, target).
- But that must be *stated and defended* — silence reads as an oversight, not a decision.
- Weighting and covariate adjustment are separate axes, not two rival framings. Design decides which population the estimate speaks for; adjustment decides which covariates it holds fixed. Every combination is available, and the honest report crosses them (Slide 11).
- Declare the estimand — population-average, conditional on covariates, or both — name the weight you used and why, and say which cell of the 2×2 your headline number came from.
- MASLD hook: the paper never declares which target it's after, so readers can't tell if unweighted was reasoned or accidental.

## Slide 11 — What weighting does to MASLD (12 min)
- Apply WTSAF (pooled) + SDMVSTRA + SDMVPSU via a survey-aware Cox fit.
- Group IV all-cause HR moves ~15.1 -> ~12.4 unadjusted; CIs widen from the design effect.
- Direction of the headline survives — Group IV still worst — but the magnitude and precision are honestly smaller/wider.
- Then cross the axes and show all four cells, fitted on the *same* Model-1 complete-case rows (n = 5,939): read **down** a column for adjustment, **across** a row for design. Holding the rows fixed is the only thing that makes a difference attributable to the axis you moved — and it is why the crude IV-vs-I cell reads 16.05 rather than the ~15.1 of the full analytic file.
- IV vs I, the paper's contrast: unweighted crude 16.05 (5.91–43.58), unweighted Model 1 3.79 (1.38–10.39); weighted crude 11.93 (2.60–54.84), weighted Model 1 2.97 (0.69–12.79).
- IV vs III, our locked contrast: unweighted crude 2.34 (1.72–3.18), unweighted Model 1 1.06 (0.77–1.45); weighted crude 3.07 (2.11–4.48), weighted Model 1 1.29 (0.90–1.86).
- The familiar ledger that runs unadjusted, then fully adjusted, then survey-weighted mixes crude and adjusted models fitted on different row sets. It is not a sequence of successive corrections and you do not present it as one.
- MASLD hook: on the paper's own IV-vs-I contrast, design decides whether the interval excludes 1; on the locked IV-vs-III contrast, adjustment dominates and design moves the estimate in the opposite direction and by less. "Survey design matters" is true of one contrast and much weaker for the other.

## Slide 12 — The question settled by CDC's least-common-denominator rule: fasting vs non-fasting analytes (12 min)
- FLI combines triglycerides + GGT + BMI + waist. TG is a *fasting* analyte (WTSAF domain); GGT is *not* (available in the broader MEC, WTMEC).
- Which weight is **primary** is settled by CDC's least-common-denominator rule, not contested: use the weight of the smallest applicable subsample.
- The rule selects WTSAF (FLI needs a fasting analyte). MEC is not a defensible *primary* — it would weight to a population in which the exposure cannot be constructed — but a MEC-weighted run, **explicitly labelled as a sensitivity analysis**, shows students how much the rule was worth. The point is to apply the rule, say so, and quantify what it bought.
- MASLD hook: MASLD's own ascertainment recipe forces a weight decision the paper never confronts.

## Slide 13 — Subset the design, never the data (10 min)
- Cardinal rule: define the full-survey design object once, then *subset within it* (e.g., `subset()` on the design), never filter rows first and re-declare a design on the survivors.
- Dropping rows first discards the strata/PSU information that non-selected units contribute to variance -> wrong SEs.
- This is the #1 practical error students will hit in L5.
- MASLD hook: MASLD eligibility (FLI>=60, ≥1 cardiometabolic criterion) is a *subset*, so it must be applied to the design, keeping WTSAF/strata/PSU intact.

## Slide 14 — Design-aware workflow, end to end (8 min)
- Steps: (1) pick weight tier by most-restrictive variable, (2) pool /cycles, (3) declare design with weight+strata+PSU, (4) subset within design, (5) fit survey-aware model, (6) report DEFF-widened CIs.
- Report a one-line "design statement" in every table caption — the habit that would have fixed the paper.
- Sensitivity analysis is part of the deliverable, not optional polish. For the weight that means: WTSAF primary by the rule, WTMEC reported alongside it and labelled as sensitivity.
- MASLD hook: this six-step recipe is precisely what P4 asks you to run on your paper.

## Slide 15 — Common pitfalls checklist (6 min)
- Forgetting to divide pooled weights by the number of cycles.
- Filtering rows before declaring the design (the fatal one).
- Using WTMEC when a fasting analyte is in the model, or vice versa.
- Reading unweighted vs weighted divergence as "error" rather than as two different estimands.

## Slide 16 — Bridge to today's lab (L5) and P4 (7 min)
- In L5 (EpiMethods Complex Survey module) you will re-fit the MASLD Group I–IV Cox model two ways on the fixed dataset: a *naive* unweighted fit, then a *design-aware* fit declaring WTSAF/6 + SDMVSTRA + SDMVPSU, subsetting the design (not the rows) to the MASLD-eligible sample. You will tabulate naive vs survey HRs and CIs side by side and quantify the attenuation (~15 -> ~12.4) and CI widening.
- This becomes **P4, your design-aware re-estimate**: apply the same six-step workflow to *your* paper's headline estimate, declare and justify your chosen weight (naming the fasting-vs-non-fasting tension if it applies), report the naive-vs-weighted contrast, and write the one-line design statement your paper omitted. Those six steps are the survey route. A group whose paper qualified at M0 criterion 5 on a time-to-event structure instead has no weight to declare and therefore no naive-vs-correct number to report: their P4 is to reproduce the paper's survival estimand keeping follow-up time and censoring, then interrogate the one structural choice they named at M0 — the time scale, the censoring rule, the index date, or how competing events were handled — and report what that choice does to the estimate and to its interpretation. Be exact about what is comparable: weighted and unweighted fits of the same survival model on the same rows are one estimand on one scale, so the gap between them is attributable to the design; a survival model set beside a collapsed "ever died" model is two different estimands on two different scales, so the gap between them measures the collapse, not the design, and is never the design-aware correction. P4 is formative and feeds directly into your M1 replication and M2 critique of another group's M1.
