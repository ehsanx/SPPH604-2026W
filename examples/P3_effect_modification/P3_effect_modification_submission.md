# P3 — Effect Modification / Interaction (Lab 4)

*Model submission — demonstration paper (Kueh et al., BMJ Open 2026).*

## The candidate modifier and why we chose it

We test **sex** as an effect modifier of the phenotype–mortality association. Sex is the strongest candidate here for two reasons. First, it is clinically plausible: men and women differ in fat distribution, in the visceral-adiposity thresholds at which cardiometabolic risk rises, and in baseline all-cause mortality — so a WHtR-defined "high central adiposity" contrast could act differently across sexes. Second, and more decisively for us, **sex is entangled with the exposure itself**. The four phenotype groups are far from sex-balanced: Group II (obese, high central) is 56% female while Group I (obese, low central, our reference) is only 15% female. When the composition of the comparison groups shifts with sex, any crude between-group contrast partly reflects who is in each group rather than the effect of central adiposity — exactly the situation where a stratified analysis can mislead and a formal interaction test is required.

## Diagnostic only — the retired IV-vs-I stratification

> **This table is not the P3 result.** It uses **Group I as reference**, which is the
> paper's contrast, not our locked estimand. It is reproduced here solely to show *why*
> an earlier draft reached a dramatic conclusion, and it is superseded by the targeted
> IV-vs-III analysis below. Read that one for the finding.

Refitting the crude Cox model within each sex against Group I (Table P3.1), the
all-cause HRs are dramatically larger in men.

**Table P3.1. Crude sex-stratified all-cause HR (95% CI), Group I = reference.**

| Group | Men | Women |
|---|---|---|
| II (obese, high central) | 11.7 | 2.25 |
| III (non-obese, low central) | 8.47 | 2.94 |
| IV (non-obese, high central) | **28.2 (8.9–89.3)** | **4.08 (0.98–16.9)** |

Read naively, this is a striking picture: for the headline Group IV, the crude HR is roughly seven-fold higher in men (28.2) than in women (4.08), and the women's interval even crosses 1. Taken at face value it would suggest that non-obese central adiposity is far more lethal for men.

## The formal interaction test — targeted at the locked contrast

Our locked estimand is **IV vs III**. An earlier draft tested `group * sex` across all
four groups, which is a **multi-degree-of-freedom test of whether *any* group contrast
varies by sex** — a broader question than ours. Its p-values (0.055 crude, 0.571
adjusted) answered that broader question and are **retired**, not carried forward.

To test our estimand we restrict to Groups III and IV, making the interaction term
exactly **1 df for the contrast we care about**. Crude and adjusted are fit on the
**same Model-1 complete-case rows** (n = 1,296 of 1,306; 937 men, 359 women), so any
difference between them is attributable to adjustment rather than to sample change.

| | ratio of HRs (women / men) | p |
|---|---|---|
| Crude | 0.62 (0.26–1.43) | 0.278 |
| Model 1 adjusted | **1.00 (0.42–2.35)** | **0.993** |

Sex-specific adjusted IV vs III hazard ratios:

| | n | HR (95% CI) |
|---|---:|---|
| Men | 937 | 1.10 (0.75–1.62) |
| Women | 359 | 1.06 (0.48–2.34) |

## The additive scale — a real estimand, not an inference from hazard ratios

Stratum-specific hazard ratios do not show you the additive picture; you have to
estimate it. We take a **six-year horizon** (natural given the paper's ~6.9-year mean
follow-up) and compute **standardized risks by g-computation**: fit the Model-1 Cox
model within each sex, then predict six-year risk for *every* person in that stratum
twice — once setting IV = 0, once setting IV = 1 — and average. That marginalizes over
the observed covariate distribution of that stratum, so the contrast is a
population-average risk difference rather than a covariate-conditional one. Confidence
intervals are from 300 bootstrap resamples within stratum.

| | 6-yr risk, Group III | 6-yr risk, Group IV | Risk difference |
|---|---:|---:|---|
| Men | 0.097 | 0.105 | **+0.008 (−0.033 to 0.042)** |
| Women | 0.101 | 0.106 | **+0.005 (−0.073 to 0.076)** |

Difference in risk differences (women − men): **−0.003**.

## Interpretation

**What we can say.** On the multiplicative scale, the adjusted ratio of hazard ratios is
1.00, and on the additive scale both six-year risk differences are under one percentage
point. The data are **compatible with little or no interaction by sex** for our locked
contrast.

**What we cannot say.** The confidence interval on that ratio runs from **0.42 to
2.35** — compatible with the effect in women being less than half that in men, or more
than twice it. So the data are *also* compatible with substantial heterogeneity. "No
evidence of multiplicative interaction **at the precision available**" is the honest
statement; "no effect modification" is not. With 359 women and few events in the
non-obese strata, this study is not powered to resolve the question.

**What we specifically withdraw.** An earlier draft said the crude difference was
"confounding by baseline risk, not true modification" and that the adjusted test
"refuted" modification. Neither follows. A p-value that moves when covariates enter
tells you the *estimate* changed; it does not establish **what generated** the crude
difference, and a non-significant test is not evidence of absence. The crude ratio of
0.62 and the adjusted ratio of 1.00 are both imprecise; the change between them is
within their joint uncertainty.

## Method note — what we did and did not avoid

We did **not** run a logistic RERI. The problem is specific and worth stating correctly:
the error is analysing *ever-died* with logistic regression, which discards follow-up
time and ignores censoring, so any additive measure built on it answers a question about
cumulative status at an unspecified time. **RERI is not inherently a logistic-regression
concept** — additive interaction can be estimated on a survival scale. Our six-year
standardized risk differences above *are* the additive-scale analysis, done in a way
that respects time-to-event.

**Two limitations of the additive estimate.** Several bootstrap replicates in the female
stratum triggered Cox convergence warnings — with 359 women and sparse events, some
resamples separate — so the female interval is wide and should be read as
order-of-magnitude. And all of this is **unweighted**: P3 precedes the survey-design
increment. P4 shows that design materially changes inference for the main estimate, so
whether the design-aware interaction gives the same qualitative answer is an open
question, and one M1 should check rather than assume.

## Bottom line

For the locked IV-vs-III contrast, sex does not show evidence of effect modification on
either scale at the precision this study affords — adjusted ratio of hazard ratios 1.00
(0.42–2.35), six-year risk differences +0.008 in men and +0.005 in women. The eye-
catching crude stratified gap reported by an earlier draft came from a different
contrast (IV vs I) and a broader test. This is a null reported with its uncertainty
attached, not a demonstration that sex is irrelevant.
