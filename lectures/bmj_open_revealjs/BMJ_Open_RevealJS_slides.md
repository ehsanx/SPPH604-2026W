---
title: Decomposing the Study Aim
theme: white
transition: slide
slideNumber: true
---

# Decomposing the Study Aim

## BMI, central adiposity, and mortality in MASLD

**Example paper:** Kueh et al. *BMJ Open*. 2026;16:e113719

**Teaching focus:** Move from a broad published aim to a clearly defined research question — and see exactly which NHANES variables it rests on.

---

# What did the authors say they wanted to study?

The paper has **two related aims**:

1. Examine the **clinical correlates** of four groups defined by BMI and waist-to-height ratio.
2. Assess the **prognostic value** of this classification for mortality.

These are related, but they are **not the same research question**.

---

# The aim contains two questions

|  | Clinical correlates | Mortality prognosis |
|---|---|---|
| **Question** | How do the four phenotype groups differ in their health characteristics? | Do the four phenotype groups have different subsequent mortality? |
| **Time structure** | Mostly cross-sectional at baseline | Longitudinal follow-up |

A single paper can contain more than one research question.

---

# First: how NHANES is organised

- **Six two-year cycles**, 2007–2018. Each cycle has its own file suffix: `E F G H I J`.
- Files are **.XPT** (SAS transport), read in R with `haven::read_xpt()`.
- Each file is **one row per participant** for one topic — not one big table.
- SEQN is the key. Every component is joined on it.

| Family | Examples | What it holds |
|---|---|---|
| Demographics | `DEMO` | age, sex, race, survey design, weights |
| Examination | `BMX`, `BPX` | measured body size, blood pressure |
| Laboratory | `TRIGLY`, `BIOPRO`, `GLU`, `GHB`, `HDL` | blood results |
| Questionnaire | `ALQ`, `BPQ`, `DIQ`, `SMQ` | self-reported history and medication |

> Mortality is **not** an NHANES file. It is a separate linked, fixed-width file from NCHS.

---

# Where the measurements and labs come from

| Concept | NHANES variable | Component |
|---|---|---|
| Participant ID | `SEQN` | *every file — the merge key* |
| Age, sex, race | `RIDAGEYR`, `RIAGENDR`, `RIDRETH3` | `DEMO` |
| BMI, waist, height | `BMXBMI`, `BMXWAIST`, `BMXHT` | `BMX` |
| Triglycerides | `LBXTR` | `TRIGLY` |
| GGT | `LBXSGTSI` | `BIOPRO` |
| Glucose, HbA1c | `LBXGLU`, `LBXGH` | `GLU`, `GHB` |
| HDL cholesterol | `LBDHDD` | `HDL` |
| Blood pressure | `BPXSY1–4`, `BPXDI1–4` | `BPX` |

Anthropometry, blood pressure and laboratory values are measured/assayed. Age, sex and race/ethnicity come from the demographic interview/file.

---

# Where the questionnaire, design and outcome come from

| Concept | NHANES variable | Component |
|---|---|---|
| BP / lipid medication | `BPQ050A`, `BPQ100D` | `BPQ` |
| Diabetes | `DIQ010`, `DIQ050`, `DIQ070` | `DIQ` |
| Alcohol | `ALQ130`, `ALQ120Q`, `ALQ120U`, `ALQ121` | `ALQ` |
| Survey design | `WTMEC2YR`, `WTSAF2YR`, `SDMVSTRA`, `SDMVPSU` | `DEMO`, `TRIGLY` |
| Mortality | `MORTSTAT`, `PERMTH_EXM`, `ELIGSTAT` | linked mortality file |

> In the variables shown here, the analysis reaches across **seven examination/laboratory component files**, plus demographics and questionnaire components, and a separate linked mortality file. That is what L1 assembles.

---

# Four NHANES traps — each one has bitten this project

- 777 = refused, 999 = don’t know. They are codes, not counts. Reading `ALQ130` literally over-excluded about 2,000 people here.
- **Do not automatically recode diastolic BP = 0 as missing.** NHANES explicitly allows a diastolic value of 0; failure to obtain a reading is handled separately. Treating every 0 as missing would also be an error.
- `RIDRETH3` does not exist before 2011. It is what identifies Asian participants for the lower BMI threshold, so the first two cycles cannot apply it.
- Fasting labs carry their own weight. `LBXTR` and `LBXGLU` come from the fasting subsample, which is weighted by `WTSAF2YR`, not `WTMEC2YR`.

---

# Survey design: paper versus reproduction

NHANES is a **complex, multistage probability sample**.

For analyses using fasting triglycerides, CDC provides the fasting-subsample weight `WTSAF2YR`, together with strata and PSU variables.

---

# Survey design: the distinction that matters

- The **published paper's Statistical analysis section does not report using NHANES survey weights, strata or PSUs**.
- Our reproduction pipeline includes survey-design variables and fasting-subsample weights.
- Therefore, a survey-weighted reproduction is a **design-informed reanalysis**, not necessarily a literal reproduction of every published analytic choice.

> Without the appropriate NHANES design information, estimates and standard errors should not be described as design-based nationally representative estimates.

---

# Population: who is being studied?

## Adults with MASLD in NHANES, 2007–2018

**MASLD** = metabolic dysfunction-associated steatotic liver disease: excess fat in the liver together with metabolic dysfunction.

> But nobody looked at a liver. **Steatosis was estimated by a formula** — see the next slide.

The study population is **not the general population**. Everyone in the main analysis already meets the study definition of MASLD.

---

# How MASLD was actually ascertained

Hepatic steatosis was **estimated** using the **Fatty Liver Index** (Bedogni 2006), thresholded at FLI ≥ 60:

$$ FLI uses: triglycerides (LBXTR) · BMI (BMXBMI) · GGT (LBXSGTSI) · waist (BMXWAIST) $$

Plus **at least one of five cardiometabolic criteria**: adiposity, raised glucose/HbA1c or diabetes, raised blood pressure or treatment, raised triglycerides or treatment, or low HDL.

So “MASLD” here is a **derived variable**, not a diagnosis. No imaging, no biopsy.

---

# Notice what the eligibility formula contains

|  | Inputs |
|---|---|
| **Eligibility** (FLI) | triglycerides, GGT, BMI, waist |
| **Exposure** (phenotype group) | BMI, waist / height |

> **The population definition and the exposure classification share BMI and waist measurements.** This creates structural dependence between cohort eligibility and phenotype classification. For a causal question, conditioning on this selected population could create selection/collider bias under some causal structures; for a prognostic question, it primarily defines a selected target population. It is not automatically 'circularity' or bias.

We only *name* it today. You will dissect what it does to the estimate at **M1**.

---

# What is the main exposure?

The exposure is not one measurement. It is built in two steps:

`BMXWAIST` + `BMXHT` → **waist-to-height ratio** `BMXBMI` → **obesity category** BMI category × WHtR category → four phenotype groups

---

# Exposure component 1: BMI

$$ BMI = weight (kg) / height² (m²) $$

- Weight and height were **measured** in the exam, not self-reported (`BMXBMI`).
- BMI marks **overall body size**.
- Obesity defined as **BMI ≥ 30**; for Asian participants **BMI ≥ 25** (`RIDRETH3 == 6`).

BMI does not measure body fat, or where fat is stored.

> **Paper reporting note:** the Methods define obesity as BMI ≥30 kg/m² (≥25 kg/m² for Asians), but the published Tables 1–2 label the groups as BMI ≥25 versus <25. Those table labels conflict with the Methods and with the reported group BMI distributions, so they appear to be a reporting error.

---

# Exposure component 2: waist-to-height ratio

$$ WHtR = waist (cm) / height (cm) = BMXWAIST / BMXHT $$

A person 170 cm tall with a 102 cm waist has WHtR = 102/170 = **0.60**.

- High central adiposity is defined as **WHtR ≥ 0.60**.
- WHtR is a simple marker of **abdominal adiposity**.
- It is not a CT or MRI measurement of visceral fat.

---

# The exposure is the combination

|  | Lower central adiposity WHtR < 0.60 | High central adiposity WHtR ≥ 0.60 |
|---|---|---|
| **Obesity by BMI** | **Group I** reference | **Group II** |
| **No obesity by BMI** | **Group III** | Group IV |

> Group IV — not obese by BMI, but a large waist for their height. The study asks whether BMI alone misses this higher-risk phenotype.

Every hazard ratio in the paper is measured **against Group I**. A ratio without its reference group means nothing.

---

# Exposure and comparison

There is no single “treated” group and “control” group.

- The **four-category phenotype** is the exposure / index factor.
- Mortality is compared **across the four categories**.
- In the Cox model, **Group I is the reference**; the hazard in Groups II, III and IV is expressed relative to it.

---

# Outcome and follow-up

**Primary outcome:** all-cause mortality — death from any cause (`MORTSTAT`).

- Participants entered NHANES between **2007 and 2018**.
- Mortality follow-up ran through **31 December 2019**, via the NCHS linked mortality file.
- Follow-up time is `PERMTH_EXM` — months from exam to death or censoring.
- Participants had **different lengths of follow-up and censoring**, so time-to-event methods are appropriate. A risk difference could still be estimated at a fixed time horizon using methods that account for censoring.

---

# Our reproduction: how 59,842 people became 6,048

| Step | N | What kind of step |
|---|---|---|
| NHANES 2007–2018 records | 59,842 |  |
| Age ≥ 18 | 36,580 | eligibility |
| In fasting subsample | 14,962 | design — drops 21,618 |
| FLI computable | 14,170 | missingness |
| Steatosis (FLI ≥ 60) | 6,052 | target population |
| MASLD (≥1 criterion) | 6,050 | target population |
| Mortality-linked | **6,048** | outcome ascertainment |

> The largest single exclusion in **our reproduction** is the fasting subsample — a design feature because the analysis uses fasting triglycerides.

---

# What the funnel reveals

**Reproducibility note:** the published paper reports **6,300** participants with MASLD, whereas this pipeline yields **6,048** mortality-linked participants. The two numbers should not be presented as if they were the same cohort.

The paper also states eligibility as **age >18 years**, while this reproduction flow uses **age ≥18**. Small implementation differences like this should be recorded rather than silently harmonized.

---

# PECOT decomposition

| Element | This study |
|---|---|
| **P** — Population | Adults with MASLD by FLI ≥ 60 + ≥1 cardiometabolic criterion, in the fasting subsample |
| **E** — Exposure | Four-category BMI × WHtR phenotype |
| **C** — Comparison | Groups II, III, IV versus **Group I** |
| **O** — Outcome | All-cause mortality to 31 Dec 2019 |
| **T** — Time | Months from exam to death or censoring |

---

# Reconstructed mortality question

> Among adults with MASLD, are BMI/WHtR phenotypes associated with different subsequent risks of all-cause mortality?

This wording makes the population, exposure, comparison, outcome and time structure explicit — and it is now honest about how the population was defined.

---

# What does “prognostic value” mean here?

A prognostic question asks: does knowing the phenotype tell us something about what is likely to happen later?

After multivariable adjustment: does phenotype remain associated with mortality among people who are similar on the other variables in the model?

> That is an **adjusted prognostic association**. It is not automatically a causal effect.

---

# Same variables, different targets

| Research goal | Scientific target in this example |
|---|---|
| **Description** | What are the characteristics and mortality experience of each phenotype group? |
| **Association** | Is phenotype statistically associated with subsequent mortality? |
| **Prognostic factor** | Does phenotype carry prognostic information about mortality **over and above** other known prognostic factors? |
| **Prediction** | How accurately can we predict an individual's mortality risk, and does adding WHtR improve prediction? |
| **Causal** | What would mortality have been under a specified intervention or exposure contrast that changed central adiposity? |

> The variables can be identical. **The target quantity is not.**

---

# Same variables, different analyses

| Goal | Typical analysis/design | How are other variables handled? |
|---|---|---|
| **Description** | Survey-weighted means, proportions, prevalence; Kaplan–Meier or standardized survival summaries | Used for stratification/standardization if scientifically useful |
| **Association** | Cox regression, splines, group comparisons | Included to define a **conditional association**; no automatic causal interpretation |
| **Prognostic factor** | Multivariable Cox model containing established prognostic factors + the index factor | Adjust for **other prognostic factors** to ask whether the index factor contributes information beyond them |
| **Prediction** | Develop/validate a multivariable survival prediction model; compare a base model with a base + WHtR model | Choose predictors for predictive value, availability and intended use; control overfitting with shrinkage/penalization and validation |
| **Causal** | Specify the causal estimand/target trial; use standardization, g-formula, inverse-probability weighting or another identification strategy | Select **confounders** using causal knowledge/DAGs; avoid inappropriate control of mediators/colliders for the chosen estimand |

> A Cox model can appear in several rows. **The model family does not determine the research goal.**

---

# Same variables, different evidence of success

| Goal | Main result / performance evidence |
|---|---|
| **Description** | Absolute summaries with uncertainty: means, prevalences, survival/risk at clinically meaningful times, group differences |
| **Association** | Association measure such as HR with 95% CI; model assumptions and functional form |
| **Prognostic factor** | Adjusted prognostic effect (for example HR + CI). If claiming **incremental prognostic information**, compare a model with versus without the factor (for example likelihood-ratio change / explained variation); if claiming improved **prediction**, also show changes in calibration/discrimination/error |
| **Prediction** | **Calibration** (plot, calibration-in-the-large, slope), **discrimination** (C-index/time-dependent AUC), overall error such as **Brier score**, plus internal/external validation; clinical use may require decision-curve/net-benefit analysis |
| **Causal** | A prespecified causal contrast—preferably an absolute risk/survival difference or ratio at a fixed time, or RMST difference—plus diagnostics for positivity/weights/balance and sensitivity analyses for unmeasured confounding/selection |

---

# HR + CI: what it is, and is not, evidence for

**HR + CI** can be enough to report an adjusted association or prognostic-factor effect.

It is **not** evidence that a prediction model is good, and it is **not** by itself evidence that a causal effect has been identified.

---

# What does this paper most directly support?

It directly supports:

- description of how phenotype groups differ clinically;
- association between phenotype and subsequent mortality;
- an adjusted prognostic association.

It does not, by itself, establish:

- that central adiposity **causes** the mortality difference;
- that reducing WHtR would reduce mortality;
- that adding WHtR meaningfully improves individual prediction.

---

# Take-home sequence

1. **Define the population** — and state how membership was *ascertained*, not just what it means.
2. **Define exactly how the exposure is measured** — down to the variable name and the file it came from.
3. **Check whether the two overlap.** Here they do.
4. **Define outcome and time** — all-cause mortality to 2019.
5. **State the research question** so that all five are explicit.

> Before Thursday’s lab, you should be able to name the component each variable above comes from.

---

# Methods references for these distinctions

- **Prognostic factors:** Riley RD, et al. *BMJ* 2019;364:k4597 — adjusted prognostic effects and value over and above other prognostic factors.
- **Prediction models:** Moons KGM, et al. *BMJ* 2009;338:b375; Riley RD, et al. *BMJ* 2024;386:e078276 — development, validation, calibration and discrimination.
- **Causal inference:** Hernán MA, Robins JM. *J Epidemiol Community Health* 2006 — estimating causal effects from epidemiologic data; Hernán MA, Dahabreh IJ. *Ann Intern Med* 2025 — target-trial framing and explicit causal estimands.

---

# Reference

Kueh MTW, Intaran MAU, Goh R, et al. **Body weight categories and fat distribution in relation to all-cause mortality among adults with metabolic dysfunction-associated steatotic liver disease: a population-based analysis of NHANES, 2007–2018.** *BMJ Open*. 2026;16:e113719.

doi: [10.1136/bmjopen-2025-113719](https://doi.org/10.1136/bmjopen-2025-113719)

Cohort counts and variable names on these slides come from this repository’s own reproduction pipeline, not from the paper’s prose.
