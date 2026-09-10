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
# SPPH 604 — Project Increments P1–P5

These five weekly increments turn your **M0-locked paper** into your **M1
replication**. Each week you apply that week's lab skill to *your own* paper and
commit one small, reproducible piece to your group repo. By the end of P5 you have
assembled M1 — and you have practised the two things assessed after it: critiquing
another group's M1 at M2, and defending your own analysis, alone, at M3.

## The one question you are answering all term

You keep **one scientific question** fixed and interrogate it from five angles. For
the demonstration paper it is:

> *Among adults meeting the study's MASLD criteria, is central adiposity associated
> with all-cause mortality — and how robust is that to cohort construction,
> confounding, effect heterogeneity, survey design, and missing data?*

Write the equivalent one-sentence question for **your** paper in P1 and keep it at
the top of every increment.

## Every increment runs the same four moves

1. **Replicate** — what did the authors do, and can you reproduce it?
2. **Interrogate** — which analytic choice matters most here?
3. **Improve** — implement one defensible alternative.
4. **Defend** — does it change the scientific interpretation, and why?

## The five increments

Note the **+1 offset**: L1 (shortlist) has no increment, so each P lines up with the
*next* lab number.

| # | Increment | Week | Applies lab | Feeds M1 slide |
|---|---|:--:|---|---|
| **P1** | Analytic cohort | 3 | L2 Analytic data | Cohort flow diagram |
| **P2** | Confounding diagnostic (Table 1) | 4 | L3 Confounding | Table 1 + variable roles |
| **P3** | Effect modification (interaction) | 5 | L4 Interaction | Effect-modification slide |
| **P4** | Design-aware main estimate | 6 | L5 Survey analysis | Reproduced Table 2 / KM |
| **P5** | Missing-data sensitivity | 7 | L6 Missing data | Missingness audit |

These increments are **optional and ungraded** — there is no separate weight, no
separate deadline, and nothing to submit. Keep each one in your **group GitHub repo**
as you go, because **M1 is assembled from these five increments**: doing them week by
week is what stops M1 from becoming five weeks of work in one. Each handout ends with a
*What good looks like* section — use it to check your own work — and a **Be ready to
defend** question, which is the kind of thing you will be asked live at M3.

## Where "the dominant threat" went: into M1

Naming the **single most consequential threat** to the paper's conclusion is a
*synthesis* judgment — you cannot rank threats before you have actually done the
confounding (P2), interaction (P3), design (P4), and missingness (P5) work. So it is
**not a weekly increment**; it is the analytic-judgment core of **M1**. At M1 you:

1. present your P1–P5 replication, then
2. argue which one threat could most change the interpretation, and
3. run or propose one targeted check on it.

That "biggest threat" argument is what your **M2 reviewers will interrogate**, and what you defend at M3.

## Ground rules for every increment

- **Do not force the paper's exact numbers.** A discrepancy you have *traced and
  explained* beats an unexplained exact match, or code that hard-codes the target.
- **Justify, don't automate, your choices.** "Adjust for everything," AIC/stepwise
  confounder selection, and hard-coded imputation settings are lab conveniences, not
  project methods. Argue from causal/temporal reasoning.
- **AI co-pilots are allowed — and you are accountable.** Each handout names a mistake
  a co-pilot can make at that step. You must find and fix it, and you must be able to
  answer that increment's **defence question** live at M3, alone.

## Optional: a one-page note on what you decided

Nothing in this section is collected, read, or marked. It is a habit some groups
find useful, offered here because it costs about a page and it makes five separate
increments easier to assemble into one M1.

Once your paper is locked, the seven things below are already settled somewhere in
your group's head — establishing them is what M0 asked of you. Writing them down in
one place, early, gives you a record of what you believed *before* you had seen any
of your own results:

1. **The scientific question** — one sentence, in the terms your own analysis will
   use.
2. **The primary contrast and estimand** — which two groups are compared, on what
   scale, and in which population.
3. **The exposure and outcome definitions** — by variable name and cut point, not by
   description.
4. **The prespecified adjustment set** — the causal or temporal reason for each
   variable you include, and for any important one you deliberately leave out.
5. **The effect modifier you intend to examine** — and why that one rather than
   another.
6. **The design features your analysis has to respect** — named, with the variables
   that encode them (weights, strata, and clusters, where your data have them).
7. **The missingness you expect to have to handle** — which variable of your locked
   analysis carries it, and roughly how much.

Where you keep it is up to you: a file in your group repo, a shared document, or a
comment block at the top of your P1 script. There is no template to fill in, no
place to hand it in, and no format anyone is checking.

The point is not to be right the first time. You will change your mind about several
of these, and changing your mind for a stated reason is good epidemiology. The point
is that a decision you wrote down in advance is one you can notice yourself
revising — which is exactly the kind of reasoning you present at M1 and defend at M3.

## The demonstration paper

Each handout contains a *Worked example* box from the instructor's full reproduction
of **Kueh et al., BMJ Open 2026;16:e113719** (MASLD/NHANES). Use it to see the target
and the traps — not to copy. Your paper is different; the *moves* are the same.
