---
output:
  pdf_document:
    latex_engine: xelatex
  html_document: default
geometry: margin=1in
header-includes:
  - '\usepackage{newunicodechar}'
  - '\newunicodechar{→}{\ensuremath{\rightarrow}}'
  - '\newunicodechar{≈}{\ensuremath{\approx}}'
  - '\newunicodechar{≥}{\ensuremath{\geq}}'
  - '\newunicodechar{≤}{\ensuremath{\leq}}'
  - '\newunicodechar{×}{\ensuremath{\times}}'
  - '\newunicodechar{·}{\ensuremath{\cdot}}'
  - '\newunicodechar{½}{\ensuremath{\tfrac{1}{2}}}'
  - '\newunicodechar{…}{\ldots}'
---
# P5 — Missing-data sensitivity

**Week 7 · applies L6 (Missing data) · optional and ungraded — no separate deadline, nothing to submit; M1 is assembled from these five increments**
**Keep in your group GitHub repo:** a missingness audit + one justified missing-data analysis compared with complete-case.

## The question this week

*Which reductions in your sample are actually missing data, how much genuine
missingness is there, and does handling it change your main estimate?*

The trap this increment exists to defuse: **a shrinking N is not evidence of a
missing-data problem.** Cohorts shrink for several reasons and only one of them is
missingness.

## Step 1 — Classify every reduction before naming any of it "missing"

Go back to your P1 funnel and give every downward step a type. Do this **first**, before
you quantify anything.

| Type | What it is | Can a missing-data method fix it? |
|---|---|---|
| **DESIGN** | The study deliberately measured this variable in a subsample, and supplies a weight for it | No — and it does not need fixing. Use the right weight (P4). |
| **ELIGIBILITY** | A definitional restriction: age, calendar window, geography | No — it states who the study is about |
| **TARGET POPULATION** | A disease or exposure definition: people who do not have the condition | No — they are not who the paper is about |
| **OUTCOME ASCERTAINMENT** | Failure to link or follow up for the outcome — the record was never in a position to carry a value | No — count it, report it separately, and do not impute it |
| **MISSINGNESS** | Someone who *should* have a value and does not | **Yes — this is the only row a missing-data method addresses** |

**Designed subsampling is not missing data.** If your survey supplies a subsample weight,
absence outside that subsample is a design feature with a documented fix, not an
uncorrectable selection bias. Inference remains conditional on the weighting assumptions
— say so — but do not call it MNAR.

## Step 2 — Name the problem you will analyse, and scope the rest

Your sensitivity analysis runs on the MISSINGNESS rows only: records that should have
carried a value on a variable your locked model uses and do not. That is exactly what
M0 criterion 6 required you to point at, and it is the only loss P5 addresses with the
methods this course teaches. It must arise from your locked scientific analysis — the
variables your main model already uses, not variables added until a problem appears.

The other rows stay in your write-up. DESIGN is answered by the weight you chose at P4;
inference stays conditional on the weighting assumptions — say so, and do not call it
MNAR. ELIGIBILITY and TARGET POPULATION state who the paper is about; report them so
nobody reads them as attrition. OUTCOME ASCERTAINMENT is failure to link or follow up —
the record was never in a position to carry an outcome value, so count it, report it
separately, and do not impute it. A record that was followed and still has no outcome
value is missingness, and belongs here in Step 2. Where any of these limits who your
estimate applies to, write the one sentence that states the population your conclusion
is about.

None of this says every loss above is unanalysable. Design is already answered, by the
P4 weight; eligibility and target population state who the study is about, so there is
nothing there to analyse. Selection beyond the design weight, and failure to link or
follow up, do have methods — selection models and censoring weights among them — but
they are not the methods this course teaches, so at P5 you classify, report and scope
those losses rather than analyse them.

> Adding covariates to manufacture missingness changes your adjustment set and answers a
> different question. That is not a missing-data analysis.

## What to do

1. **Classify** every funnel step by type (Step 1). One table, five categories.
2. **Identify** the genuine missingness arising from your locked model (Step 2).
3. **Quantify** it: which variables, how many observations each, overlap between them,
   and the loss both unweighted and weighted.
4. **State your estimand** before comparing anything — complete-case and any alternative
   can silently target different populations.
5. **Choose a method** and state the assumptions that would make it informative.
6. **Measure whether it matters.** Compare against your P4 design-aware estimate and say
   whether the difference is *practically* meaningful, not merely whether one is
   "significant".

## Deliverable

- The **typed funnel table** — this becomes your M1 missingness-audit slide.
- A quantification of the genuine missingness in your locked model's variables.
- Your complete-case estimate against one justified alternative, with the estimand and
  assumptions stated, and two or three sentences on whether it changed anything.
- One sentence naming the population your conclusion is about, given every restriction
  in the funnel. Not a caveat added if there is room — part of the deliverable.

## Worked example — MASLD/NHANES demonstration

- **Classified:** after eligibility, the two largest reductions are DESIGN (the fasting
  subsample, handled by `WTSAF2YR`) and TARGET POPULATION (people without steatosis).
  Neither is missing data. Genuine missingness across the whole funnel is
  **792 item-nonresponse losses** and, separately, **2 outcome-ascertainment losses** —
  different problems, not added together.
- **Identified:** within the locked domain — the 6,048 rows P5 analyses — exactly **one**
  Model-1 covariate carries any missingness: cancer status,
  **109 observations, 1.8% unweighted, 1.18% weighted**.
- **Measured:** complete-case **2.97**, both extreme assignments of the missing values
  **2.98 / 2.99**, multiple imputation **2.98**. Everything inside a 0.02 band.
- **Concluded:** this missing-data problem mattered little **after we measured it**. The
  analysis was necessary because we did not know that in advance.

## What good looks like

- **Exceptional:** classifies every funnel step by type before quantifying anything;
  identifies missingness arising from the locked model rather than manufactured; states
  the estimand and the assumptions; measures the effect and reports it honestly —
  including when the honest answer is "no material change" — and states in one sentence
  the population the conclusion is about.
- **Adequate:** quantifies the missingness in the model's variables, runs complete-case
  against one alternative, interprets sensibly.
- **Weak:** treats total cohort shrinkage as the missing-data problem; calls designed
  subsampling MNAR; adds variables until a missing-data problem appears; reports
  "<10% missing, complete-case is fine" with no analysis; builds the increment on a loss
  P5 does not address with the methods this course teaches — designed subsampling,
  eligibility, the disease definition, or a linkage failure.

## Be ready to defend (M3)

> *"Point at one step in your funnel and tell me whether it is design, eligibility,
> target population, outcome ascertainment, or missingness — and how you know."*

## AI co-pilot note
A co-pilot will typically report the small per-variable missingness, run a quick
`mice()` with default settings, and declare victory — never noticing the large
*selection* into the analytic sample. Justify the imputation model and follow the
selection upstream yourself.

## Lab → project handoff
You are applying **L6 (Missing data)** — examining the missingness pattern and using
multiple imputation with design-adjusted regression (EpiMethods `missingdataE`).
Choose the imputation model and the number of imputations to fit *your* problem, not
the lab's fast defaults.
