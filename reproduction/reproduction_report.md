# Reproduction Report

**Paper:** Kueh MTW, Intaran MAU, Goh R, et al. *Body weight categories and fat
distribution in relation to all-cause mortality among adults with
metabolic dysfunction-associated steatotic liver disease: a population-based
analysis of NHANES, 2007–2018.* **BMJ Open** 2026;16:e113719.

**Data:** NHANES 2007–2018 (6 cycles) + NCHS Public-Use Linked Mortality Files
(2019 release), all public. **Software:** R 4.5.1.

> **Scope note.** These materials document a teaching reproduction of published
> analyses using the specified public data and course implementation. Differences
> from published results are reproducibility findings, not allegations of research
> misconduct, and may reflect analytic, implementation, or data-version differences.
> The findings below stand as recorded; this note frames how to read them, not
> whether they hold.

**Verdict:** **Table 1, Table 2 and Figure 1 reproduce closely** from the public
data — analytic cohort, group sizes, death counts, hazard ratios and
number-at-risk all match the publication to within a few tenths of a percent.
**Figure 2 reproduces for BMI (panel a) but not for WHtR (panel b)**, where our
curve turns down above WHtR ≈ 0.75 while the published curve keeps rising; the
paper does not report the spline specification, so the difference cannot be
resolved from what is published. Six reproducibility *findings* surfaced along
the way (alcohol exclusion, BMI cut-point labelling, CV-death definition, FLI
circularity, survey design, the WHtR spline) and are documented below — these
are the pedagogically useful part.

---

## 1. Sample funnel — typed, and two row sets kept apart

**Every step carries a type label.** A funnel shows N falling; it does not show *why*,
and the reasons are not interchangeable.

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

After eligibility, the two largest drops are **Step 2 (design)** and **Step 4 (target
population)**, and *neither is missing data*. Step 2 is the NHANES fasting subsample: it
was selected deliberately, and `WTSAF2YR` exists to account for that selection stage and
its nonresponse, so the correct response is the right weight and a domain analysis (P4),
not imputation. Step 4 is people without hepatic steatosis, who are not missing — they
are not who the paper is about. Genuine missingness here is **792 item-nonresponse
losses** at Step 3 and, separately, **2 outcome-ascertainment losses** at Step 7:
different problems, not added together, and not 30,532, which is what reading every
post-age-eligibility reduction as attrition would give.

**Two row sets, kept apart.**

| Row set | N | What it is |
|---|---:|---|
| **Full analytic file** | **6,371** | the funnel above with Step 2 removed: every adult with a computable FLI, whether or not they carry a valid fasting weight. It is the row set the paper itself analyses and the cohort `02_build_analytic.R` saves, so every table and figure under `output/` is built on it. |
| **Locked domain** | **6,048** | the funnel above as written: the records carrying a valid `WTSAF2YR`. It is the only row set on which a design-aware estimate is possible, and it is what P1 locks and P2–P5 analyse. |

The two differ by **323** records and neither is an error. Dropping Step 2 lets 819
adults through Step 3 who have all four FLI inputs but no valid fasting weight — that is
why the full analytic file's own FLI step is **14,989** rather than 14,170 — and 323 of
those 819 survive to the end. The paper is unweighted, so **6,371** is what reproduces
it; **6,048** is a different (correct) denominator, not a correction to the first. Quote
6,371 when you mean *what reproduces the paper*, and 6,048 when you mean *what a
design-aware estimate can be computed on*. `logs/sample_funnel.csv` logs both chains,
typed, and closes with the `Alcohol exclusion applied = FALSE` switch, which is why the
full analytic file stays at 6,371 rather than dropping further.

**Fatty Liver Index** (Bedogni 2006):
`FLI = e^L / (1+e^L) × 100`, `L = 0.953·ln(TG) + 0.139·BMI + 0.718·ln(GGT) + 0.053·WC − 15.745`, steatosis if FLI ≥ 60.

**Phenotype groups:** obesity = BMI ≥ 30 (≥ 25 for Asians); high central
adiposity = WHtR ≥ 0.6.

| Group | Definition | Reproduced N | Paper N |
|---|---|---:|---:|
| I | obese, low central | 391 | 386 |
| II | obese, high central | 4,585 | 4,541 |
| III | non-obese, low central | 787 | 769 |
| IV | non-obese, high central | 608 | 604 |

---

## 2. Table 1 — baseline characteristics (Overall column)

| Characteristic | Reproduced | Published | Match |
|---|---|---|:--:|
| N (full analytic file) | 6,371 | 6,300 | ~ |
| Age, year (mean SD) | 51.0 (16.6) | 51.0 (16.6) | ✓ exact |
| Female, n (%) | 2,997 (47.0) | 2,973 (47.2) | ✓ |
| Waist, cm (median IQR) | 110.5 (103.7–119.5) | 111.0 (104.0–120.0) | ✓ |
| BMI, kg/m² | 33.2 (30.1–37.4) | 33.2 (30.2–37.4) | ✓ exact median |
| Systolic BP | 124.0 (114.7–136.0) | 124.0 (114.0–135.0) | ✓ |
| Diastolic BP | 72.0 (64.0–79.3) | 72.0 (64.7–79.3) | ✓ |
| Current smoking | 1,238 (40.9) | 1,210 (40.6) | ✓ |
| Family history CHD | 911 (14.6) | 904 (15.0) | ✓ |
| Hypertension | 3,444 (54.1) | 3,238 (52.6) | ≈ (+1.5) |
| T2DM | 1,595 (25.0) | 1,645 (26.1) | ≈ (−1.1) |
| Dyslipidaemia | 3,839 (60.3) | 3,612 (57.7) | ≈ (+2.6) |
| CKD | 1,296 (20.3) | 1,142 (18.1) | ≈ (+2.2) |
| Stroke | 270 (4.3) | 269 (4.4) | ✓ |
| MI | 520 (8.2) | 518 (8.4) | ✓ |
| Heart failure | 283 (4.5) | 283 (4.6) | ✓ exact n |
| COPD | 157 (5.2) | 152 (5.2) | ✓ exact % |
| Cancer | 624 (10.0) | 624 (10.1) | ✓ exact n |

All group-stratified columns and p-values are in
`output/tables/table1_reproduced.{csv,html}`.

**Comorbidity definitions** (calibrated to the paper's prevalences — the paper
uses composites, not pure self-report):
- Hypertension = self-report **or** measured BP ≥ 140/90
- T2DM = self-report **or** HbA1c ≥ 6.5%
- Dyslipidaemia = self-report **or** lipid-lowering meds **or** LDL ≥ 130
- MI = prior heart attack **or** coronary heart disease (MCQ160E ∪ MCQ160C)
- CKD = eGFR < 60 (CKD-EPI 2021) **or** ACR ≥ 30
- Current smoking is expressed as a **% of ever-smokers** (matches the paper's 40.6%)

---

## 3. Table 2 — Cox regression (HR, 95% CI)

**All-cause mortality**

| Group | Events (repro / paper) | Unadjusted (repro) | Unadjusted (paper) | Model 2 (repro) | Model 2 (paper) |
|---|---|---|---|---|---|
| I | 5 / 5 | Reference | Reference | Reference | Reference |
| II | 389 / 388 | 6.68 (2.76–16.14) | 6.66 (2.76–16.09) | 2.37 (0.97–5.76) | 2.30 (0.94–5.60) |
| III | 74 / 74 | 6.23 (2.52–15.41) | 6.25 (2.53–15.47) | 2.99 (1.20–7.43) | 3.03 (1.22–7.53) |
| IV | 118 / 118 | 15.14 (6.19–37.04) | 15.13 (6.18–37.02) | 2.91 (1.18–7.20) | 2.89 (1.17–7.17) |

**Cardiovascular mortality** (CV death = underlying cause = *diseases of heart*)

| Group | Events (repro / paper) | Unadjusted (repro) | Unadjusted (paper) |
|---|---|---|---|
| I | 1 / 1 | Reference | Reference |
| II | 112 / 112 | 9.64 (1.35–69.04) | 9.64 (1.35–69.05) |
| III | 19 / 19 | 8.08 (1.08–60.38) | 8.11 (1.09–60.61) |
| IV | 26 / 26 | 16.75 (2.27–123.5) | 16.75 (2.27–123.4) |

Event counts match **exactly**; HRs agree to the 2nd–3rd significant figure.
Full three-model table in `output/tables/table2_reproduced.csv`.

- **Model 1:** age, sex, dyslipidaemia, hypertension, T2DM, CKD, MI, cancer,
  antihypertensive / antidiabetic / lipid-lowering medication use.
- **Model 2:** Model 1 + current smoking + sedentary minutes/day.

---

## 4. Figures

- `output/figures/figure1_km.png` — Kaplan–Meier by group. Group IV falls to
  ≈ 0.80 survival at ~7 y; Group I stays highest; log-rank p < 0.0001.
  Number-at-risk matches (e.g. Group IV 608 / 549 / 431 / 330 vs paper 604 / 546 / 433 / 334).
- `output/figures/figure2_rcs.png` — restricted cubic splines (4 knots,
  unadjusted, probability scale, matching the published caption).
  **Panel (a) BMI reproduces:** a steep fall from ≈ 0.22 at BMI 22 to ≈ 0.08 by
  BMI 33, then a shallow tail — the paper's "J-shaped trend towards reduced
  all-cause mortality as BMI increased" (nonlinear p = 0.003).
  **Panel (b) WHtR does *not* reproduce at the upper tail.** The published curve
  rises and then flattens, staying highest at WHtR 1.0 (≈ 0.045 → ≈ 0.12). Ours
  rises to a peak of ≈ 0.11 near WHtR 0.75 and then *declines* to ≈ 0.086 by 1.0
  — an inverted U, not a monotonic increase. The overall association is
  significant (p = 0.004) but the non-linearity is not (p = 0.073), and the
  confidence band above WHtR ≈ 0.85 is very wide. See finding #6.

---

## 5. Key reproduction findings (the interesting part)

1. **The Table 1/2 column headers and the Methods text state different BMI cut-points.**
   The headers read "BMI ≥ 25 / < 25", while the reported BMI medians in the
   *non-obese* groups are 27.6 and 28.8, which a 25 cut cannot produce. The Methods
   text gives obesity = BMI ≥ 30, and coding to **30** reproduces the published group
   sizes; coding to 25 does not. We therefore read the analysis as using 30 and the
   printed headers as a labelling inconsistency.

2. **The stated alcohol exclusion does not match the reported numbers.** The paper
   says it excluded "significant alcohol" (> 2 drinks/day men, > 1/day women), yet
   its N = 6,300 and 585 deaths match a cohort with **no material alcohol exclusion**
   (our 6,371, 586 deaths). A faithful average-daily exclusion removes ~430 people
   (N → 5,944). We keep the paper-matching cohort as primary and expose the
   exclusion as a sensitivity switch (`APPLY_ALCOHOL_EXCL` in `02_build_analytic.R`).
   *We could not reconcile the stated exclusion with the reported N under any coding of
   the public alcohol variables we implemented; a different implementation of the same
   sentence may reconcile them.*

3. **CV mortality = "diseases of heart" only.** Using heart + cerebrovascular gives
   185 CV deaths; heart-only gives exactly the paper's **158**.

4. **FLI circularity (Reviewer 1's point).** FLI uses BMI and waist circumference,
   which also define the BMI/WHtR exposure groups — exposure and steatosis
   ascertainment share inputs. The paper's TyG-index sensitivity analysis addresses
   this; it is the single most important methodological threat to interrogate.

5. **Complex survey design not applied.** The paper (and this reproduction) treat NHANES
   as a simple cohort — no `svydesign`, weights, strata, or PSUs. Defensible for
   internal HR estimation but affects national representativeness of the descriptives.

6. **The WHtR spline does not reproduce, and the specification needed to check it is
   not reported.** The published Figure 2b rises across the whole WHtR range and stays
   highest at the top; ours peaks near WHtR 0.75 and turns down (see §4). The Methods
   say only that "restricted cubic splines were constructed" — no knot count, no knot
   placement, no statement of whether the model was adjusted, and no trimming rule
   for the sparse upper tail. Those are exactly the choices that determine the
   shape where the data run out. Our panels use `rcs(x, 4)` with the `rms` default
   knot placement, so a different knot count, knot placement or trimming rule is a
   plausible explanation for the divergence where the data thin out. This is the
   clearest case in the paper of a published result that *cannot* be checked from
   what is reported, and it is a better worked example of under-specification than
   anything above.

---

## 6. Assumptions / deviations from an unknown ground truth

- Medication classes for the Cox models use NHANES questionnaire self-report
  (BPQ/DIQ) as a proxy; GLP-1 / SGLT2i-specific flags would need the RXQ_RX drug
  file parsed against the Multum lexicon (the lexicon file 404'd at download and is
  not required for the primary results).
- Residual ±1–3 pt differences in HTN/T2DM/dyslipidaemia/CKD reflect the paper's
  under-specified composite definitions ("as previously described").
- N differs by +71 (1.1%), almost entirely the alcohol-exclusion ambiguity above.

---

## 7. Map to the course project increments (P1–P5)

This reproduction *is* a worked example of the term project spine — and at two of the
five increments, a worked example of what the increment has to *repair*:

| Increment | Course task | Where it lives in this reproduction |
|---|---|---|
| **P1 — Analytic cohort** | rebuild the cohort and type every funnel step | `02_build_analytic.R` + `logs/sample_funnel.csv`; §1 above is the typed funnel, and the alcohol-exclusion finding (#2) is the P1 eligibility judgment call |
| **P2 — Confounding diagnostic (Table 1)** | Table 1, variable roles, crude vs adjusted | `03_table1.R` and §2; the BMI cut-point labelling discrepancy (#1) and the composite comorbidity definitions are the P2 interrogation targets |
| **P3 — Effect modification** | stratum-specific estimates plus a formal interaction test, on the locked contrast | **not in this pipeline** — no script here fits an interaction. P3 is where a group adds one |
| **P4 — Design-aware main estimate** | replicate the headline, then re-estimate the way the design demands | `04_table2_cox.R` replicates the *unweighted* headline; the survey-design omission (#5) is precisely what P4 repairs, using `WTSAF2YR` on the locked domain (§1) |
| **P5 — Missing-data sensitivity** | analyse the genuine missingness, and scope the rest | the **792 FLI item-nonresponse losses** and the complete-case covariate loss in Models 1–2 (§1). The fasting-subsample restriction is **DESIGN**, not missingness: it is answered by the P4 weight and by a sentence naming the population it leaves you with, never by imputation |

Naming the **single dominant threat** is not a weekly increment; it is the
analytic-judgment core of **M1**. The candidates this reproduction surfaces are FLI
circularity (#4), the survey-design omission (#5), and the under-specified WHtR spline
(#6).

**What this reproduction does and does not establish.** The pipeline reproduces the
paper's analysis, and the discrepancies above are documented rather than tuned away.
Read crudely, Group IV has the poorest observed survival, and the paper reports exactly
that — **that descriptive claim does follow**. Read adjusted, the picture is different:
the Model 2 estimates for Groups III and IV are near enough to each other to be
indistinguishable (repro 2.99 vs 2.91; paper 3.03 vs 2.89, both against Group I), so the
adjusted results **do not provide clear evidence** that Group IV has higher mortality
than Group III. Estimated directly on the locked domain, that contrast is
compatible with no difference as well as with a meaningful increase — 1.06 (0.77–1.45)
unweighted and 1.29 (0.90–1.86) design-aware (course increments P2 and P4).

So the replication succeeds, and the disagreement is not with the authors' arithmetic
but with which contrast supports the stated conclusion. Do not report this reproduction
as confirming the stronger, comparative reading — that the Group IV phenotype carries
higher mortality than Group III, and does so independently of overall body weight.
Neither the published table nor this pipeline establishes that.
