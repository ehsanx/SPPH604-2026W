# Week 2 — Six questions for reading a Methods section

Duration: ~2.5 h (Tue, before the Thu lab)

Cap: **150 min**. Markers below total **144**, leaving ~6 minutes of slack.

> **The timing accounting changed on 2026-09-12.** The previous version marked 122 minutes
> of content and left ~28 minutes unmarked as "the room's". That under-filled a
> 2.5-hour session and hid where the discussion actually goes. The markers below now
> include the interactive moments — the two vote-and-argue slides and the lab preview
> block — so the total is what happens in the room. See *If you are running behind* at the
> foot of this file for the drop order.

The lecture is one argument. The **six questions are the spine**; the NHANES anatomy is
what the answers are **made of**, so the component files, variable names and join key are
taught in full rather than gestured at. A dedicated preview block before the break puts
Thursday's actual L1 code on screen, so the lab is the execution of Tuesday's lecture
rather than a new topic.

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
   and the **join key** — and write the `nhanesA` call that fetches it.
4. Distinguish a **design feature** from **missingness**, and a **row set** from a cohort.
5. Say what a crude-to-adjusted change does and does not establish.

## Continuity

- **Last week (Wk1):** reproducibility as a practice, and the course arc.
- **Today:** what a Methods section has to tell you, whether this one does, and what the
  NHANES files underneath it actually look like.
- **Thursday (L1):** build the merged NHANES frame those answers rest on — previewed here.
- **Toward M0 (Wk3):** ask the same six questions of two or three candidate papers.

---

## Frame · 10 minutes across the slides below

## Slide 1 — Where we are in the project (3 min)
- Week 1 argued that a result you cannot rebuild is a claim, not a finding.
- Today is the step before rebuilding: knowing **what** you are trying to rebuild.
- The six questions are the spine; the NHANES anatomy is what the answers are made of.
- Everything named today — component files, variable names, the join key — is used on
  Thursday in L1 and again for M0.

## Slide 2 — Why the question comes before the data (3 min)
- The instinct is to start with "what did they run?". A model family answers nothing on its
  own: a Cox model appears under several different research goals.
- Reading a Methods section is the first act of reproduction.
- *MASLD hook:* by the end of today you will have watched this paper answer four of the six
  questions clearly, one partially, and one not at all.

## Slide 3 — The six questions (4 min)
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

## Q1 — What is the research goal? · 20 minutes across the slides below

## Slide 4 — The paper states two aims, not one (4 min)
- Aim 1: the **clinical correlates** of four groups defined by BMI and waist-to-height ratio.
- Aim 2: the **prognostic value** of that classification for mortality.
- A two-column table contrasts the question and the **time structure**: cross-sectional at
  baseline versus longitudinal follow-up. One needs the linked mortality file; one does not.

## Slide 5 — Five goals the same variables can serve (4 min)
| Research goal | Scientific target in this example |
|---|---|
| Description | What are the characteristics and mortality experience of each group? |
| Association | Is phenotype statistically associated with subsequent mortality? |
| Prognostic factor | Does phenotype inform mortality **over and above** other known factors? |
| Prediction | How accurately can we predict an individual's risk; does WHtR improve it? |
| Causal | What would mortality have been under a specified change in central adiposity? |

- The variables can be identical. **The target quantity is not.**

## Slide 6 — Same variables, different analyses (4 min)
- One table, five rows: typical analysis for each goal, and how other variables are handled
  under it — stratification, conditional association, other prognostic factors, predictive
  value with shrinkage, confounder selection by causal knowledge.
- **A Cox model appears in several rows. The model family does not determine the goal.**
- This is the slide that kills "they ran a Cox model, so it is an association study".

## Slide 7 — Same variables, different evidence of success (4 min)
- Description: absolute summaries with uncertainty. Association: HR + CI plus assumptions.
- Prognostic factor: adjusted effect, and for *incremental* value a model with versus
  without the factor. Prediction: calibration, discrimination, Brier score, validation.
- Causal: a prespecified contrast, positivity/balance diagnostics, sensitivity analyses.
- Do not rush this table — students reuse it at M0 and M1.

## Slide 8 — HR + CI: what it is, and is not, evidence for (2 min)
- Enough to report an adjusted association or a prognostic-factor effect.
- **Not** evidence that a prediction model is good, and **not** by itself evidence that a
  causal effect was identified.
- *MASLD hook:* the paper names "prognostic value" and supplies adjusted association.

## Slide 9 — What does this paper most directly support? (2 min)
- Directly supports: description; association; an adjusted prognostic association.
- Does not by itself establish: causation; that reducing WHtR would reduce mortality; that
  adding WHtR improves individual prediction.
- **Vote and argue:** which row of the ladder is this paper actually on? Take a show of
  hands before revealing the second half, and do not resolve it too quickly.

---

## Q2 — Who is the population, and how is eligibility operationalised? · 18 minutes for the NHANES anatomy, 14 more after the break

## Slide 10 — First: how NHANES is organised (5 min)
- **Six two-year cycles**, 2007–2018, each with a file suffix: `E F G H I J`. H = 2013–2014,
  I = 2015–2016, J = 2017–2018 — the letters they will type on Thursday.
- Files are **`.XPT`** (SAS transport): `haven::read_xpt()`, or `nhanesA::nhanes()`.
- Each file is **one row per participant for one topic** — not one big table.
- Three collection settings: **Interview** (home) · **MEC exam** (measured body size, blood
  pressure) · **Laboratory** (triglycerides, GGT, glucose).
- Component families: Demographics (`DEMO`) · Examination (`BMX`, `BPX`) · Laboratory
  (`TRIGLY`, `BIOPRO`, `GLU`, `GHB`, `HDL`) · Questionnaire (`ALQ`, `BPQ`, `DIQ`, `SMQ`).
- **Mortality is not an NHANES file.** It is a separate linked, fixed-width file from NCHS.

## Slide 11 — Where the measurements and labs come from (4 min)
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

- Do not read the table aloud. Ask instead which rows the **exposure** is built from and
  which the **eligibility rule** is built from. Both answers are needed in Q3, and the fact
  that the two lists overlap is the whole of Slide 27.

## Slide 12 — Where the questionnaire, design and outcome come from (4 min)
| Concept | NHANES variable | Component |
|---|---|---|
| BP / lipid medication | `BPQ050A`, `BPQ100D` | `BPQ` |
| Diabetes | `DIQ010`, `DIQ050`, `DIQ070` | `DIQ` |
| Alcohol | `ALQ130`, `ALQ120Q`, `ALQ120U`, `ALQ121` | `ALQ` |
| Survey design | `WTMEC2YR`, `WTSAF2YR`, `SDMVSTRA`, `SDMVPSU` | `DEMO`, `TRIGLY` |
| Mortality | `MORTSTAT`, `PERMTH_EXM`, `ELIGSTAT` | linked mortality file |

- These variables alone reach across **seven examination and laboratory components**, plus
  demographics, plus questionnaire components, plus a linked mortality file. **That is what
  L1 assembles.**
- Dwell on the last row: the outcome does not live in NHANES at all. Note too that the
  fasting weight `WTSAF2YR` ships on `TRIGLY` — a design variable living in a lab file.

## Slide 13 — SEQN is the join key (5 min)
- Every respondent has one **SEQN**, the identifier CDC uses to sort and merge NHANES files.
- Analysis = pick the topic files you need, then **merge them on SEQN** into one row per
  person.
- SEQN does **not** repeat across the continuous cycles: all 59,842 values across 2007–2018
  are distinct and the per-cycle ranges do not overlap.
  *Analysis set: all NHANES 2007–2018 records, N = 59,842.*
- The ranges are **not contiguous**: a gap of 1,640 sits between 2011–2012 and 2013–2014,
  so a cycle cannot be recovered arithmetically from an ID.
- Keep a **cycle variable** anyway — provenance, definitions that change between cycles, and
  weights built per cycle. Not to disambiguate SEQN.

---

## Thursday, previewed: L1 builds exactly this · 14 minutes across the slides below

This block is new. It exists because L1 is not "merge on SEQN" — it is a download, a join,
a cycle loop, a stack, a rename, a derivation, a missingness inspection and a descriptive
table. Showing the code before the lab turns Thursday into execution rather than a new
topic, and every line on these four slides uses a name taught on Slides 10–13.

## Slide 14 — L1 in one screen: two files, one key (4 min)
```r
pacman::p_load(tidyverse, nhanesA, tableone, naniar)

demo <- nhanes("DEMO_H", translated = TRUE)   # 2013-2014 demographics
bmx  <- nhanes("BMX_H",  translated = TRUE)   # 2013-2014 body measures

merged <- full_join(demo, bmx, by = "SEQN")
```
- `DEMO_H` and `BMX_H` are the same `DEMO` and `BMX` from Slide 11, cycle **H**.
- `translated = TRUE` turns stored codes into labels. Convenient — and it changes what a
  value *looks like*, so recode rules written against raw codes silently miss.
- **`full_join` keeps people measured in one file but not the other.** A row-set decision
  made by a single word: `inner_join` would be a different study. Ask which verb they want
  and why; there is no universally right answer, which is the point.

## Slide 15 — Then do it for every cycle (4 min)
```r
cycles <- c("H", "I", "J")                     # 2013-14, 2015-16, 2017-18

all_cycles <- lapply(cycles, function(cy) {
  d <- nhanes(paste0("DEMO_", cy), translated = TRUE)
  b <- nhanes(paste0("BMX_",  cy), translated = TRUE)
  full_join(d, b, by = "SEQN") %>% mutate(cycle = cy)
})

stacked <- bind_rows(all_cycles)
```
- `paste0("DEMO_", cy)` is why the suffix table was worth memorising.
- `bind_rows()` stacks cycles; the joins happen **within** a cycle first.
- Our reproduction does the same over all six cycles, `E` through `J`.
- *Flag forward to Q5:* a variable present in later cycles may be absent in earlier ones, so
  a column can appear mid-stack and `bind_rows()` fills the rest with NA. That is a changing
  instrument, not missingness in the usual sense.

## Slide 16 — Raw names in, analysis names out (3 min)
```r
analysis <- stacked %>%
  rename(Sex = RIAGENDR, Age = RIDAGEYR,
         RaceEthnicity = RIDRETH3, BMI = BMXBMI) %>%
  filter(Age >= 20) %>%
  mutate(BMICat = cut(BMI, c(0, 18.5, 25, 30, Inf), right = FALSE,
                      labels = c("Underweight", "Normal weight", "Overweight", "Obese")))
```
- Every rename is a **decision you must be able to defend**, not cosmetics.
- **`right = FALSE` is not optional**, and it is worth thirty seconds. `cut()` defaults to
  right-closed intervals, which would put BMI exactly 30.0 in *Overweight* — the mirror
  image of the WHO convention, of the lab's own code, and of
  `reproduction/R/02_build_analytic.R`. A boundary convention hidden in a default argument
  silently reassigns everyone sitting on a cut-point.
- `BMICat` uses standard WHO cut-points. **The paper does not**: obesity at BMI ≥ 30, and
  ≥ 25 for Asian participants.
- The lab keeps **age ≥ 20**; the paper says **age > 18**; our reproduction uses **≥ 18**.
  **Same variable, three eligibility rules, three different studies.** Record which rule you
  used, every time.

## Slide 17 — Look at what is missing before you model it (3 min)
```r
colSums(is.na(analysis))
naniar::gg_miss_var(analysis, show_pct = TRUE)

tab1_vars <- c("Age", "RaceEthnicity", "BMI", "BMICat")
CreateTableOne(vars = tab1_vars, data = analysis, strata = "Sex",
               addOverall = TRUE, test = FALSE)
```
- Missingness is inspected first, then decided about — never discovered inside a model.
- `CreateTableOne` is the Table 1 they rebuild for the paper's cohort at M1.
- `test = FALSE` on purpose: a p-value comparing baseline groups answers no question anyone
  asked.
- Name what Thursday produces: one merged table, a missingness picture, a descriptive table.
  Week 7 is where the missingness picture becomes a method.

---

## Slide 18 — BREAK (10 min)

---

## Q2, continued — the population this paper defines · 14 minutes across the slides below

## Slide 19 — Population: who is being studied? (3 min)
- Adults with **MASLD** in NHANES 2007–2018: excess liver fat with metabolic dysfunction.
- **But nobody looked at a liver.** Steatosis was estimated by a formula.
- The study population is **not the general population** — everyone in the main analysis
  already meets the study's own definition.
- The hinge: the population is defined by a computation, so it can be recomputed, and
  therefore it can disagree.

## Slide 20 — How MASLD was actually ascertained (4 min)
- Steatosis estimated with the **Fatty Liver Index** (Bedogni 2006), thresholded at
  **FLI ≥ 60**. A small table on the slide gives its four inputs with their component
  files: triglycerides (`LBXTR`, `TRIGLY`), BMI (`BMXBMI`, `BMX`), GGT (`LBXSGTSI`,
  `BIOPRO`), waist (`BMXWAIST`, `BMX`). Say explicitly that these enter a published
  logistic formula and are **not multiplied together** — the slide used to present them
  `·`-separated, which reads as a product.
- Plus **at least one of five cardiometabolic criteria**: adiposity; raised glucose/HbA1c or
  diabetes; raised blood pressure or treatment; raised triglycerides or treatment; low HDL.
- So MASLD here is a **derived variable, not a diagnosis** — no imaging, no biopsy.
- Not a criticism: every population study of MASLD in NHANES this decade faces the same
  constraint. What matters is that eligibility is *computed*, from four named variables in
  three different component files — two of which return in Q3 as the exposure.

## Slide 21 — The funnel, with a type on every row (4 min)
| Step | N | Kind of step |
|---|---|---|
| NHANES 2007–2018 records | 59,842 | — |
| Age ≥ 18 | 36,580 | eligibility — drops 23,262 |
| In fasting subsample | 14,962 | **design** — drops 21,618 |
| FLI computable | 14,170 | missingness |
| Steatosis (FLI ≥ 60) | 6,052 | target population — drops 8,118 |
| MASLD (≥1 criterion) | 6,050 | target population |
| Mortality-linked | **6,048** | outcome ascertainment |

*Analysis set: locked mortality-linked cohort, N = 6,048.*

- A funnel shows N falling; the **type** column shows why, and the types are not
  interchangeable.
- **Scope the claim exactly.** The age criterion removes more people than anything else
  (23,262), but that is the study's own eligibility rule. **After eligibility**, the two
  largest drops are **design** (the fasting subsample, 21,618) and the **disease
  definition** (8,118) — and neither is missing data. The printed drops are on the table so
  a student can check the sentence rather than take it on trust.
- This scoped form is the course-wide wording: `reproduction/reproduction_report.md`,
  `Week7_missing_slides.qmd`, the M1 deck and the P1 exemplar all state it this way. An
  unscoped "the largest single exclusion is design" is false against this table.
- Name the row-set label and say why it is there: the full reconstructed file is 6,371.

## Slide 22 — What the funnel reveals (3 min)
- The published paper reports **~6,300** participants with MASLD; this pipeline yields
  **6,048** mortality-linked participants. *Analysis set: locked mortality-linked cohort,
  N = 6,048.* The two should not be presented as the same cohort.
- The paper states eligibility as **age > 18**; this reproduction uses **age ≥ 18**. Small
  implementation differences are **recorded, not silently harmonised**.
- Tie back to Slide 16: they have just seen three age rules on one slide. A reproduction
  that quietly adopts the other rule has destroyed its own evidence.

---

## Q3 — What is the exposure, and the comparison? · 16 minutes across the slides below

## Slide 23 — The exposure is constructed, not measured (3 min)
- `BMXWAIST` ÷ `BMXHT` → **waist-to-height ratio**; `BMXBMI` → **obesity category**; the two
  categories crossed → **four phenotype groups**.
- All three inputs come from **one component, `BMX`**, in the MEC exam — so a person missing
  the exam is missing the exposure entirely.
- **Contrast with eligibility**, which needs `BMX` *and* the laboratory (`LBXTR`,
  `LBXSGTSI`). Eligibility spans two collection settings; the exposure does not.
- *Correction:* an earlier version of this deck said the **exposure** spanned two settings.
  It does not. Eligibility does.

## Slide 24 — Exposure component 1: BMI (4 min)
- Weight and height were **measured** in the exam, not self-reported (`BMXBMI`).
- BMI marks overall body size — not body fat, and not where fat is stored.
- Obesity defined as **BMI ≥ 30**; for Asian participants **BMI ≥ 25** (`RIDRETH3 == 6`).
- **Paper reporting note:** the Methods define obesity as BMI ≥ 30 (≥ 25 for Asian
  participants), but published Tables 1–2 label the groups as BMI ≥ 25 versus < 25. Those
  labels conflict with the Methods *and* with the reported group BMI distributions, so they
  appear to be a reporting error.
- Ask which version they would implement, and how they would say so in writing. Flag
  `RIDRETH3` — it returns on Slide 32.

## Slide 25 — Exposure component 2: waist-to-height ratio (2 min)
- WHtR = waist (cm) / height (cm) = `BMXWAIST` / `BMXHT`. A person 170 cm tall with a 102 cm
  waist has WHtR = 0.60 — worked on screen so the threshold stops being abstract.
- High central adiposity defined as **WHtR ≥ 0.60**; a simple marker of abdominal adiposity,
  not a CT or MRI measurement of visceral fat.

## Slide 26 — The exposure is the combination (4 min)
|  | WHtR < 0.60 | WHtR ≥ 0.60 |
|---|---|---|
| **Obesity by BMI** | **Group I** — *reference* | **Group II** |
| **No obesity by BMI** | **Group III** | **Group IV** |

- **Group IV** — not obese by BMI, large waist for height. The study asks whether BMI alone
  misses this higher-risk phenotype.
- There is no treated arm and control arm: the four-category phenotype is the **index
  factor**, and mortality is compared **across** the categories.
- **Group I is the reference.** A ratio without its referent means nothing — and here the
  referent is an **obese** group. Make them say the Group IV versus Group I contrast aloud.

## Slide 27 — Eligibility and exposure share their inputs (3 min)
|  | Inputs |
|---|---|
| Eligibility (FLI ≥ 60) | triglycerides, GGT, **BMI**, **waist** |
| Exposure (phenotype) | **BMI**, **waist** ÷ height |

- Being selected into the study and being placed in a phenotype group are **not independent
  events**. That is **structural dependence**.
- For a causal question, conditioning on this selected population could open selection or
  collider paths under some structures; for a prognostic question, it primarily defines a
  selected target population. Not automatically circularity, not automatically bias.
- We name it today; **M1** dissects it. Takeaway: **never trust a label you have not
  recomputed.**

---

## Q4 — What is the outcome, time zero, and follow-up? · 11 minutes across the slides below

## Slide 28 — Outcome and the clock (6 min)
- Outcome: **all-cause mortality** (`MORTSTAT`), via the NCHS linked mortality file — not an
  NHANES file, a separate linked, fixed-width one.
- **Time zero is the MEC examination.** `PERMTH_EXM` is person-months from that exam.
- Follow-up runs through **31 December 2019**, stated in the NCHS 2019 Linked Mortality File
  linkage methodology document — not inferred from the filename. That sourcing is the
  standard we ask of them.
- Participants entered between 2007 and 2018, so **follow-up lengths and censoring differ**.
  Time-to-event methods are appropriate — and a **risk difference at a fixed horizon can
  still be estimated** with methods that account for censoring.
- *Correction:* an earlier version said differing follow-up meant "survival analysis, not a
  risk difference". Differing follow-up forbids a *naive* absolute contrast, not an absolute
  contrast.

## Slide 29 — Time zero is a question the checklist never asks (5 min)
- "Exposure, outcome, covariates" can all be specified while time zero stays ambiguous, and
  an ambiguous time zero silently changes who is at risk and for how long.
- *MASLD hook:* exposure here is measured **at** time zero, which is convenient and rare.
- Ask of your M0 candidates: when does follow-up begin, and does everyone start together?
  A show of hands on whether their candidates state it is worth the thirty seconds.

---

## Q5 — What other variables enter, and in what role? · 15 minutes across the slides below

## Slide 30 — In the model is not the same as confounding (4 min)
- The paper adjusts for age, sex, and a list of comorbidities and medications.
- "We adjusted for X" says where X sits in the syntax. It does not say what X **does**.
- The same variable can be a confounder, a mediator, a competing prognostic factor, or a
  collider — and which it is depends on the research goal from Q1. Under a prognostic-factor
  question the adjustment set need not be confounders at all.

## Slide 31 — What a crude-to-adjusted change establishes (5 min)
- Group IV all-cause HR ≈ **15.1 crude → ≈ 2.9 adjusted**.
  *Analysis set: full reconstructed analytic file, N = 6,371.*
- Conditioning on the adjustment set moves the estimate enormously. What that movement
  **means** — confounding controlled, mediation removed, a collider opened — depends on the
  goal and on the causal role of those variables.
- **Week 4 does that work.** Today it is enough to see that the size of a move is not itself
  an interpretation.
- **Vote and argue:** what would you need to know to call this confounding? Collect answers;
  resist supplying one.

## Slide 32 — Five NHANES traps, each of which has bitten this project (3 min)
- **`ALQ130` is drinks per *drinking day*, not drinks per day.** The paper's ">2 drinks a
  day" is an average intake — frequency × quantity. Applying the rule to `ALQ130` directly
  over-excluded roughly **2,000** people here. **Week 3 owns the full demonstration.**
- **777 = refused, 999 = don't know.** Codes, not counts. Left inside a threshold rule they
  reclassified **nine** refusals as heavy drinkers (the exclusion moves 2,063 → 2,072).
- Keep those two bullets **separate**. An earlier version of this slide fused them and
  attached the 2,000 to the reserved codes — wrong by a factor of two hundred, and the sort
  of error this course exists to catch.
- **`RIDRETH3` does not exist before 2011.** It identifies Asian participants for the lower
  BMI threshold, so the first two cycles cannot apply the paper's own rule. A definition
  that cannot be applied in a third of your cycles is a finding, not a nuisance.
- **Fasting labs carry their own weight:** `LBXTR` and `LBXGLU` come from the fasting
  subsample, weighted by `WTSAF2YR`, not `WTMEC2YR`.
- **Blood pressure is not a row mean** — next slide.
- These sit under Q5 rather than in a separate tips section because each is a
  variable-handling decision.

## Slide 33 — The blood pressure trap, in full (3 min)
- The NHANES **Blood Pressure Procedures Manual (s3.1.7.3)** specifies the averaging: the
  **first reading is excluded** whenever more than one was obtained; an **all-zero diastolic
  set averages to zero**, because a diastolic 0 is a measurement and a failure to obtain a
  reading is coded separately as missing; and a **zero beside a positive reading is omitted**.
- Applying it changed derived SBP/DBP for **5,523 of 6,371** participants and moved
  hypertension from 3,444 to 3,448, while adjusted hazard ratios shifted only in the third
  significant figure. *Analysis set: full reconstructed analytic file, N = 6,371.*
- **A coding error can be real, and worth fixing, even when the headline estimate survives.**
- The paper does not specify its own averaging in enough detail to establish that it used
  this algorithm, so ours is a documentation-informed choice, not a claim of exact
  computational reproduction.

---

## Q6 — What design and analysis features must be respected? · 10 minutes across the slides below

## Slide 34 — NHANES is not a simple random sample (3 min)
- A complex multistage probability design: **weights, strata (`SDMVSTRA`), PSUs
  (`SDMVPSU`)**. We *use* them in Week 6; today, note they exist and that ignoring them is a
  choice with consequences.
- Fasting-subsample analyses carry their own weight, **`WTSAF2YR`**, not `WTMEC2YR`.
- Build the design on the **full frame**, then `subset()` — never on the subsample alone.
  The single most common survey-analysis error, worth planting now.

## Slide 35 — Designed subsampling is not missingness (4 min)
- The fasting subsample is **statistically designed**, not self-selected, and carries a
  weight built to keep it nationally representative.
- Check it rather than assume: adults in and out of it differ by **0.2 years of age,
  0.02 kg/m² of BMI and 0.07 cm of waist**. It is balanced on the very measurements this
  paper's exposure is built from. *Analysis set: all NHANES adults 2007–2018, N = 36,580.*
- So the distinction is **designed subsampling ≠ ordinary missingness**. That it was
  *checked*, rather than assumed in either direction, is the transferable habit.

## Slide 36 — Survey design: paper versus reproduction (3 min)
- The published paper's Statistical analysis section **does not report** using NHANES survey
  weights, strata or PSUs. Our pipeline does include them.
- Therefore a survey-weighted rebuild is a **design-informed reanalysis**, not a literal
  reproduction of every published analytic choice.
- Without the design information, estimates and standard errors should not be described as
  design-based nationally representative estimates.
- *MASLD hook:* this is Q6 answered by omission — a documented divergence that is neither
  our error nor theirs, and the honest move is to label it as one.

---

## Closing · 6 minutes across the slides below

## Slide 37 — PECOT, and the question rebuilt (2 min)
| Element | This study |
|---|---|
| **P** — Population | Adults with MASLD by FLI ≥ 60 + ≥1 cardiometabolic criterion, in the fasting subsample |
| **E** — Exposure | Four-category BMI × WHtR phenotype |
| **C** — Comparison | Groups II, III, IV versus **Group I** |
| **O** — Outcome | All-cause mortality to 31 Dec 2019 |
| **T** — Time | Months from exam to death or censoring |

- *Among adults with MASLD, are BMI/WHtR phenotypes associated with different subsequent
  risks of all-cause mortality?* That sentence is the deliverable shape for M0.

## Slide 38 — M0: ask the six of your own papers (2 min)
- Shortlist two or three candidate NHANES papers and answer all six questions for each, each
  answer with a pointer to where in the paper you found it.
- **Reconstructable is necessary, not sufficient.** A paper can be perfectly specified and
  still be a bad M0 choice — too few events, no design feature worth respecting, no variable
  whose handling you could interrogate.
- Where a paper leaves a question unanswered, that is not a disqualification — it is a
  candidate for the judgement you will defend at M1.
- If you are ahead of schedule, work one candidate live. It is the best use of spare minutes.

## Slide 39 — Bridge to L1 and M0 (2 min)
- **Thursday (L1):** the code from before the break — several cycles downloaded, topic files
  read, merged on `SEQN`, renamed, categorised, missingness inspected, Table 1 built.
- **Before you go:** you should be able to name the component file each variable on these
  slides comes from. Ask two or three at random on the way out.
- **Toward M0 (Wk3):** bring six answers for each candidate paper, not a summary.
- Takeaway: reading a Methods section *is* the first act of reproduction.

---

## If you are running behind

Drop in this order. Each is a slide whose content is carried elsewhere in the course, so
cutting it costs continuity rather than a concept:

1. **Slide 7** (different evidence of success, 4 min) — Slide 8 states its one-line version.
2. **Slide 25** (WHtR, 2 min) — the ratio is defined again on Slide 26's table header.
3. **Slide 6** (different analyses, 4 min) — painful, but Slide 5 carries the distinction.
4. **Slide 33** (the blood pressure trap, 3 min) — Slide 32's blood-pressure bullet
   survives alone. (Named, not numbered: the bullet's position moved once already.)
5. **Slide 22** (what the funnel reveals, 3 min) — Week 3 revisits the cohort arithmetic.

Do **not** cut Slides 14–17. The lab preview is the reason this deck was rebuilt, and
dropping it puts students into L1 cold.

---

## Deliberately deferred

Three things the old Week 2 taught are **not** here, and are deferred on purpose rather
than squeezed under a question:

- **The alcohol-exclusion three-way demonstration** (~23 min including live work). It is a
  cohort-construction exercise and Week 3 owns it (`Week3_cohort_construction_FLI.md`). Its
  residue survives as the **two alcohol bullets** on Slide 32 — the `ALQ130`
  drinks-per-drinking-day trap and the 777/999 reserved-code trap — which name the two
  errors and their sizes without running the demonstration.
- **"Table 1 reproduces closely, therefore the variable definitions are recoverable."** The
  inference is exactly what Q5 warns against, and Week 4 carries the careful version.
- **The four primitives** (exposure / outcome / eligibility / variables). Kept as an idea,
  demoted from *the* framework to a reconstructability check nested inside Q2–Q5. It never
  asked what kind of question the variables were meant to answer, which is why a
  crude-to-adjusted collapse could be read as settled confounding.

The **reading-Methods traps checklist** is no longer listed as deferred: the NHANES traps
now have their own slides under Q5, and the six questions are the reading checklist.

If a later revision wants any of the three back, they belong where they are now owned, not
retrofitted into a six-question spine.

---

## Relationship to the companion deck

`lectures/bmj_open_revealjs/` — *Decomposing the Study Aim* — is the standalone deck this
rebuild draws its NHANES anatomy, PECOT and goal-ladder material from. It remains published
as a companion for students who want the aim-decomposition argument on its own, without the
six-question scaffolding or the lab preview. **Where the two disagree, this file wins.**

Two errors were corrected during this rebuild. **Neither is in the companion today**, but
they reached Week 2 by different routes, and the difference matters — an inherited error
attributed to the wrong source cannot be traced:

- **The exposure spans one collection setting, not two** (Slide 23). This one was never in
  the companion, which makes no collection-settings claim about the exposure at all. It was
  introduced by the previous Week 2 rewrite (`c782167`).
- **Differing follow-up permits an absolute contrast** computed with censoring in mind, and
  forbids only a naive one (Slide 28). This one **was inherited from the companion**, which
  carried "survival analysis and not a risk difference" in its first version (`02e50be`)
  until `ae5e3ef` corrected it. The previous Week 2 rebuild copied the *pre-correction*
  wording an hour and a half later — a fix that lands in one file and not in its copy is
  exactly how a corrected error comes back.

One claim **was** wrong in the companion and has been fixed there in the same change: its
funnel slide called the fasting subsample "the largest single exclusion", which is false
against its own table. It now carries the course-canonical *after eligibility* scoping, and
its fused `ALQ130` / 777-999 trap bullet has been split the same way as Slide 32's.
