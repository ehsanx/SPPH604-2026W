# P2 — Confounding Diagnostic / Table 1

*Model submission — demonstration paper (Kueh et al., BMJ Open 2026).*

## Primary contrast

Our term question isolates central adiposity: among adults meeting FLI-based MASLD criteria, we compare **Group IV (non-obese, high central adiposity: BMI<30, WHtR≥0.6)** against **Group III (non-obese, low central adiposity: WHtR<0.6)** for all-cause mortality, holding body-mass category fixed so that WHtR carries the exposure contrast rather than obesity.

## Reproduced Table 1 (mortality-eligible cohort, n=6,371)

We reproduced the descriptive table from the raw NHANES 2007–2018 files. Reproduced vs paper, key rows:

| Characteristic | Reproduced | Paper |
|---|---|---|
| Age, mean (SD), y | 51.0 (16.6) | 51.0 (16.6) |
| Female, n (%) | 2,997 (47.0) | 2,973 (47.2) |
| Waist, cm (median) | 110.5 | 111.0 |
| BMI, kg/m² (median) | 33.2 | 33.2 |
| SBP / DBP, mm Hg | 124 / 72 | 124 / 72 |
| Current smoking (% of ever-smokers) | 1,238 (40.9) | 1,210 (40.6) |
| Hypertension, n (%) | 3,444 (54.1) | 3,238 (52.6) |
| Type 2 diabetes, n (%) | 1,595 (25.0) | 1,645 (26.1) |
| Dyslipidaemia, n (%) | 3,839 (60.3) | 3,612 (57.7) |
| CKD, n (%) | 1,296 (20.3) | 1,142 (18.1) |
| Prior MI, n (%) | 520 (8.2) | 518 (8.4) |
| Cancer, n (%) | 624 (10.0) | 624 (10.1) |

The demographics land essentially on top of the paper. The comorbidity rows sit a few points higher (HTN, dyslipidaemia, CKD), which we attribute to our composite definitions folding in measured/lab evidence, not only self-report — a defensible choice we document rather than tune toward the paper.

## Composite comorbidity definitions we used

- **Hypertension** — self-report of diagnosis OR measured BP ≥140/90 mm Hg.
- **Type 2 diabetes** — self-report OR HbA1c ≥6.5%.
- **Dyslipidaemia** — self-report OR lipid-lowering medication OR measured LDL ≥130 mg/dL.
- **Prior MI** — prior heart attack (MCQ160E) OR coronary heart disease (MCQ160C).
- **CKD** — CKD-EPI-2021 eGFR <60 mL/min/1.73 m² OR urine ACR ≥30 mg/g.
- **Current smoking** — expressed as a percentage of ever-smokers (matching the paper's denominator).

Making these explicit is the point of the increment: the same label ("hypertension") can shift several percentage points depending on whether measured values count, and that choice propagates into every adjusted model.

## Variable roles: what the paper adjusted for, versus what we can justify

**These are two different lists and we keep them apart.** The paper states that it
adjusted for these variables; it does not establish their causal roles, and neither does
predicting mortality. A variable is a confounder because of its position in a causal
structure, not because it is prognostic.

Age, sex and race/ethnicity we can justify as confounders on temporal grounds: they
precede adult adiposity and plausibly cause both it and mortality. **T2DM, hypertension,
dyslipidaemia, CKD and prior MI we cannot.** Each is plausibly *downstream* of central
adiposity on the path to death, which would make Model 1 a partial mediator adjustment
rather than confounding control. Cancer is more ambiguous still.

We therefore do **not** claim Model 1 estimates a direct effect. Doing so would require
assumptions — no unmeasured mediator–outcome confounding among others — that nothing in
this paper or our reproduction establishes. What we can say is that the adjustment set is
inherited, that its causal justification is not given, and that this is a threat we carry
forward to M1 rather than resolve here.

A variable's role is defined **relative to the WHtR→mortality contrast**, not by whether it predicts the outcome.

| Variable | Role | Reasoning |
|---|---|---|
| Age | Confounder | Drives both fat redistribution to the trunk and death; a common cause. |
| Sex | Confounder | Affects central-fat patterning (WHtR) and baseline mortality; upstream of both. |
| Income (PIR) | Confounder | Socioeconomic position shapes adiposity and mortality via access, diet, environment. |
| Hypertension, T2DM, dyslipidaemia, CKD | **Ambiguous — confounder vs mediator** | If cardiometabolic disease *causes* central adiposity they confound; if central adiposity *causes* them they are mediators on the causal path and adjusting them under-estimates the total effect. |
| Prior MI, heart failure | Likely mediator/collider | Downstream of adiposity and cardiometabolic strain; conditioning risks collider bias. |
| Cancer | **Causal role uncertain** | Predicts mortality, but prediction is not confounding. Cancer may precede adiposity, follow it, or share causes with it; we cannot place it from what the paper or our reproduction establishes. |

**DAG sketch.** Age, sex, and income are common causes pointing into both WHtR (exposure) and mortality (outcome) — the classic back-door structure we must block. The cardiometabolic comorbidities sit on the fence: the paper's Model 1 adjusts for them as confounders, but the mechanistic story ("central fat → dysmetabolism → death") makes them candidate mediators. We flag this explicitly because **we cannot say which estimand Model 1 targets.** If the comorbidities are confounders it approaches a total effect; if they are mediators it approaches something closer to a direct effect; if any are colliders it may be neither. Deciding between those requires causal assumptions the paper does not state and our reproduction cannot supply, so we leave it open rather than assert one. Prior MI and heart failure are the most collider-prone: they are consequences of the exposure, so conditioning on them can open non-causal paths.

## Two estimands, kept apart on purpose

The paper references every contrast to **Group I** (obese, low central adiposity). Our
locked term question references **Group III** (non-obese, low central adiposity),
because that is the comparison that isolates central adiposity while holding body-mass
category fixed. Both are legitimate; they answer different questions, and the failure
mode is switching between them without saying so.

**Group I is obese.** It is not a "lean reference", and calling it one — as we did in an
earlier draft — quietly turns the paper's contrast into a claim about thinness that it
does not make.

### Replication estimand — the paper's contrast, IV vs I

| Model | rows | Group IV vs I HR (95% CI) |
|---|---:|---|
| Crude | 6,048 | 16.96 (6.24–46.05) |
| Crude | 5,939 | 16.05 (5.91–43.58) |
| Model 1 | 5,939 | **3.79 (1.38–10.39)** |

Reproduced. The paper's headline survives adjustment on its own reference.

### Locked scientific estimand — IV vs III, identical rows

Model 1 loses 109 observations to missing cancer status, so a crude estimate on 6,048
rows and an adjusted estimate on 5,939 differ for **two** reasons at once. We therefore
fit both on the same complete-case set, and report the all-rows crude separately to show
what the restriction did.

| Model | rows | Group IV vs III HR (95% CI) |
|---|---:|---|
| Crude | 6,048 | 2.33 (1.71–3.17) |
| Crude | 5,939 | 2.34 (1.72–3.18) |
| Model 1 | 5,939 | **1.06 (0.77–1.45)** |

**The row restriction accounts for essentially none of the change** (2.33 → 2.34). What
follows is attributable to adjustment, which is the only reason we can say so.

### What this shows, and what it does not

On our locked contrast, the crude 2.34-fold excess **does not survive Model-1
adjustment**: the adjusted hazard ratio is 1.06 with a confidence interval spanning
0.77 to 1.45. Among non-obese adults with MASLD, we find **no evidence of a higher
hazard at the available precision** once age, sex and cardiometabolic burden are
accounted for. That interval is compatible with a 23% reduction and a 45% increase, so
it does not establish absence of an effect — it establishes that this study cannot
detect one.

**These are not two models disagreeing.** Both contrasts come from the *same* fitted
Cox model; re-levelling the exposure factor is reparameterization, not reanalysis. So
nothing here says the paper's result is unstable or that "the answer depends on the
reference group" — it does not. What it says is that the model contains two different
scientific questions, and they have different answers:

- *Is the non-obese, high-central-adiposity group worse off than the obese, low-central
  group?* Yes — 3.79 (1.38–10.39).
- *Within the non-obese, does high central adiposity carry higher mortality?* Not
  detectably — 1.06 (0.77–1.45).

Both are true of the same model at once. Group IV looks dramatic against Group I partly
because **Group I is a small, comparatively healthy obese stratum (n = 391)**. The
paper's headline is stated against that reference and reproduces against it; our locked
question is the second one, and it is the one that does not survive adjustment.

**We do not read the attenuation as validation.** An earlier draft of this submission
claimed a large effect surviving adjustment is "more credible" than a large crude
effect. That is wrong as a general principle and we withdraw it. Adjustment can remove
confounding, but it can also remove real effect by conditioning on mediators, and it can
introduce bias by conditioning on colliders. **Attenuation is diagnostic evidence about
what the covariates are doing — it is not evidence that the adjusted estimate is
correct.** Which of those three mechanisms is operating here is exactly what the
variable-role analysis below cannot yet settle.

## Publication inconsistency caught: PIR income-% swap

Reconstructing the income (poverty-income ratio) distribution from the counts, we get **High 22.1% / Middle 54.9% / Low 23.0%**. The paper prints **High 23.0% / Low 22.1%** — the high- and low-income percentages are transposed. The middle category and the underlying counts agree, so the difference is in the printed percentages rather than in how the variable is defined. It does not affect the models (PIR is not in Model 1/2), but it is the kind of small, traceable discrepancy the diagnostic exists to surface, and we log it alongside the BMI cut-point mislabel for the M1 synthesis.
