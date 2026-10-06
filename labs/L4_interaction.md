# Lab 4: Effect Modification & Interaction

## Overview

In this lab you will work through **effect modification** and **interaction** using the
`RHC` dataset, investigating whether the effect of right-heart catheterization on
mortality is modified by a patient's Do-Not-Resuscitate (DNR) status. You will prepare an
analysis-ready dataset, fit logistic regression models with a product term (the
multiplicative scale), and calculate the Relative Excess Risk due to Interaction (RERI),
Attributable Proportion (AP) and Synergy Index (SI) — all three on the additive scale. Your
TA will walk through the worked solution during the session.

These are the questions you will ask in **P3** on your own locked paper. If your paper's
outcome is time-to-event, use Tuesday's time-to-event tools rather than this lab's logistic
recipe.

## Materials

- **Exercise instructions:** [Interaction in Epidemiology](https://ehsanx.github.io/EpiMethods/confoundingE2.html)
- **Worked solution:** [R codes](https://ehsanx.github.io/EpiMethods/confoundingE2solution.html)

**Before you come to lab**, install the two packages this exercise needs:

```r
install.packages(c("interactionR", "Publish"))
```

Note the capital **P** in `Publish` — the CRAN package is capitalised even though the
function you call is lowercase `publish()`.

Things to know about the exercise before you read its output:

- **Count the cells first.** Run
  `with(high_dasi_data, table(rhc_status, dnr_status, death_status))`. Only 23 of the 623
  patients have a DNR order, and the exercise's reference cell — RHC *and* a DNR order —
  holds **3 patients**, 1 of whom died. Every RERI, AP and S you compute divides by them,
  which is why their intervals are so wide. This is Tuesday's "count first" slide, in the
  lab's own data.
- **Which cell is the reference?** The text says it changes the reference levels "to
  `No RHC` and `No`"; the code does the reverse (both indicators are 1 for "No"), so the
  reference cell is RHC with a DNR order.
- **S (the synergy index) is an additive-scale measure,** like RERI and AP: S = 1 means no
  *additive* interaction. The exercise text calls it multiplicative; go with Tuesday.
- **A negative RERI means "less than additive",** not that the exposures are protective
  when combined.
- **Death is common here (about 40%),** so odds ratios overstate risk ratios, and an RERI
  computed from odds ratios is not the RERI you would get from risks.
- **Read the intervals, not interactionR's p column.** Its p-values for RERI, AP and S are
  one-sided or on the wrong scale (S prints p = 0.98 while its own interval excludes 1).
- **In 1(c), interactionR prints the question the other way round.** With `em = TRUE` it
  treats the *first* exposure named as the modifier, so as called it shows DNR's effect by
  RHC. Problem 1 asks for RHC's effect by DNR: read it from the `publish()` rows, or swap
  the order of `exposure_names`.
- **The exercise defines interaction as "a departure from multiplicativity".** Tuesday's
  definition (and the EpiMethods *Concepts* page): interaction is the joint effect of two
  exposures, which can be assessed on either scale.
- **Is DNR a fair modifier?** DNR and RHC are both recorded on day 1, and which came first
  is not known. Tuesday's rule says the exposure must not change the modifier. If
  catheterisation (or what it revealed) could prompt a DNR order, DNR fails that rule;
  Problem 1's reading assumes it could not.

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
| **This week’s lecture** | [Week 5 — Interaction and effect modification](https://ehsanx.github.io/SPPH604-2026W/lectures/Week5_interaction_effect_modification.html) | Tuesday used the paper's four groups (obesity × waist fat) to separate effect modification from interaction — each with its own adjustment set — and the multiplicative scale from the additive one. Its rule was to count every cell first. This lab does both questions on a binary outcome, where logistic regression is the right tool: Problem 1 is effect modification (RHC's confounders only), Problem 2 is interaction (the confounders of both). |
| **Slide deck** | [Week 5 deck](https://ehsanx.github.io/SPPH604-2026W/lectures/slides/Week5_interaction_slides.html) | The same material as slides, with speaker notes. Press `S` for notes, `F` for fullscreen. |
| **Your increment** | [P3 — Effect modification](https://ehsanx.github.io/SPPH604-2026W/practice/P3_effect_modification.html) | Run **one pre-specified** effect-modification test on your own paper’s exposure, and state the verdict as evidence rather than as a mechanism: what the data show at the precision you have, and what the interval leaves open. |
| **Worked example** | [P3 example](https://ehsanx.github.io/SPPH604-2026W/examples/P3_effect_modification/P3_effect_modification_submission.html) — [its code](https://ehsanx.github.io/SPPH604-2026W/examples/P3_effect_modification/P3_code.html) | A completed P3, including how the verdict is worded when the interval is wide. That wording is the hard part, not the arithmetic. |
| **Milestone** | [M1 — Replication and interrogation](https://ehsanx.github.io/SPPH604-2026W/milestones/M1_assignment.html) | P3 enters M1 as **Effect modification**. P3 is optional and ungraded with nothing to submit; M1 is where it is assessed. |
