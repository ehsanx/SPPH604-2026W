# Lab 2: Accessing & Preparing NHANES–Mortality Data

## Overview

In this lab you will learn how public health researchers link large survey datasets with
national mortality records and prepare an analytic dataset for modeling. The exercise uses
NHANES 1999–2014 linked to CDC mortality data to study the association between
benzodiazepine and opioid use and all-cause mortality. You will work through downloading
and importing data, merging files, applying eligibility criteria, creating exposure
categories, recoding covariates, producing a descriptive table, and fitting a logistic
regression. Your TA will walk through the worked solution during the session.

This is the workflow you will reuse in **P1** on your own locked paper.

## Materials

- **Exercise instructions:** [Accessing & Preparing NHANES–Mortality Data](https://ehsanx.github.io/EpiMethods/accessingE2.html)
- **Worked solution:** [Exercise Solution](https://ehsanx.github.io/EpiMethods/accessingE2solution.html)
- **Background on downloading:** [Accessing Data Guide](https://ehsanx.github.io/EpiMethods/accessing8.html)

> **If the download stalls,** the TA will point you to a pre-built copy of the merged
> dataset so you can continue. Thirty people pulling from CDC at once over campus wifi is
> the most likely way this lab goes wrong, and it is not your fault.

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
- **Due:** end of the lab session (Thu Sept 24).

## Grading: Complete / Incomplete

You receive **Complete** if the document knitted without errors, your group name and
members are in it, and it was submitted before the lab ended. Only members present in the
room receive credit.

---

## Where this lab fits

This lab is one step in a weekly chain: Tuesday’s lecture sets up the method, Thursday’s lab runs it on fixed teaching data, and your increment applies it to the paper your group locked at M0.

| | Document | How this lab connects |
|---|---|---|
| **This week’s lecture** | [Week 3 — Cohort construction (FLI, MASLD criteria, eligibility)](https://ehsanx.github.io/SPPH604-2026W/lectures/Week3_cohort_construction_FLI.html) | Tuesday built the MASLD cohort definition on the board — coding the FLI, applying FLI ≥ 60 plus at least one cardiometabolic criterion, and choosing one defensible alcohol coding. This lab implements it, and outputs a funnel with N at every step. |
| **Slide deck** | [Week 3 deck](https://ehsanx.github.io/SPPH604-2026W/lectures/slides/Week3_cohort_FLI_slides.html) | The same material as slides, with speaker notes. Press `S` for notes, `F` for fullscreen. |
| **Your increment** | [P1 — Analytic cohort](https://ehsanx.github.io/SPPH604-2026W/practice/P1_analytic_cohort.html) | Repeat the funnel for *your own* locked paper: write each inclusion and exclusion as executable logic, report N at every step, and flag one ambiguous eligibility sentence you had to adjudicate. |
| **Milestone** | [M1 — Replication and interrogation](https://ehsanx.github.io/SPPH604-2026W/milestones/M1_assignment.html) | P1 enters M1 as **Analytic cohort and eligibility**. P1 is optional and ungraded with nothing to submit; M1 is where it is assessed. |
| **Builds on** | [L1 — NHANES data wrangling](https://ehsanx.github.io/SPPH604-2026W/labs/L1_data_wrangling.html) | You build today’s analytic dataset from the merged frame you made in L1. |
