# M0 — Feasibility Gate

**Group · Feasibility memo · Weight and deadline: see the syllabus**

---

## What M0 is

Your entire project is built on a **single recent, open-data paper** that your group
selects and **locks** at M0. **Recent** means published in the current calendar year or
the five preceding ones — for 2026W, a publication year of 2021 or later. Because the
weekly increments deliberately exercise specific
methods — cohort reconstruction, confounding, interaction, design-aware estimation and
missing data — not every paper can support the full sequence.

M0 is the gate that checks yours can. It is a gate, not a grade, but a paper
that cannot clear it **cannot be carried into P1–P5**.

## What you submit

A **short feasibility memo** confirming all six criteria below, each with a **specific
pointer** — variable names, file names, sample sizes. Not "NHANES has weights", but which
weight variable, in which file.

Your memo must end with a **Cover note** section containing a one-line contribution note
per member, any external-feedback disclosure, and an AI Use Statement. M0 submits no
repository, so the memo is the only place it goes.

## The six criteria

Your paper is eligible **only if you can identify all six**.

| | Criterion | What it means |
|---|---|---|
| 1 | **Reconstructable data** | Accessible raw or near-raw microdata (NHANES, NHIS, or a comparable fully public source) from which you can rebuild the analytic cohort. A paper whose numbers can only be read from a summary table, with no underlying data you can re-run, does **not** qualify. |
| 2 | **A clear exposure and outcome** | A single primary association you can state in one sentence. |
| 3 | **Plausible confounders** | Measured covariates that support a defensible, causally-reasoned adjustment set. |
| 4 | **Adequate size and events** | Enough observations — and, for time-to-event outcomes, enough events — for the main analysis *and* at least one subgroup or interaction analysis to be stable. |
| 5 | **Design variables** | Your paper must carry a design or outcome-structure feature this course teaches you to handle, and you must name it and point to the variables that encode it. Normally that is complex-survey sampling — the weights, strata and PSU identifiers that make a design-aware re-estimate possible. The other qualifying case is a time-to-event outcome — follow-up time and a censoring indicator — and on that route you must also name here the one structural choice you will interrogate at P4: the time scale, the censoring rule, the index date, or the handling of competing events. The two routes do not lead to the same deliverable. The survey route gives P4 a naive-versus-weighted contrast on one estimand; the time-to-event route gives P4 a reproduction of the paper's survival estimand plus a structural interrogation of the choice you named, and no such contrast. Complex-survey data is the default case and the one the demonstration paper uses. A paper carrying neither feature does not qualify: there would be nothing for P4 to respect. |
| 6 | **A genuine incomplete-observation problem** | Point to at least one variable your locked analysis actually uses — the exposure, the outcome, or a covariate in the main model — that is absent for records which should have carried it. That is the problem P5 analyses, and it is what this criterion asks for. Designed subsampling, eligibility restrictions, the disease definition, and failure to link or follow up the outcome also shrink a cohort; you must tell them apart from missingness and you report them at P5, but none of them satisfies this criterion on its own, because P5 does not address them with the methods this course teaches. What fails is a paper whose analysis variables are complete by construction, leaving nothing to measure. |

**Criterion 5 is not waivable.** Complex-survey data is the default route through it, not
the only one; a paper whose data carry no design feature to respect cannot support P4.

**Three things that catch people out on criterion 6:**

- **Designed subsampling does not satisfy it.** If the study deliberately measured
  something in a subsample and supplies a weight for it, absence outside that subsample
  is a design feature with a documented fix — the right weight, plus an honest sentence
  naming who your estimate is about. That is a scope question, not a missing-data problem.
- **The test is not size.** Do not argue from magnitude. The demonstration paper's main
  model is incomplete for one covariate in under 2% of its cohort and that clears the
  gate. Ask instead whether you could have known in advance that handling it would change
  nothing; if you could not, it is worth analysing, and P5 measures whether it mattered.
  "It did not" is a result.
- **The problem must arise from your locked analysis.** Introducing extra variables
  solely to manufacture one is not a missing-data analysis; it is a change of adjustment
  set wearing a disguise.

## If your paper does not qualify

Bring it early. If your first choice fails the gate, the teaching team will help you
identify an eligible replacement **before** the M0 lock. That is much cheaper than
discovering the problem at P4.

The lock means there are no elective changes of paper after the M0 deadline: you carry
the paper you named through P1–P5, M1, M2, M3 and M4. It does not tie you to a paper the
memo itself shows cannot work. If your memo makes clear that your paper cannot clear all
six criteria, the teaching team may require you to replace it; the paper you then move to
becomes your locked paper. That is the teaching team's decision to make, not a swap you
can elect.

The demonstration paper used throughout the course — a MASLD / NHANES all-cause mortality
analysis — passes all six, and is used to illustrate what each increment should look like.

## Weight, deadline and policy

See the syllabus. It governs what this milestone is worth, when it is due, whether the
weight can be shifted, and any late penalty. This page describes the task only.
