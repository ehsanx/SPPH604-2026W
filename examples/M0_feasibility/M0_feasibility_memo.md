# M0 — Feasibility Memo

**Group:** Demonstration (instructor's worked example)
**Members:** AB, CD, EF
**Date:** 22 September 2026

---

## The paper we are locking

> Kueh MTW, Chew NWS, et al. Body weight categories and fat distribution in relation to
> all-cause mortality among adults with metabolic dysfunction-associated steatotic liver
> disease. *BMJ Open* 2026;16:e113719.
> doi:[10.1136/bmjopen-2025-113719](https://doi.org/10.1136/bmjopen-2025-113719)

Open access (CC BY-NC). Built entirely on public NHANES data with NCHS linked mortality.

**Our estimands, fixed for the term:**

> **Scientific (locked) estimand — IV vs III.** Among adults meeting FLI-based MASLD
> criteria, do **non-obese adults with high central adiposity** have higher all-cause
> mortality than **non-obese adults with low central adiposity** — and how robust is that
> to cohort construction, confounding, effect heterogeneity, survey design, and
> incomplete observation?
>
> **Replication estimand — IV vs I.** The paper references its contrasts to Group I
> (obese, low central adiposity). We reproduce that, because reproducing it is what
> *Replicate* means.

Both are contrasts within one fitted model; re-levelling is reparameterization, not
reanalysis. Every estimate we report says which estimand it belongs to. The locked
contrast is the one the term interrogates, because it holds body-mass category fixed and
so isolates central adiposity.

---

## The six criteria

Each claim below is confirmed with a **specific pointer**: a file name, a variable name,
or a number we counted ourselves.

### 1. Reconstructable data — **met**

Six NHANES cycles, all public, no data-use agreement required:

| Cycle | Suffix | Cycle | Suffix |
|---|:--:|---|:--:|
| 2007–2008 | `_E` | 2013–2014 | `_H` |
| 2009–2010 | `_F` | 2015–2016 | `_I` |
| 2011–2012 | `_G` | 2017–2018 | `_J` |

Download pattern:
`https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/<year1>/DataFiles/<COMPONENT>_<suffix>.XPT`

Components we need: `DEMO`, `BMX`, `BPX`, `TRIGLY`, `BIOPRO`, `GHB`, `GLU`, `HDL`,
`TCHOL`, `ALQ`, `SMQ`, `BPQ`, `DIQ`, `MCQ`, `KIQ_U`, `PAQ`, `ALB_CR`, `RXQ_RX`.

Mortality linkage: `NHANES_<cycle>_MORT_2019_PUBLIC.dat` from the NCHS linked mortality
files (fixed-width, public-use).

**Merge key:** `SEQN`, present in every file including the mortality `.dat`.

We downloaded all six cycles and merged them before writing this memo — the funnel in
criterion 4 is counted from our own merged file, not read off the paper.

### 2. A clear exposure and outcome — **met**

**Exposure** — a 2×2 phenotype, not a continuous variable:

- Obesity axis: `BMXBMI` ≥ 30 (≥ 25 if `RIDRETH3` = Asian)
- Central-adiposity axis: WHtR = `BMXWAIST` / `BMXHT` ≥ 0.6

giving Groups I (obese, low central), II (obese, high central), III (non-obese, low),
IV (non-obese, high). Group IV is the paper's headline.

**Outcome** — all-cause mortality: `MORTSTAT` = 1, follow-up time `PERMTH_EXM`, censored
31 December 2019.

**Eligibility** — MASLD by Fatty Liver Index ≥ 60 plus ≥ 1 cardiometabolic criterion.
FLI is computed from `LBXTR` (triglycerides), `LBXSGTSI` (GGT), `BMXBMI` and `BMXWAIST`.

### 3. Plausible confounders — **met**

Measured and available on every cycle:

| Confounder | Variable(s) |
|---|---|
| Age | `RIDAGEYR` |
| Sex | `RIAGENDR` |
| Race / ethnicity | `RIDRETH3` |
| Income-to-poverty ratio | `INDFMPIR` |
| Smoking | `SMQ020`, `SMQ040` |
| Type 2 diabetes | `DIQ010` + `LBXGH` (HbA1c) |
| Hypertension | `BPQ020` + measured `BPXSY1`–`BPXSY4` |
| Kidney function | `LBXSCR` (CKD-EPI 2021), `ALB_CR` (ACR) |
| Medication classes | `RXQ_RX` |

**A judgment we are flagging now, not at M1:** several of these — T2DM, hypertension,
CKD, prior MI — **could be descendants or intermediates under plausible causal
structures, but their causal roles and temporal ordering are not established here.** The
paper adjusts for all of them. We will reproduce that adjustment set because replication
requires it, and we expect to argue at M1 that the crude-to-adjusted attenuation
**cannot be attributed** to confounding control without a prespecified causal model
supporting the adjustment set.
Temporal ordering supports adjusting for age, sex, race, income and smoking without
reservation.

### 4. Adequate size and events — **met, with one caveat**

Counted from our merged file:

| Step | N |
|---|---:|
| All NHANES 2007–2018 records | 59,842 |
| Age ≥ 18 | 36,580 |
| FLI computable (TG, GGT, BMI, waist present) | 14,989 |
| Steatosis, FLI ≥ 60 | 6,376 |
| MASLD (≥ 1 cardiometabolic criterion) | 6,374 |
| Mortality-eligible and linked | **6,371** |

Group sizes **391 / 4,585 / 787 / 608**; **586 deaths**.

That is ample for the main analysis. **The caveat is Group I**, the reference group, at
n = 391. A sex-stratified interaction analysis (P3) splits it further, so stratum-specific
estimates in Group I will be imprecise and we should expect wide confidence intervals
rather than treat them as null findings. We are proceeding, with that stated in advance.

### 5. Design variables — **met**

All present in `DEMO` and `TRIGLY`:

- `WTMEC2YR` — MEC examination weight
- `WTSAF2YR` — **fasting subsample weight**, which is the correct one here, because FLI
  requires fasting triglycerides
- `SDMVSTRA` — stratum
- `SDMVPSU` — primary sampling unit
- `SDDSRVYR` — cycle indicator

Because we pool six two-year cycles, the weight must be divided by 6. The published
analysis appears to be **unweighted**, which is one of the improvements we expect to
propose.

### 6. A genuine incomplete-observation problem — **met**

We claim only that the paper **can support** an incomplete-observation analysis. We do
not claim the problem is large, because we have not yet measured whether it matters.

First, what does **not** count. Four kinds of loss shrink this cohort, and none of them
satisfies criterion 6 on its own, because P5 does not address them with the methods
this course teaches. We must be able to tell each apart from missingness, and at P5 we
report it and scope the conclusion around it.

- **DESIGN.** Fasting laboratory measures come from a **designed** NHANES subsample, and
  `WTSAF2YR` exists precisely to account for that selection stage and its nonresponse.
  Their absence outside the subsample is a design feature, not by itself a missing-data
  problem or evidence of MNAR — and the syllabus is explicit that designed subsampling
  alone does not satisfy this criterion. Inference does remain conditional on the
  weighting assumptions.
- **ELIGIBILITY.** The restriction to adults removes records that were never in scope.
  That states who the paper is about; it is not attrition.
- **TARGET POPULATION.** The steatosis and MASLD criteria remove people without the
  disease. They are not missing — they are **not who the paper is about**.
- **OUTCOME ASCERTAINMENT.** Records that could not be linked or followed for mortality
  were never in a position to carry an outcome value: we count them, report them
  separately, and do not impute them. A record that *was* followed and still lacks an
  outcome value would be missingness, and belongs in the list below.


What does count, measured inside the fasting frame:

- **Item nonresponse on the exposure inputs.** FLI needs triglycerides, GGT, BMI and
  waist. Among the 14,962 adults in the fasting frame, **792 (5.3%)** lack a computable
  FLI. These are people who *were* selected into the subsample and still cannot be
  classified.
- **Residual covariate missingness** within the analytic cohort, on variables the paper's
  own Model 1 uses.
- **A checkable missingness mechanism.** Are the 792 who lack a computable FLI
  systematically different from those who have one? NHANES retains demographic and
  examination data on them, so the MAR argument P5 will need is checkable rather than
  merely assertable. This is a diagnostic on the missingness itself. The selection stage
  upstream of it is DESIGN — handled by `WTSAF2YR` and by a sentence naming who our
  estimate is about, not by anything we would impute.

**We are not arguing from magnitude.** 5.3% is not self-evidently serious, and it may
turn out to change nothing. The criterion asks whether there is a real incomplete-
observation issue that requires explicit assumptions and can support a substantive
sensitivity analysis. There is, and whether it matters is P5's job to measure rather than
ours to presume.

---

## Feasibility verdict

**All six criteria are met.** We are locking this paper.

The thing we already expect to be interesting is that the FLI eligibility index shares
its inputs (BMI and waist) with the exposure definition — cohort selection and exposure
definition are built from the same measurements. That is a candidate threat we will
develop across P1–P5. Which threat actually dominates is a judgment for M1, once all five
increments have been run; naming it now would be guessing.

---

## Cover note

**Contribution.**
AB: data download, merge, funnel counts.
CD: variable mapping for criteria 2–3, confounder table, temporal-ordering argument.
EF: design variables, missingness quantification, memo assembly.

**External feedback.** None received.

**AI Use Statement.**
Tool and version: Claude (Opus 5), used in RStudio and in a browser.
Used for: drafting the download loop across the six cycle suffixes, and for checking the
NHANES variable names for GGT and creatinine against the codebooks.
Not used for: the six eligibility judgments. Each was verified by us against the actual
codebooks and the actual downloaded files, and every N in criterion 4 was counted from
our own merged data. An AI's guess about what NHANES contains is not a feasibility check.
