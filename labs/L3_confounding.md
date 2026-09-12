# Lab 3: Confounding & Effect Measure Collapsibility

## Overview

In this lab you will explore confounding and effect measure collapsibility using the
Right Heart Catheterization (`RHC`) dataset, investigating the association between
receiving a right-heart catheterization and all-cause mortality. You will prepare the
data, produce a descriptive summary table, and fit a series of regression models to
calculate and compare crude, conditional, and marginal effect estimates (odds ratios, risk
ratios, and risk differences) — seeing how adjustment affects each measure differently.
Your TA will walk through the worked solution during the session.

This is the workflow you will reuse in **P2** on your own locked paper.

## Materials

- **Exercise instructions:** [Confounding](https://ehsanx.github.io/EpiMethods/confoundingE.html)
- **Worked solution:** [The R codes](https://ehsanx.github.io/EpiMethods/confoundingEsolution.html)

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
- **Due:** end of the lab session (Thu Oct 1).

## Grading: Complete / Incomplete

You receive **Complete** if the document knitted without errors, your group name and
members are in it, and it was submitted before the lab ended. Only members present in the
room receive credit.

---

## Where this lab fits

This lab is one step in a weekly chain: Tuesday’s lecture sets up the method, Thursday’s lab runs it on fixed teaching data, and your increment applies it to the paper your group locked at M0.

| | Document | How this lab connects |
|---|---|---|
| **This week’s lecture** | [Week 4 — Confounding and DAGs; Table 1; variable roles](https://ehsanx.github.io/SPPH604-2026W/lectures/Week4_confounding_and_table1.html) | Tuesday moved from a frozen cohort to estimates: what Table 1 is for, how to decide an adjustment set from causal and temporal reasoning, and why what you leave out (mediators, colliders) matters as much as what you put in. This lab runs that sequence on the RHC data and watches crude, conditional and marginal estimates behave differently. |
| **Slide deck** | [Week 4 deck](https://ehsanx.github.io/SPPH604-2026W/lectures/slides/Week4_confounding_slides.html) | The same material as slides, with speaker notes. Press `S` for notes, `F` for fullscreen. |
| **Your increment** | [P2 — Confounding diagnostic](https://ehsanx.github.io/SPPH604-2026W/practice/P2_confounding_diagnostic.html) | Produce your own Table 1 plus a written adjustment rationale — which variables you adjust for, which you deliberately do not, and why. |
| **Milestone** | [M1 — Replication and interrogation](https://ehsanx.github.io/SPPH604-2026W/milestones/M1_assignment.html) | P2 enters M1 as **Confounding, adjustment set, Table 1**. P2 is optional and ungraded with nothing to submit; M1 is where it is assessed. |
