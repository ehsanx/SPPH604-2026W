# Lab 4: Effect Modification & Interaction

## Overview

In this lab you will work through **effect modification** and **interaction** using the
`RHC` dataset, investigating whether the effect of right-heart catheterization on
mortality is modified by a patient's Do-Not-Resuscitate (DNR) status. You will prepare an
analysis-ready dataset, fit logistic regression models with interaction terms, and
calculate the Relative Excess Risk due to Interaction (RERI), Attributable Proportion (AP)
and Synergy Index (SI) to quantify interaction on both the multiplicative and additive
scales. Your TA will walk through the worked solution during the session.

This is the workflow you will reuse in **P3** on your own locked paper.

## Materials

- **Exercise instructions:** [Interaction in Epidemiology](https://ehsanx.github.io/EpiMethods/confoundingE2.html)
- **Worked solution:** [R codes](https://ehsanx.github.io/EpiMethods/confoundingE2solution.html)

**Before you come to lab**, install the two packages this exercise needs:

```r
install.packages(c("interactionR", "Publish"))
```

Note the capital **P** in `Publish` — the CRAN package is capitalised even though the
function you call is lowercase `publish()`.

## Your task

1. Follow along as the TA explains the worked solution.
2. Run the R Markdown file yourself, as a group, on your own laptop.
3. Put your **group name and the first names of everyone present** in the `author:`
   field at the top of the file.

4. Add `sessionInfo()` in a final code chunk.
5. Knit to **PDF or HTML** and submit that one file before the lab ends.

No written explanations are required. If you get stuck, ask the TA in the room — that is
what the session is for.

## Deliverable

- **One file per group:** the knitted PDF or HTML.
- **Due:** end of the lab session (Thu Oct 8).

## Grading: Complete / Incomplete

You receive **Complete** if the document knitted without errors, your group name and
members are in it, and it was submitted before the lab ended. Only members present in the
room receive credit.

---

## Where this lab fits

This lab is one step in a weekly chain: Tuesday’s lecture sets up the method, Thursday’s lab runs it on fixed teaching data, and your increment applies it to the paper your group locked at M0.

| | Document | How this lab connects |
|---|---|---|
| **This week’s lecture** | [Week 5 — Interaction and effect modification](https://ehsanx.github.io/SPPH604-2026W/lectures/Week5_interaction_effect_modification.html) | Tuesday separated effect modification from interaction, and the multiplicative scale from the additive one. This lab fits the product term, extracts stratum-specific estimates, and computes RERI, AP and SI so you have done both scales by hand. |
| **Slide deck** | [Week 5 deck](https://ehsanx.github.io/SPPH604-2026W/lectures/slides/Week5_interaction_slides.html) | The same material as slides, with speaker notes. Press `S` for notes, `F` for fullscreen. |
| **Your increment** | [P3 — Effect modification](https://ehsanx.github.io/SPPH604-2026W/practice/P3_effect_modification.html) | Run **one pre-specified** effect-modification test on your own paper’s exposure, and state the verdict as evidence rather than as a mechanism: what the data show at the precision you have, and what the interval leaves open. |
| **Worked example** | [P3 example](https://ehsanx.github.io/SPPH604-2026W/examples/P3_effect_modification/P3_effect_modification_submission.html) — [its code](https://ehsanx.github.io/SPPH604-2026W/examples/P3_effect_modification/P3_code.html) | A completed P3, including how the verdict is worded when the interval is wide. That wording is the hard part, not the arithmetic. |
| **Milestone** | [M1 — Replication and interrogation](https://ehsanx.github.io/SPPH604-2026W/milestones/M1_assignment.html) | P3 enters M1 as **Effect modification**. P3 is optional and ungraded with nothing to submit; M1 is where it is assessed. |
