# Document index

> Every item below ships as **HTML** (read in the browser) and **PDF** (download).
> You do not need R, Quarto, Pandoc or LaTeX to read anything in this repository.

Everything in this repository, in one place. Links are relative, so they work on the course site, while browsing on GitHub,
and after cloning.

Canvas carries **submissions and grading**, and also the things the syllabus points there
for: the rubric grids, weekly chapter signposts, Zoom links, AI-use examples and the
weekly Modules. This repository holds the course materials themselves.

---

## Start of term

| | |
|---|---|
| [Syllabus](syllabus/SPPH604-syllabus-2026W.pdf) | Authoritative on deadlines, weights and policy |
| [L0 — Setup](labs/L0_setup.md) | **Do this before the first class.** R, RStudio, TinyTeX, GitHub, test knit |
| [Practice overview](practice/README.md) | How P1–P5 build into M1 |
| [Licence](LICENSE.md) | CC BY 4.0, with named carve-outs |
| [All compiled artifacts](ARTIFACTS.md) | Every document, with its HTML and PDF |

---

## Weekly work

### Labs — in person, weekly

Graded **Complete / Incomplete**. Day, room and due dates are in the syllabus.

| Lab | Topic | Read | Download | Source | Feeds |
|---|---|:--:|:--:|:--:|:--:|
| **L0** | Setup — do this before the first class | [HTML](labs/L0_setup.html) | [PDF](labs/L0_setup.pdf) | [md](labs/L0_setup.md) | — |
| **L1** | NHANES data wrangling | [HTML](labs/L1_data_wrangling.html) | [PDF](labs/L1_data_wrangling.pdf) | [md](labs/L1_data_wrangling.md) | — |
| **L2** | NHANES–mortality linkage | [HTML](labs/L2_nhanes_mortality.html) | [PDF](labs/L2_nhanes_mortality.pdf) | [md](labs/L2_nhanes_mortality.md) | P1 |
| **L3** | Confounding & collapsibility | [HTML](labs/L3_confounding.html) | [PDF](labs/L3_confounding.pdf) | [md](labs/L3_confounding.md) | P2 |
| **L4** | Effect modification & interaction | [HTML](labs/L4_interaction.html) | [PDF](labs/L4_interaction.pdf) | [md](labs/L4_interaction.md) | P3 |
| **L5** | Complex survey analysis | [HTML](labs/L5_survey_analysis.html) | [PDF](labs/L5_survey_analysis.pdf) | [md](labs/L5_survey_analysis.md) | P4 |
| **L6** | Missing data & multiple imputation | [HTML](labs/L6_missing_data.html) | [PDF](labs/L6_missing_data.pdf) | [md](labs/L6_missing_data.md) | P5 |

### Practice increments — optional, ungraded

The same method applied to **your** paper. No deadline, not submitted, not marked — but
M1 is assembled from these five, and they are the practice you draw on at M2 and M3.

| | Topic | Read | Download | Source | Model answer |
|---|---|:--:|:--:|:--:|---|
| **P1** | Analytic cohort | [HTML](practice/P1_analytic_cohort.html) | [PDF](practice/P1_analytic_cohort.pdf) | [md](practice/P1_analytic_cohort.md) | [example](examples/P1_analytic_cohort/) |
| **P2** | Confounding & Table 1 | [HTML](practice/P2_confounding_diagnostic.html) | [PDF](practice/P2_confounding_diagnostic.pdf) | [md](practice/P2_confounding_diagnostic.md) | [example](examples/P2_confounding/) |
| **P3** | Effect modification | [HTML](practice/P3_effect_modification.html) | [PDF](practice/P3_effect_modification.pdf) | [md](practice/P3_effect_modification.md) | [example](examples/P3_effect_modification/) |
| **P4** | Design-aware estimate | [HTML](practice/P4_design_aware_estimate.html) | [PDF](practice/P4_design_aware_estimate.pdf) | [md](practice/P4_design_aware_estimate.md) | [example](examples/P4_design_aware/) |
| **P5** | Missing-data sensitivity | [HTML](practice/P5_missing_data.html) | [PDF](practice/P5_missing_data.pdf) | [md](practice/P5_missing_data.md) | [example](examples/P5_missing_data/) |
---

## Milestones

Weights and deadlines are in the syllabus.

| | What | Read | Download | Source | Model answer |
|---|---|:--:|:--:|:--:|---|
| **M0** | Feasibility memo — lock your paper | [HTML](milestones/M0_assignment.html) | [PDF](milestones/M0_assignment.pdf) | [md](milestones/M0_assignment.md) | [example](examples/M0_feasibility/) |
| **M1** | Five increments compiled + dominant-threat judgment (deck + repository zip) | [HTML](milestones/M1_assignment.html) | [PDF](milestones/M1_assignment.pdf) | [md](milestones/M1_assignment.md) | [example](examples/M1_replication/) |
| **M2** | Live critique of another group's M1 | [HTML](milestones/M2_assignment.html) | [PDF](milestones/M2_assignment.pdf) | [md](milestones/M2_assignment.md) | [example](examples/M2_critique/) |
| **M3** | Individual oral defense | [HTML](milestones/M3_assignment.html) | [PDF](milestones/M3_assignment.pdf) | [md](milestones/M3_assignment.md) | [example](examples/M3_defense/) |
| **M4** | Reanalysis letter + repository | [HTML](milestones/M4_assignment.html) | [PDF](milestones/M4_assignment.pdf) | [md](milestones/M4_assignment.md) | [example](examples/M4_reanalysis_letter/) |

**Read the model answers in order.** M1 → M2 → M3 → M4 tells one continuous story: a group
replicates a paper, another group critiques that replication, the first group answers the
critique under questioning, and the result is written up. That arc *is* the course.

---

## The demonstration paper

| | |
|---|---|
| [The paper](paper/) | Kueh et al., *BMJ Open* 2026;16:e113719 (CC BY-NC) |
| [Reproduction pipeline](reproduction/) | Full R code that rebuilds every number |
| [Pipeline walkthrough](reproduction/WALKTHROUGH.md) | What each script decides, the sample funnel, and two NHANES traps |
| [Reproduction report](reproduction/reproduction_report.md) | What reproduced, what did not, and why |

Headline: N = 6,371 against the published ~6,300; Group IV hazard ratio 15.14 unadjusted →
2.91 adjusted (published 15.13 → 2.89).

**These are answer keys, not templates.** You will do this on *your* paper.

---

## Lectures

| Week | Topic | Lecture plan | Slide deck |
|:--:|---|---|---|
| 1 | Intro & reproducibility | [HTML](lectures/Week1_intro_and_reproducibility.html) · [PDF](lectures/Week1_intro_and_reproducibility.pdf) · [md](lectures/Week1_intro_and_reproducibility.md) | [HTML](lectures/slides/Week1_intro_slides.html) · [PDF](lectures/slides/Week1_intro_slides.pdf) · [qmd](lectures/slides/Week1_intro_slides.qmd) |
| 2 | NHANES & reading methods | [HTML](lectures/Week2_nhanes_and_reading_methods.html) · [PDF](lectures/Week2_nhanes_and_reading_methods.pdf) · [md](lectures/Week2_nhanes_and_reading_methods.md) | [HTML](lectures/slides/Week2_nhanes_slides.html) · [PDF](lectures/slides/Week2_nhanes_slides.pdf) · [qmd](lectures/slides/Week2_nhanes_slides.qmd) |
| 3 | Cohort construction & FLI | [HTML](lectures/Week3_cohort_construction_FLI.html) · [PDF](lectures/Week3_cohort_construction_FLI.pdf) · [md](lectures/Week3_cohort_construction_FLI.md) | [HTML](lectures/slides/Week3_cohort_FLI_slides.html) · [PDF](lectures/slides/Week3_cohort_FLI_slides.pdf) · [qmd](lectures/slides/Week3_cohort_FLI_slides.qmd) |
| 4 | Confounding & Table 1 | [HTML](lectures/Week4_confounding_and_table1.html) · [PDF](lectures/Week4_confounding_and_table1.pdf) · [md](lectures/Week4_confounding_and_table1.md) | [HTML](lectures/slides/Week4_confounding_slides.html) · [PDF](lectures/slides/Week4_confounding_slides.pdf) · [qmd](lectures/slides/Week4_confounding_slides.qmd) |
| 5 | Interaction & effect modification | [HTML](lectures/Week5_interaction_effect_modification.html) · [PDF](lectures/Week5_interaction_effect_modification.pdf) · [md](lectures/Week5_interaction_effect_modification.md) | [HTML](lectures/slides/Week5_interaction_slides.html) · [PDF](lectures/slides/Week5_interaction_slides.pdf) · [qmd](lectures/slides/Week5_interaction_slides.qmd) |
| 6 | Complex survey design | [HTML](lectures/Week6_complex_survey_design.html) · [PDF](lectures/Week6_complex_survey_design.pdf) · [md](lectures/Week6_complex_survey_design.md) | [HTML](lectures/slides/Week6_survey_slides.html) · [PDF](lectures/slides/Week6_survey_slides.pdf) · [qmd](lectures/slides/Week6_survey_slides.qmd) |
| 7 | Missing data | [HTML](lectures/Week7_missing_data.html) · [PDF](lectures/Week7_missing_data.pdf) · [md](lectures/Week7_missing_data.md) | [HTML](lectures/slides/Week7_missing_slides.html) · [PDF](lectures/slides/Week7_missing_slides.pdf) · [qmd](lectures/slides/Week7_missing_slides.qmd) |

Later in the term the lectures give way to the M1, M2 and M3 presentation sessions, a
midterm break, and a closing open session. The syllabus schedule gives the weeks and
dates.

---

## Textbooks — both free

- [Advanced Epidemiological Methods](https://ehsanx.github.io/EpiMethods/) — the labs are drawn from here
- [Scientific Writing for Health Research](https://ehsanx.github.io/Scientific-Writing-for-Health-Research/)
- [`svyTable1`](https://ehsanx.github.io/svyTable1) — survey-weighted descriptive tables

**Estimated cost of required materials: $0.**

---

## Turning this into a website

This index works as-is when browsing on GitHub. To serve it as a site instead, set
**Settings → Pages → Source** to *Deploy from a branch*, branch `master`, folder **`/ (root)`**
— not `/docs`, because the links above point outside this folder and Pages only serves
what is under its chosen root.
