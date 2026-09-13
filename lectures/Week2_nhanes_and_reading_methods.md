# Week 2 Lecture Plan — Survey Data Sources & Reading a Methods Section Critically

Duration: ~2.5 h (Tue, before the Thu lab)

Timing: the per-slide markers below sum to ~105 min, including the 10-min break. The
remaining ~45 min of the session is live work and discussion on the material already
here, not extra content:

- ~15 min at **Slide 13** — code the alcohol-exclusion sentence three ways on screen and
  show the three N's it produces. The slide names the discrepancy; this is the time to
  demonstrate it rather than assert it.
- ~8 min at **Slide 15** — stating all six M0 criteria, rather than the four-box screen
  alone, does not fit that slide's 7-min marker.
- ~7 min for the two prompts the deck already carries: the imputation question in the
  Slide 6 notes, and reading the Kaplan-Meier panel on the Slide 11 exposure slide.
- ~15 min of Q&A and buffer, distributed across the session and weighted to the second
  half, where students meet the four-primitive template for the first time.

## Learning objectives
- Describe NHANES structure: 2-year cycles, the interview/MEC/lab components, the SEQN merge key, and the fasting subsample.
- Explain why MASLD is a *surrogate-defined* outcome here (Fatty Liver Index), and what non-invasive scores buy and cost.
- Read a Methods section to extract the four reproducibility primitives: exposure, outcome, eligibility, variables.
- State the six M0 feasibility criteria, and place the four reproducibility primitives correctly inside them: reconstructability is the pre-screen, not the whole gate.
- Anticipate the L1 workflow: download multiple NHANES cycles and merge them on SEQN.

## Continuity
- Recap Wk1: the term is a term-long NHANES project — Replicate -> Interrogate -> Improve -> Defend — anchored to one demonstration paper (Kueh 2026, MASLD phenotypes and mortality).
- Last week we met the paper and the arc; today we open the *data engine* underneath it (NHANES) and learn to read a Methods section the way a replicator does.
- Sets up Thu L1 (multi-cycle download + merge on SEQN) and M0 (each student shortlists candidate papers to replicate).

## Slide 1 — Where we are in the project (3 min)
- One-line map of the term: Replicate (Wk2-8) -> Interrogate -> Improve -> Defend; milestones M0 (Wk3) through M4 (Dec).
- Today's job: understand the data source and learn to *strip a Methods section for parts*.
- Flag the two deliverables this week feeds: L1 (Thu) and M0 shortlisting (due Wk3).

## Slide 2 — Why start with the data source (4 min)
- You cannot judge or reproduce a study you don't understand at the data level; the Methods section is a *promise* about data you must be able to keep.
- NHANES is public, documented, and versioned — ideal for a replication course.
- MASLD hook: Kueh 2026 uses NHANES 2007-2018 (six cycles) — every number we will reproduce traces back to public files.

## Slide 3 — NHANES in one picture (8 min)
- Continuous NHANES released in **2-year cycles** (2007-08, 2009-10, ... 2017-18); ~5,000 examined persons per cycle after screening.
- Nationally representative of the civilian non-institutionalized US population via a complex multistage design (we USE weights in Wk6; today just note they exist).
- Data arrive as many small files by topic, not one table.
- MASLD hook: "2007-2018" = six cycles stacked; combining cycles is why the analytic N runs to several thousand — the paper reports ~6,300 and our reproduction's full analytic file lands on 6,371.

## Slide 4 — The three data-collection settings (7 min)
- **Interview (questionnaire)** at home: demographics, income, alcohol, medical history.
- **MEC exam** (Mobile Examination Center): physical measures — BMI, waist circumference, blood pressure.
- **Laboratory**: blood draws — triglycerides, GGT, glucose; some assays only in the **fasting subsample**.
- MASLD hook: FLI needs triglycerides + GGT (lab) + BMI + waist (MEC) — the exposure spans *two* settings, so a person missing either is missing the exposure.

## Slide 5 — SEQN: the key that holds it together (7 min)
- Every respondent has one **SEQN** (respondent sequence number) — the identifier CDC uses to sort and merge NHANES files.
- Analysis = pick the topic files you need, then **merge them on SEQN** into one row-per-person table.
- SEQN does **not** repeat across the continuous cycles. The six 2007–2018 cycles occupy contiguous, non-overlapping ranges (41,475 → 102,956) and all **59,842 values are distinct**, so joining on SEQN alone across stacked cycles is safe — which is exactly what our reproduction pipeline does.
- Keep a **cycle variable** anyway: for provenance, for harmonising definitions that change between cycles, and because the weights are built per cycle. Not to disambiguate SEQN.
- MASLD hook: reproducing Table 1 means merging DEMO + BMX + BIOPRO + TRIGLY + ALQ + mortality, all keyed on SEQN across six cycles.

## Slide 6 — The fasting subsample (and why it will haunt us) (7 min)
- Some labs (fasting glucose, triglycerides for the calculation path) are collected only in the morning fasting subsample -> smaller N with its own weight (WTSAF).
- It is a **statistically designed subsample**, not a self-selected one, and it carries its own weight (`WTSAF2YR`) built to keep it nationally representative.
- Check it rather than assume it: among adults, those in and out of the fasting subsample differ by **0.2 years of age, 0.02 kg/m² of BMI and 0.07 cm of waist**. It is balanced on the very measurements this paper's exposure is built from.
- So the Week 2 distinction is **designed subsampling ≠ ordinary missingness** — *not* “the fasting subsample is a biased sample.”
- MASLD hook: FLI needs fasting labs, so it is computable only in NHANES' **designed fasting subsample**. That absence is a *design* feature with its own weight (`WTSAF2YR`), **not** ordinary missingness. Park the distinction — it is the spine of Weeks 3, 6 and 7.

## Slide 7 — What "MASLD" actually is (6 min)
- MASLD = metabolic dysfunction-associated steatotic liver disease (the 2023 rename of NAFLD): hepatic steatosis **+** >= 1 cardiometabolic criterion.
- Gold-standard steatosis = biopsy or imaging — neither exists in NHANES for this window.
- So the paper needs a *surrogate* for "fatty liver."
- MASLD hook: the disease definition itself forces a non-invasive workaround — this is a feature of the data, not a shortcut by the authors.

## Slide 8 — Surrogate-defined outcomes: the Fatty Liver Index (8 min)
- FLI is a published score from **triglycerides, BMI, GGT, waist circumference**; Kueh uses **FLI >= 60** to call steatosis.
- Non-invasive scores make population studies possible but embed their inputs into the case definition.
- MASLD hook — plant the seed for M1: the phenotype groups are built from **BMI x waist (WHtR)**, and FLI eligibility *also* uses BMI + waist. Exposure and cohort selection share inputs -> **circularity**. We only name it today; we dissect it at M1.

## Slide 9 — BREAK (10 min)

## Slide 10 — From data source to a reproducible study: the four primitives (6 min)
- To reproduce any paper you must extract four things from the Methods: **Exposure, Outcome, Eligibility, Variables (confounders/covariates)**.
- If any one is under-specified, the study is not reconstructable — no matter how clean the results look.
- Frame the rest of the lecture as filling this 4-box template for Kueh 2026.
- MASLD hook: we will find that three of the four boxes are clear and one (eligibility) is *internally contradictory*.

## Slide 11 — Extract the EXPOSURE (5 min)
- Exposure = four phenotypes from obesity (BMI >= 30) x central adiposity (WHtR >= 0.6): I obese/low-central, II obese/high-central, III non-obese/low-central, IV non-obese/high-central.
- Ask: are the cut-points, variables, and coding fully stated? Mostly yes.
- MASLD hook: the paper's group sizes are 386 / 4,541 / 769 / 604; our reproduction gives 391 / 4,585 / 787 / 608. Either way Group IV (non-obese, high-central) has the **worst** survival — the paper's headline.

## Slide 12 — Extract the OUTCOME and follow-up (5 min)
- Outcome = all-cause mortality via NHANES linked mortality files; time-to-event with median follow-up ~6.7 y.
- Ask: mortality source, censoring date, and time origin all stated? Yes — linked NDI is standard and documented.
- MASLD hook: the paper counts 585 all-cause deaths and our reproduction 586; Group IV unadjusted HR ~15.1 collapses to ~2.9 after adjustment. Conditioning on the adjustment set moves the estimate enormously. What that movement *means* — confounding controlled, mediation removed, or a collider opened — depends on the research goal and on the causal role of those variables. **Wk4 does that work; today we only note the size of the move.**

## Slide 13 — Extract ELIGIBILITY — and read it adversarially (8 min)
- Eligibility = adults with MASLD (FLI >= 60 + >= 1 cardiometabolic criterion), with stated alcohol and missingness exclusions.
- Reading critically means checking that the prose *arithmetic* actually lands on the reported N.
- MASLD hook — two real discrepancies to show on screen:
  - The alcohol-exclusion sentence, coded three plausible ways, yields **N = 4,308 / 5,944 / 6,371** — the text does not pin down the cohort.
  - Table headers mislabel the BMI cut as "<25" when the analysis actually uses **30**. Same idea, opposite lesson: never trust a label you haven't recomputed.

## Slide 14 — Extract the VARIABLES (confounders & covariates) (5 min)
- Variables = age, sex, race/ethnicity, income, smoking, comorbidities — each must map to a specific NHANES file/field.
- Ask: is every adjustment variable named precisely enough to pull it? Mostly, but income has ~9% missing (a Wk7 thread).
- MASLD hook: reproduced Table 1 matches closely (mean age ~51, BMI ~33.2) — evidence the variable definitions are recoverable even where the eligibility prose is not.

## Slide 15 — M0 feasibility: reconstructable is necessary, not sufficient (7 min)
- The four-box template is a **reconstructability pre-screen**. If a replicator cannot fill all four from public data + the Methods alone, the paper is not reconstructable and nothing else about it matters:
  - Public, obtainable data source (ideally NHANES) with a stated version/cycles.
  - Exposure & outcome defined with explicit variables and cut-points.
  - Eligibility that resolves to a countable N (flag contradictions early — they are *interrogation fuel*, not disqualifiers).
  - Named confounders that map to real fields.
- **Passing the screen is necessary but not sufficient.** M0 has six criteria and the four boxes reach only the first three — (1) reconstructable data, (2) a clear exposure and outcome, (3) plausible confounders. Three more must also hold, and a beautifully written paper can fail every one of them:
  - **(4) Adequate size and events** — enough observations, and for time-to-event outcomes enough events, for the main analysis *and* at least one subgroup or interaction analysis to be stable.
  - **(5) Design variables** — name the design feature the analysis has to respect and the variables that encode it: survey weights/strata/PSU, a cluster or repeated-measure identifier, or follow-up time and censoring. Not waivable; a paper with no design feature to respect has nothing to re-estimate at P4.
  - **(6) A genuine incomplete-observation problem** — a variable the locked analysis actually uses that is absent for records which should have carried it. Cohort shrinkage from designed subsampling, eligibility or the disease definition is not this, and does not satisfy the criterion on its own.
- A little ambiguity is fine — it is exactly what M1 interrogates; *total* under-specification is not.
- Each criterion is confirmed in the memo with a specific pointer — a variable name, a file name, a number — not an assertion; the M0 brief carries the full wording.
- MASLD hook: Kueh 2026 clears all six — the four boxes *and* size, design and missingness — which is why it can carry P1-P5. It also hands us a rich interrogation agenda: the model of a good replication target.

## Slide 16 — Common traps when reading Methods (4 min)
- Labels vs. computations (the "<25 = 30" trap); prose arithmetic that never sums to the reported N.
- Silent design choices: unweighted analysis of a survey; a fasting-only exposure treated as if universal.
- "Defined by" scores whose inputs overlap the exposure (circularity) — a smell to log now, test at M1.
- MASLD hook: every trap on this slide is one the demonstration paper actually contains.

## Slide 17 — Bridge to today's lab (L1) and your project increment (5 min)
- **In L1 (Thu, EpiMethods wrangling module):** you will download several NHANES cycles (2007-2018), read the raw topic files (DEMO, BMX, lab files), and **merge them on SEQN** into one analytic-ready, one-row-per-person table — adding a cycle indicator before stacking. Output: a merged multi-cycle dataset you can count and describe.
- **How it becomes your increment:** L1's merge is the substrate for the whole term — every later lab (Table 1, confounding, interaction, survey weights, missing data) runs on the table you build Thursday.
- **M0 shortlisting (toward Wk3 lock):** using today's four-primitive template + the M0 feasibility criteria, shortlist 2-3 candidate NHANES papers of your own. For each, be ready to say whether exposure/outcome/eligibility/variables are extractable — that is the pre-screen — *and* whether the paper has enough observations and events, a design feature its analysis must respect, and a missing variable the analysis actually uses. All six criteria, each with a pointer. You lock one paper at M0 (Wk3).
- Takeaway: reading a Methods section *is* the first act of reproduction — you did it to Kueh today; do it to your candidates before Wk3.
