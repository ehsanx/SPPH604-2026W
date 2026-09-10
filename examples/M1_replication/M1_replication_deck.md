# M1 — Replication and Interrogation

*Model submission — demonstration paper (Kueh et al., BMJ Open 2026;16:e113719).*

> **Student-facing resolved version.** Numerical values in this document were generated from the accompanying course results and match the rendered PDF.

*This is the **Instructor exemplar**: technically correct as far as P1–P5 establish. It is
not a planted-error "Review case".*

*Provenance: every result attributed to us is produced or assembled by `M1_code.qmd`. Most
are read from structured P1–P5 result objects; M1 additionally runs the replication
analysis and the design-aware interaction explicitly identified in the notebook. Figures
attributed to the paper are quoted from the article and checked against its PDF.*

\newpage

## Slide 1 — The question, and the two contrasts

- **Scientific (locked) estimand — IV vs III.** Among adults meeting FLI-based MASLD
  criteria, do **non-obese adults with high central adiposity** have higher all-cause
  mortality than **non-obese adults with low central adiposity**?
- **Replication estimand — IV vs I.** The paper references its contrasts to Group I
  (obese, low central adiposity). We reproduce that, because reproducing it is what
  *Replicate* means.
- **Two contrasts from one fitted model.** Re-levelling is reparameterization, not
  reanalysis. Nothing here says the paper's result is unstable.
- The locked contrast is what we interrogate: it holds body-mass category fixed, so
  central adiposity carries the exposure.

\newpage

## Slide 2 — The paper reproduces

On the **full analytic file** — the row set the paper itself analyses.

| | Published | Ours |
|---|---|---|
| Analytic N | ~6,300 | **6,371** |
| Groups I / II / III / IV | 386 / 4,541 / 769 / 604 | 391 / 4,585 / 787 / 608 |
| Deaths | 585 | 586 |
| Group IV vs I, unadjusted | 15.13 | 15.14 |
| Group IV vs I, **Model 2** | 2.893 | 2.908 |

- Rebuilt from raw NHANES 2007–2018 plus NCHS linked mortality; no derived extracts.
- **Model 2 is the paper's headline adjusted model.** Every diagnostic that follows uses
  **Model 1**, so the model label travels with the number everywhere.
- **Four discrepancies logged, none tuned away** — the "BMI <25" header (the Methods
  text uses 30), PIR percentages that disagree with the counts printed beside them,
  an alcohol exclusion matching no reported N, and
  cardiovascular death counted as heart-only (158; adding
  cerebrovascular gives 185).
- **One thing does not reproduce:** the WHtR spline panel. The knot specification is not
  reported, so the difference cannot be resolved.

\newpage

## Slide 3 — The analysis population, typed

| Step | N | Type |
|---|---:|---|
| NHANES 2007–2018 records | 59,842 | — |
| Age ≥ 18 | 36,580 | ELIGIBILITY |
| In fasting subsample | 14,962 | **DESIGN** |
| FLI computable | 14,170 | **MISSINGNESS** |
| Steatosis, FLI ≥ 60 | 6,052 | **TARGET POPULATION** |
| MASLD criterion | 6,050 | TARGET POPULATION |
| Mortality-eligible and linked | **6,048** | OUTCOME ASCERTAINMENT |

- After eligibility, the two largest reductions are **design** and **disease
  definition**. Neither is missing data.

- **Genuine missingness: 792 item-nonresponse losses.
  Separately, 2 outcome-ascertainment losses.** Different
  problems — not added together, and not 30,532, which is what
  reading every post-age-eligibility reduction as attrition would give.
- **Two row sets, kept apart.** The replication uses the full analytic file
  (6,371); every diagnostic from here uses the **locked domain,
  6,048** — the records with a valid fasting weight.

\newpage

## Slide 4 — The central diagnostic: adjustment versus design

All four cells on the **same 5,939 Model-1 complete-case rows**.

| | IV vs I *(replication)* | IV vs III *(locked)* |
|---|---|---|
| unweighted, crude | 16.05 (5.91–43.58) | 2.34 (1.72–3.18) |
| unweighted, Model 1 | 3.79 (1.38–10.39) | **1.06 (0.77–1.45)** |
| weighted, crude | 11.93 (2.60–54.84) | 3.07 (2.11–4.48) |
| weighted, Model 1 | 2.97 (0.69–12.79) | **1.29 (0.90–1.86)** |

Read **down** a column for adjustment; **across** a row for design.

- **On the locked estimand, adjustment dominates.** Design moves it in the *opposite*
  direction and by less, and does not materially alter the estimate or the uncertainty
  statement.
- **Design does materially alter the replication estimate** — 3.79 (1.38–10.39)
  becomes 2.97 (0.69–12.79) — a lower estimate and a substantially wider interval.
- **The paper's own Table 2 points the same way.** Its published Model 1 gives Group III
  3.175 and Group IV 3.155 against Group I —
  an implied IV-vs-III ratio of 0.99.

\newpage

## Slide 5 — Interaction: imprecise, and sensitive to design

Targeted **1-df** test of the locked contrast (Groups III and IV only; n =
1,296 — 937 men, 359 women). Both rows are
Model 1 on the **same analytic contrast and the same rows**; they differ only in whether
the survey design is used.

| | ratio of HRs (women / men) | p |
|---|---|---|
| unweighted, Model 1 | 1.00 (0.42–2.35) | 0.993 |
| **design-aware, Model 1** | **2.53 (0.92–6.98)** | 0.073 |

- **The interaction estimate is sensitive to survey design.** The weighted analysis makes
  substantial heterogeneity **more plausible** than the unweighted analysis suggested.
- Neither establishes effect modification. **The estimates are too imprecise to resolve
  the question**, which is not evidence that sex is irrelevant.
- We do not read 0.073 as a finding. The movement in the estimate and
  interval is the result; the threshold is not.

\newpage

## Slide 6 — Residual missingness: little practical impact here

1 of 11 Model-1 covariates carries any
missingness: cancer status, 109 observations
(1.80% unweighted, 1.18% weighted).

| Locked estimand, weighted Model 1 | HR (95% CI) |
|---|---|
| complete case | 1.29 (0.90–1.86) |
| all assigned **no cancer** | 1.29 (0.89–1.85) |
| all assigned **cancer** | 1.29 (0.89–1.85) |
| MI (m = 10) | 1.29 (0.89–1.85) |

- The four approaches are **materially indistinguishable — they agree to the displayed
  precision.**
- The two extreme assignments are transparent global scenarios, **not bounds**: a uniform
  assignment need not extremise the coefficient.
- Computed on the locked contrast, not inferred from the replication contrast.

\newpage

## Slide 7 — Threats, on two axes

| Candidate | What we observed | Consequence |
|---|---|---|
| **Estimand–adjustment-set alignment** | Target quantity never stated; adjustment moves the locked estimand to 1.29 (0.90–1.86) | **High** |
| **Survey design** | Moderate on the locked estimand, large on the replication one | Moderate |
| **FLI circularity** | Untested by our pipeline — but not by the authors | Uncertain |
| **Residual missingness** | Four approaches agree to displayed precision | **Low** |

**On circularity, be accurate about what already exists.** The paper reports a TyG-based
re-ascertainment and finds Group III 3.1 (1.3–7.7) and Group IV
3.1 (1.2–7.6) against Group I — so the authors' own circularity check leaves
the locked IV-vs-III contrast at roughly 1.0.
**This is a point-estimate observation only; the IV-vs-III uncertainty cannot be recovered
from the separately reported confidence intervals.**

\newpage

## Slide 8 — The dominant threat, and what would change our mind

**Dominant threat: estimand–adjustment-set alignment.** The target quantity Model 1 is
meant to represent is not made explicit — causal total effect, causal direct effect, or
conditional prognostic association. Without that target, there is no unique causal
interpretation of the attenuation, and it is unclear whether the adjustment set supports
the paper's stronger *independent of total body weight* interpretation.

- **Read crudely, Group IV has the poorest observed survival** (19.5%
  died, against 9.6% in Group III), and the paper reports exactly
  that. **That descriptive claim does follow.**
- **Read adjusted, the published Group III and IV point estimates are nearly identical,
  and our directly estimated IV-vs-III contrast is compatible with no difference**
  (1.06 (0.77–1.45) unweighted, 1.29 (0.90–1.86) design-aware). The
  adjusted results therefore **do not provide clear evidence** that Group IV has higher
  mortality than Group III. The design-aware interval remains compatible with a
  meaningful increase as well as with none.

**What would change our mind:**

- **A stated target quantity**, and — if it is causal — a prespecified causal model
  supporting the adjustment set. If a direct effect is the target, that requires an
  explicit mediation estimand.
- **A design-aware re-analysis of the TyG sensitivity on the locked contrast**, with its
  own interval.
- **A larger or pooled sample** resolving the interaction, since the design-aware estimate
  2.53 (0.92–6.98) is too imprecise to act on.

