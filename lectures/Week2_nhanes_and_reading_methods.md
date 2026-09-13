# Week 2 — Six questions for reading a Methods section

Duration: ~2.5 h (Tue, before the Thu lab)

Cap: **150 min**. Markers below total **122**; the remaining ~28 minutes are the room's —
questions, the vote-and-argue moments, and the two live recomputations.

The lecture is one argument, not two halves. It opens with six questions a reader must be
able to answer about any study, then fills them in with the demonstration paper, reaching
for NHANES mechanics **at the point where a question cannot be answered without them**.
The closing M0 section turns the six questions on the students' own candidate papers.

> **Row-set discipline.** Every quantitative slide names the analysis set it is quoting.
> *Analysis set: defined here, then named on every slide that quotes one.*
> The reconstruction has two, and they are not interchangeable:
> **full reconstructed analytic file, N = 6,371** (what scripts 03–06 read) and
> **locked mortality-linked cohort, N = 6,048** (the `WTSAF2YR` subset). Saying "N" without
> saying which is the error this course exists to catch.

## Learning objectives

1. Name the **research goal** a paper is pursuing — description, association, prognostic
   factor, prediction, or causal — and say what evidence that goal would require.
2. Answer the **six questions** for a published study, and show where the paper leaves one
   of them under-specified.
3. Locate any NHANES quantity a study uses: the **component file**, the **variable name**,
   and the **join key**.
4. Distinguish a **design feature** from **missingness**, and a **row set** from a cohort.
5. Say what a crude-to-adjusted change does and does not establish.

## Continuity

- **Last week (Wk1):** reproducibility as a practice, and the course arc.
- **Today:** what a Methods section has to tell you, and whether this one does.
- **Thursday (L1):** build the merged NHANES frame those answers rest on.
- **Toward M0 (Wk3):** ask the same six questions of two or three candidate papers.

---

## Slide 1 — Where we are in the project (3 min)
- Week 1 argued that a result you cannot rebuild is a claim, not a finding.
- Today is the step before rebuilding: knowing **what** you are trying to rebuild.
- By Thursday you need a merged NHANES table; by Week 3 you need a locked paper.

## Slide 2 — Why the question comes before the data (4 min)
- The instinct is to start with "what did they run?". A model family answers nothing on its
  own: a Cox model appears under four different research goals.
- Reading a Methods section is the first act of reproduction. You do it to Kueh today, then
  to your own candidates before Week 3.
- *MASLD hook:* by the end of today you will have watched this paper answer four of the six
  questions clearly, one partially, and one not at all.

## Slide 3 — The six questions (6 min)
1. What is the **research goal**?
2. Who is the **population**, and how is eligibility operationalised?
3. What is the **exposure / index factor**, and the comparison?
4. What is the **outcome**, time zero, and follow-up?
5. What **other variables** enter the analysis, and what role are they supposed to play?
6. What **design and analysis features** must be respected?

- Keep this slide visible: every section below fills one row.
- **If any one is under-specified, the study is not reconstructable — no matter how clean
  the results look.**
- These six are not this paper's; they are the template you take to your own at M0.

---

## Q1 — What is the research goal? · 15 minutes across the slides below

## Slide 4 — The paper states two aims, not one (4 min)
- Aim 1: the **clinical correlates** of four groups defined by BMI and waist-to-height ratio.
- Aim 2: the **prognostic value** of that classification for mortality.
- Related, but not the same question: the first is cross-sectional at baseline, the second
  needs follow-up. One paper can carry more than one research question.

## Slide 5 — Five goals the same variables can serve (5 min)
| Goal | What it asks |
|---|---|
| Description | What are the characteristics and mortality experience of each group? |
| Association | Is phenotype statistically associated with subsequent mortality? |
| Prognostic factor | Does phenotype inform mortality **over and above** other known factors? |
| Prediction | How accurately can we predict an individual's risk; does WHtR improve it? |
| Causal | What would mortality have been under a specified change in central adiposity? |

- The variables can be identical. **The target quantity is not.**

## Slide 6 — Different goals need different evidence (6 min)
- An **HR with a CI** is enough to report an adjusted association or a prognostic effect.
- It is **not** evidence that a prediction model is good — that needs calibration and
  discrimination — and not by itself evidence that a causal effect was identified.
- *MASLD hook:* the paper names "prognostic value" and supplies adjusted association. That
  gap is invisible unless you ask what evidence each goal would require.
- Vote and argue: which row is this paper actually on?

---

## Q2 — Who is the population, and how is eligibility operationalised? · 16 minutes across the slides below

## Slide 7 — NHANES in one picture (5 min)
- Continuous NHANES, released in **2-year cycles**; roughly **5,000 examined persons per
  cycle** after screening; six cycles stacked here (2007–2018).
- Three collection settings, and the distinction matters in a moment:
  **Interview** at home · **MEC exam** (measured body size, blood pressure) · **Laboratory**
  (triglycerides, GGT, glucose; some assays only in the fasting subsample).
- Data arrive as **many small topic files**, not one table.

## Slide 8 — SEQN is the join key (4 min)
- Every respondent has one **SEQN**, the identifier CDC uses to sort and merge NHANES files.
- Analysis = pick the topic files you need, then **merge them on SEQN** into one row per
  person.
- SEQN does **not** repeat across the continuous cycles: all 59,842 values across 2007–2018
  are distinct and the per-cycle ranges do not overlap. Joining on SEQN alone across stacked
  cycles is safe. *Analysis set: all NHANES 2007–2018 records, N = 59,842.*
- Keep a **cycle variable** anyway — provenance, definitions that change between cycles, and
  weights built per cycle. Not to disambiguate SEQN.
- *MASLD hook:* reproducing Table 1 means merging DEMO + BMX + BIOPRO + TRIGLY + ALQ +
  mortality, all keyed on SEQN across six cycles.

## Slide 9 — "MASLD" is a derived variable, not a diagnosis (4 min)
- MASLD = hepatic steatosis **plus** at least one cardiometabolic criterion.
- Gold-standard steatosis is biopsy or imaging. **NHANES has neither** in this window.
- So the paper uses a surrogate: the **Fatty Liver Index**, thresholded at **FLI ≥ 60**,
  computed from **triglycerides, BMI, GGT and waist**.
- The disease definition forces the workaround; it is a feature of the data, not a shortcut.

## Slide 10 — The funnel, with a type on every row (3 min)
| Step | N | Kind of step |
|---|---|---|
| NHANES 2007–2018 records | 59,842 | — |
| Age ≥ 18 | 36,580 | eligibility |
| In fasting subsample | 14,962 | **design** — drops 21,618 |
| FLI computable | 14,170 | missingness |
| Steatosis (FLI ≥ 60) | 6,052 | target population |
| MASLD (≥1 criterion) | 6,050 | target population |
| Mortality-linked | **6,048** | outcome ascertainment |

*Analysis set: locked mortality-linked cohort, N = 6,048.*

- A funnel shows N falling; the **type** column shows why. The largest exclusion is not
  clinical — it is a design feature, because the FLI needs fasting labs.
- Check that the prose arithmetic actually lands on the reported N. Ours does not match the
  paper's ~6,300, and saying so is the work.

---

## Slide 11 — BREAK (10 min)

---

## Q3 — What is the exposure, and the comparison? · 15 minutes across the slides below

## Slide 12 — The exposure is constructed, not measured (5 min)
- Obesity by **BMI ≥ 30** (Asian participants **≥ 25**) × central adiposity by
  **WHtR ≥ 0.60**, giving four phenotype groups.
- Group IV = not obese by BMI, high waist-for-height — the cell the paper is about.
- *MASLD hook:* the exposure spans **two collection settings** — BMI and waist from the MEC
  exam — so a person missing either is missing the exposure.

## Slide 13 — Which group is the comparison? (4 min)
- There is no treated and control arm. The four-category phenotype is the index factor, and
  mortality is compared **across** the categories.
- **Group I is the reference.** Every hazard ratio in the paper is measured against it.
- A ratio without its referent means nothing — and it is counterintuitive here that the
  referent is an obese group.

## Slide 14 — Eligibility and exposure share their inputs (6 min)
| | Inputs |
|---|---|
| Eligibility (FLI) | triglycerides, GGT, **BMI**, **waist** |
| Exposure (phenotype) | **BMI**, **waist** ÷ height |

- Being selected into the study and being placed in a phenotype group are **not independent
  events**. That is **structural dependence**.
- What it does to an estimate depends on the research goal and the causal structure — which
  is Q1's lesson arriving with consequences. We name it today; **M1** dissects it.
- Takeaway for any paper: **never trust a label you have not recomputed.**

---

## Q4 — What is the outcome, time zero, and follow-up? · 11 minutes across the slides below

## Slide 15 — Outcome and the clock (6 min)
- Outcome: **all-cause mortality** (`MORTSTAT`), via the NCHS linked mortality file — not an
  NHANES file, a separate linked, fixed-width one.
- **Time zero is the MEC examination.** `PERMTH_EXM` is person-months from that exam.
- Follow-up runs through **31 December 2019**, stated in the NCHS 2019 Linked Mortality File
  linkage methodology document — not inferred from the filename.
- Participants entered between 2007 and 2018, so follow-up lengths differ. That is why this
  is a survival analysis and not a risk difference.

## Slide 16 — Time zero is a question the checklist never asks (5 min)
- "Exposure, outcome, covariates" can all be specified while time zero stays ambiguous, and
  an ambiguous time zero silently changes who is at risk and for how long.
- *MASLD hook:* exposure here is measured **at** time zero, which is convenient and rare —
  in your own papers, ask when the exposure was measured relative to the clock starting.
- Ask of your M0 candidates: when does follow-up begin, and does everyone start together?

---

## Q5 — What other variables enter, and in what role? · 14 minutes across the slides below

## Slide 17 — In the model is not the same as confounding (6 min)
- The paper adjusts for age, sex, and a list of comorbidities and medications.
- "We adjusted for X" says where X sits in the syntax. It does not say what X **does**.
- The same variable can be a confounder, a mediator, a competing prognostic factor, or a
  collider — and which it is depends on the research goal from Q1.

## Slide 18 — What a crude-to-adjusted change establishes (8 min)
- Group IV all-cause HR ≈ **15.1 crude → ≈ 2.9 adjusted**.
  *Analysis set: full reconstructed analytic file, N = 6,371.*
- Conditioning on the adjustment set moves the estimate enormously. What that movement
  **means** — confounding controlled, mediation removed, a collider opened — depends on the
  goal and on the causal role of those variables.
- **Week 4 does that work.** Today it is enough to see that the size of a move is not itself
  an interpretation.
- Vote and argue: what would you need to know to call this confounding?

---

## Q6 — What design and analysis features must be respected? · 11 minutes across the slides below

## Slide 19 — NHANES is not a simple random sample (5 min)
- A complex multistage probability design: **weights, strata (`SDMVSTRA`), PSUs
  (`SDMVPSU`)**. We *use* them in Week 6; today, note they exist and that ignoring them is a
  choice with consequences.
- Fasting-subsample analyses carry their own weight, **`WTSAF2YR`**, not `WTMEC2YR`.

## Slide 20 — Designed subsampling is not missingness (6 min)
- The fasting subsample is **statistically designed**, not self-selected, and carries a
  weight built to keep it nationally representative.
- Check it rather than assume: adults in and out of it differ by **0.2 years of age,
  0.02 kg/m² of BMI and 0.07 cm of waist**. It is balanced on the very measurements this
  paper's exposure is built from.
  *Analysis set: all NHANES adults 2007–2018, N = 36,580.*
- So the distinction is **designed subsampling ≠ ordinary missingness** — not "the fasting
  subsample is a biased sample".
- *MASLD hook:* the paper's Statistical analysis section never names the survey design. That
  is Q6 answered by omission, and it is the honest finding to report.

---

## Slide 21 — M0: ask the six of your own papers (12 min)
- Shortlist two or three candidate NHANES papers and answer all six questions for each,
  each answer with a pointer to where in the paper you found it.
- **Reconstructable is necessary, not sufficient.** A paper can be perfectly specified and
  still be a bad M0 choice — too few events, no design feature worth respecting, no variable
  whose handling you could interrogate.
- The M0 criteria ask for exactly this: enough observations and events, a design feature its
  analysis must respect, and a missing variable the analysis actually uses.
- Where a paper leaves a question unanswered, that is not a disqualification — it is a
  candidate for the judgement you will defend at M1.

## Slide 22 — Bridge to today's lab (L1) and M0 (5 min)
- **In L1 (Thu):** download several NHANES cycles, read the raw topic files, and merge them
  on `SEQN` into one analytic-ready table with a cycle indicator.
- **How it becomes your project:** L1's merge is the substrate for the whole term — Table 1,
  confounding, interaction, survey weights and missing data all run on it.
- **Toward M0 (Wk3):** bring six answers for each candidate paper, not a summary.
- Takeaway: reading a Methods section *is* the first act of reproduction.

---

## Deliberately deferred

Four things the old Week 2 taught are **not** in the rebuild, and are deferred on purpose
rather than squeezed under a question:

- **The alcohol-exclusion three-way demonstration** (~23 min including live work). It is a
  cohort-construction exercise and Week 3 owns it (`Week3_cohort_construction_FLI.md`). It
  would have been the largest single block in a lecture whose job is a framework.
- **"Table 1 reproduces closely, therefore the variable definitions are recoverable."** The
  inference is exactly what Q5 warns against, and Week 4 carries the careful version.
- **The reading-Methods traps checklist.** Superseded: the six questions are the checklist.
  One line survives at Slide 14 — never trust a label you have not recomputed.
- **The four primitives** (exposure / outcome / eligibility / variables). Kept as an idea,
  demoted from *the* framework to a reconstructability check nested inside Q2–Q5. It never
  asked what kind of question the variables were meant to answer, which is why a
  crude-to-adjusted collapse could be read as settled confounding.

If a later revision wants any of these back, they belong where they are now owned, not
retrofitted into a six-question spine.
